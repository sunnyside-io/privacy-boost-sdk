import Foundation
import AuthenticationServices
import CryptoKit
import PrivacyBoost

/// Default iOS Passkey implementation of `PasskeyDelegate`.
///
/// Uses ASAuthorization APIs for WebAuthn passkey operations (iOS 16+).
///
/// IMPORTANT: passkey-protected vaults are NOT supported on iOS. iOS does not
/// expose the WebAuthn PRF / `hmac-secret` extension, so `getAssertion` falls
/// back to deriving a key from the assertion's ECDSA/P-256 signature. ECDSA
/// draws a fresh random nonce on every signature, so the derived key changes
/// on each unlock: it is NOT a valid PRF, a vault sealed with one derivation
/// can never be reopened by the next, and the key is not portable to the web
/// (which uses the real PRF extension). The SDK rejects `UnlockMethod.passkey`
/// on iOS with a typed error; this delegate is kept only as a reference for a
/// future iOS PRF capability.
///
/// Usage:
/// ```swift
/// if #available(iOS 16.0, *) {
///     let delegate = DefaultPasskeyDelegate()
/// }
/// ```
@available(iOS 16.0, macOS 13.0, *)
public class DefaultPasskeyDelegate: NSObject, PasskeyDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private var continuation: CheckedContinuation<Any, Error>?

    public override init() {
        super.init()
    }

    // MARK: - PasskeyDelegate

    public func createCredential(rpId: String, userId: Data, userName: String) async throws -> PasskeyCredentialResult {
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)

        // Generate a random challenge for registration
        var challengeBytes = [UInt8](repeating: 0, count: 32)
        _ = SecRandomCopyBytes(kSecRandomDefault, challengeBytes.count, &challengeBytes)

        let request = provider.createCredentialRegistrationRequest(
            challenge: Data(challengeBytes),
            name: userName,
            userID: userId
        )

        let credential: ASAuthorizationPlatformPublicKeyCredentialRegistration = try await performRequest(request)

        return PasskeyCredentialResult(
            credentialId: credential.credentialID,
            userHandle: userId
        )
    }

    public func getAssertion(rpId: String, credentialId: Data, prfSalt: Data) async throws -> PasskeyAssertionResult {
        let provider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)

        // The PRF salt is passed as the assertion challenge.
        let request = provider.createCredentialAssertionRequest(challenge: prfSalt)
        request.allowedCredentials = [
            ASAuthorizationPlatformPublicKeyCredentialDescriptor(credentialID: credentialId)
        ]

        let credential: ASAuthorizationPlatformPublicKeyCredentialAssertion = try await performRequest(request)

        // Not a valid PRF: the output is not reproducible. See the type-level note.
        guard let signature = credential.signature else {
            throw SdkError.InternalError(message: "Passkey assertion missing signature")
        }
        let prfKey = derivePrfOutput(signature: signature, salt: prfSalt)

        return PasskeyAssertionResult(
            prfFirst: prfKey,
            prfSecond: nil
        )
    }

    public func isAvailable() -> Bool {
        return true
    }

    // MARK: - ASAuthorizationControllerDelegate

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        continuation?.resume(returning: authorization.credential)
        continuation = nil
    }

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding

    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if os(iOS)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
        #else
        return ASPresentationAnchor()
        #endif
    }

    // MARK: - Private

    private func performRequest<T>(_ request: ASAuthorizationRequest) async throws -> T {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<T, Error>) in
            self.continuation = cont as? CheckedContinuation<Any, Error>
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }

    /// Derive a 32-byte output from a passkey assertion signature via
    /// HKDF-SHA256.
    ///
    /// WARNING: this is NOT a PRF and the output is NOT deterministic; the same
    /// credential and salt yield a different key on each call (see the
    /// type-level note). Passkey unlock is disabled on iOS.
    ///
    /// Left `internal` (not `private`) so the determinism guard test can exercise
    /// this exact code via `@testable import` rather than a drifting copy.
    func derivePrfOutput(signature: Data, salt: Data) -> Data {
        let inputKey = SymmetricKey(data: signature)
        let derivedKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: inputKey,
            salt: salt,
            info: Data("privacyboost-passkey-prf".utf8),
            outputByteCount: 32
        )
        return derivedKey.withUnsafeBytes { Data($0) }
    }
}
