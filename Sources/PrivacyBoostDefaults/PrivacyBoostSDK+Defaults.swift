import Foundation
import PrivacyBoost

/// Convenience factory for creating a `PrivacyBoost` with the current Swift
/// SDK configuration surface.
///
/// Usage:
/// ```swift
/// // Basic
/// let sdk = try PrivacyBoost.withPlatformDefaults(config: config)
///
/// // Preserves compatibility with callers that pass Passkey metadata.
/// let sdk = try PrivacyBoost.withPlatformDefaults(config: config, rpId: "myapp.com")
/// ```
extension PrivacyBoost {
    /// Create an SDK instance.
    ///
    /// - Parameters:
    ///   - config: SDK configuration (indexer URL, chain ID, etc.)
    ///   - keychainService: Keychain service identifier (default: "com.privacyboost.sdk")
    ///   - rpId: Relying party ID for passkey operations (e.g., "myapp.com"). Pass `nil` to skip passkey setup.
    public static func withPlatformDefaults(
        config: PrivacyBoostConfig,
        keychainService: String = "com.privacyboost.sdk",
        rpId: String? = nil
    ) throws -> PrivacyBoost {
        _ = keychainService
        _ = rpId
        return try PrivacyBoost(config: config)
    }
}
