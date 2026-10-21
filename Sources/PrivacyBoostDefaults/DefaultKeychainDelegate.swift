import Foundation
import Security
import LocalAuthentication
import PrivacyBoost

/// Default iOS Keychain implementation of `KeychainDelegate`.
///
/// Uses the iOS Keychain Services API for secure storage.
/// Supports optional biometric protection via `kSecAttrAccessControl`.
///
/// Usage:
/// ```swift
/// let delegate = DefaultKeychainDelegate(service: "com.myapp.privacyboost")
/// ```
public class DefaultKeychainDelegate: KeychainDelegate {
    private let service: String

    public init(service: String = "com.privacyboost.sdk") {
        self.service = service
    }

    public func store(key: String, value: Data, requireBiometry: Bool) async throws {
        // Delete existing item first
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        var addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: value,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        if requireBiometry {
            let access = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                .biometryCurrentSet,
                nil
            )
            if let access = access {
                addQuery[kSecAttrAccessControl as String] = access
                addQuery.removeValue(forKey: kSecAttrAccessible as String)
            }
        }

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SdkError.InternalError(message: "Keychain store failed: \(status)")
        }
    }

    public func load(key: String) async throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw SdkError.InternalError(message: "Keychain load failed: \(status)")
        }
    }

    public func delete(key: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SdkError.InternalError(message: "Keychain delete failed: \(status)")
        }
    }

    public func contains(key: String) async throws -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false,
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    public func isAvailable() -> Bool {
        return true
    }

    public func supportsBiometry() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
}
