import Foundation
import PrivacyBoost

/// Convenience factory for creating a `PrivacyBoost` with the iOS platform
/// defaults registered.
///
/// `StorageBackend.osKeychain` persistence is served by a process-wide
/// `KeychainDelegate`; this registers `DefaultKeychainDelegate` unless the app
/// already registered its own, then constructs the SDK.
///
/// Usage:
/// ```swift
/// let sdk = try PrivacyBoost.withPlatformDefaults(config: config)
/// ```
extension PrivacyBoost {
    /// Create an SDK instance with the platform defaults registered.
    ///
    /// - Parameters:
    ///   - config: SDK configuration (indexer URL, chain ID, etc.)
    public static func withPlatformDefaults(
        config: PrivacyBoostConfig
    ) throws -> PrivacyBoost {
        if !hasKeychainDelegate() {
            registerKeychainDelegate(delegate: DefaultKeychainDelegate())
        }
        return try PrivacyBoost(config: config)
    }
}
