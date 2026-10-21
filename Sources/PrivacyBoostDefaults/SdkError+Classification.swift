import Foundation
import PrivacyBoost

/// Broad error category, matching the WASM SDK's `errorType` property.
/// Use this to branch on error class without exhaustively matching every variant.
extension SdkError {
    /// The broad category of this error.
    public var category: ErrorCategory {
        switch self {
        case .NotAuthenticated, .AuthenticationFailed, .AuthServerError:
            return .auth
        case .NetworkError:
            return .network
        case .InvalidConfig, .ConfigError, .InvalidAddress, .InvalidAmount,
             .InvalidInput, .InsufficientBalance:
            return .validation
        case .Forbidden, .SignatureRejected:
            return .permission
        case .RateLimited:
            return .rateLimit
        case .ShieldError, .TransferError, .NoteError, .MerkleError,
             .ApiError, .ResourceNotFound, .TransactionFailed:
            return .server
        // A wait timeout means the caller backed off; the SDK is fine and the
        // request is still pollable, so it is benign (internal), not a failure.
        case .NotConnected, .WalletError, .TransactionReverted, .SerializationError,
             .WaitTimeout, .InternalError:
            return .`internal`
        }
    }

    /// Whether this error is worth retrying automatically.
    ///
    /// Returns `true` for transient failures (network issues, rate limits,
    /// and server errors explicitly marked retryable).
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
