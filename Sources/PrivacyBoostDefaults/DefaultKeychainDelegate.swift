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

    /// Suffix of the account a new value is written under before it replaces
    /// the current one.
    private static let stagingSuffix = ".pb-staging"

    /// Serializes `store` and `remove` across every instance in the process.
    /// A store replaces an item in several keychain calls, and two stores on
    /// one key could otherwise interleave: each deletes the copy the other
    /// left, or fails adding an item the other just added. Writes are rare
    /// and each is a few keychain calls, so one lock for every key costs
    /// nothing noticeable.
    private static let writeLock = NSLock()

    public init(service: String = "com.privacyboost.sdk") {
        self.service = service
    }

    /// Replace the value under `key` so that no failure loses it. The value is
    /// the encrypted vault, so a lost write is a lost account.
    ///
    /// `load` reads the item under `key` and falls back to a staging item, and
    /// every step below keeps one of the two readable, holding either the old
    /// or the new value. No step deletes the only readable copy: in particular
    /// a staging item that an interrupted store left as the sole copy is kept
    /// until the new value is in place.
    ///
    /// Once the new value is what `load` returns, the store has happened and
    /// reports success. Tidying the staging item after that is best effort:
    /// throwing then would tell the caller the old value is still in place
    /// when it is not.
    ///
    /// Every write is a fresh `SecItemAdd` rather than an in-place update, so
    /// the protection requested here is always the protection the item gets.
    ///
    /// Concurrent calls run one at a time (see `writeLock`); the steps below
    /// assume no other store or remove on the same key runs between them.
    public func store(key: String, value: Data, requireBiometry: Bool) async throws {
        try Self.writeLock.withLock {
            try replace(key: key, value: value, requireBiometry: requireBiometry)
        }
    }

    private func replace(key: String, value: Data, requireBiometry: Bool) throws {
        let protection = try protectionAttributes(requireBiometry: requireBiometry)
        let staging = key + Self.stagingSuffix

        guard exists(account: key) else {
            // A first write, or an interrupted store left its value only in the
            // staging item. Either way writing `key` directly deletes nothing,
            // and the staging item stays until the new value has landed. If
            // `key` does exist after all, the add fails as a duplicate and
            // nothing has changed.
            try add(account: key, value: value, protection: protection)
            try? delete(account: staging)
            return
        }

        // `key` holds the current value, so a staging item is only a leftover.
        try delete(account: staging)
        try add(account: staging, value: value, protection: protection)
        do {
            try delete(account: key)
        } catch {
            try? delete(account: staging)
            throw error
        }
        // From here `load` returns the new value, read from the staging item
        // until it is back under `key`.
        do {
            try add(account: key, value: value, protection: protection)
        } catch {
            // The staging item keeps serving the new value, and the next store
            // takes the path above that writes `key` without deleting it.
            return
        }
        try? delete(account: staging)
    }

    public func load(key: String) async throws -> Data? {
        if let value = try copy(account: key) {
            return value
        }
        return try copy(account: key + Self.stagingSuffix)
    }

    public func remove(key: String) async throws {
        try Self.writeLock.withLock {
            try delete(account: key)
            try delete(account: key + Self.stagingSuffix)
        }
    }

    public func contains(key: String) async throws -> Bool {
        exists(account: key) || exists(account: key + Self.stagingSuffix)
    }

    public func isAvailable() -> Bool {
        return true
    }

    public func supportsBiometry() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }

    // MARK: - Keychain items

    private func itemQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }

    /// Biometric items fail closed: without an access control object the item
    /// would be stored unprotected, which is not what the caller asked for.
    private func protectionAttributes(requireBiometry: Bool) throws -> [String: Any] {
        guard requireBiometry else {
            return [kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly]
        }
        guard let access = SecAccessControlCreateWithFlags(
            nil,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            nil
        ) else {
            throw SdkError.InternalError(
                message: "Keychain store failed: biometric access control is unavailable"
            )
        }
        return [kSecAttrAccessControl as String: access]
    }

    private func add(account: String, value: Data, protection: [String: Any]) throws {
        var query = itemQuery(account: account)
        query.merge(protection) { _, new in new }
        query[kSecValueData as String] = value
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SdkError.InternalError(message: "Keychain store failed: \(status)")
        }
    }

    private func delete(account: String) throws {
        let status = SecItemDelete(itemQuery(account: account) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SdkError.InternalError(message: "Keychain delete failed: \(status)")
        }
    }

    private func copy(account: String) throws -> Data? {
        var query = itemQuery(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

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

    private func exists(account: String) -> Bool {
        var query = itemQuery(account: account)
        query[kSecReturnData as String] = false
        return SecItemCopyMatching(query as CFDictionary, nil) == errSecSuccess
    }
}
