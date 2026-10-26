import Foundation
import PrivacyBoost

/// Broad error category, matching the WASM SDK's `errorType` property. Defined
/// here (not over FFI) because UniFFI error interfaces cannot carry methods, so
/// the category is derived wrapper-side by matching on the error case.
public enum ErrorCategory {
    case auth
    case network
    case validation
    case permission
    case rateLimit
    case server
    case wallet
    case crypto
    case state
    case operation
    case `internal`
}

extension SdkError {
    /// The broad category of this error.
    ///
    /// The binding picks each error's case so that this table agrees with the
    /// core error's own category: `foreign_category` in
    /// `uniffi/shared/tests/errors.rs` is this table, checked there against
    /// core. Change both together.
    public var category: ErrorCategory {
        switch self {
        case .NotAuthenticated, .KeysLocked, .AuthenticationFailed, .AuthServerError:
            return .auth
        case .NetworkError:
            return .network
        case .InvalidConfig, .ConfigError, .InvalidAddress, .InvalidAmount,
             .InvalidInput, .InsufficientBalance:
            return .validation
        case .Forbidden:
            return .permission
        case .RateLimited:
            return .rateLimit
        case .ShieldError, .TransferError, .NoteError, .MerkleError,
             .ApiError, .ResourceNotFound:
            return .server
        case .NotConnected, .WalletError, .SignatureRejected, .AccountSetupRequired,
             .TransactionReverted:
            return .wallet
        case .CryptoError:
            return .crypto
        case .StateError:
            return .state
        // A wait timeout means the caller backed off; the request is still
        // pollable, so it is an operation-level outcome, not an SDK failure.
        case .WaitTimeout, .TransactionFailed, .OperationError:
            return .operation
        case .SerializationError, .InternalError:
            return .`internal`
        }
    }

    /// Whether this error is worth retrying automatically.
    ///
    /// Returns `true` for transient failures (network issues, rate limits,
    /// and server errors explicitly marked retryable). Mirrored by
    /// `foreign_retryable` in `uniffi/shared/tests/errors.rs`.
    public var isRetryable: Bool {
        switch self {
        case .NetworkError, .RateLimited:
            return true
        case let .ApiError(_, _, retryable):
            return retryable
        default:
            return false
        }
    }
}
