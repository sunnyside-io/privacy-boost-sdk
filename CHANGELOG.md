# Changelog

All notable changes to the PrivacyBoost SDK, newest first. The format is based
on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Read **Breaking
changes** before upgrading: a minor version can contain them.

Every platform shares one version line, but a release can ship only some of
them. Each version lists the platforms it shipped on; a platform that isn't
listed stays on its previous version and gets those changes in its next
release.

| Platform | Package |
|----------|---------|
| TypeScript | [`@sunnyside-io/privacy-boost`](https://www.npmjs.com/package/@sunnyside-io/privacy-boost) |
| React | [`@sunnyside-io/privacy-boost-react`](https://www.npmjs.com/package/@sunnyside-io/privacy-boost-react) |
| React Native | [`@sunnyside-io/privacy-boost-react-native`](https://www.npmjs.com/package/@sunnyside-io/privacy-boost-react-native) |
| iOS | Swift package and `PrivacyBoost-iOS.zip` from [privacy-boost-sdk](https://github.com/sunnyside-io/privacy-boost-sdk) |
| Android | `PrivacyBoost-Android.zip` from [privacy-boost-sdk](https://github.com/sunnyside-io/privacy-boost-sdk) |
| CLI | `privacy-boost` binaries from [privacy-boost-sdk](https://github.com/sunnyside-io/privacy-boost-sdk) |

Before 0.2.19 the npm packages were published as `@testinprod-io/privacy-boost`
and `@testinprod-io/privacy-boost-react`.

## [1.3.0] - 2026-10-21

**Platforms:** TypeScript, React

The default iframe vault URL is now `/v17/vault.html`; apps that pin
`iframeUrl` must move to it. The CLI, iOS, Android and React Native entries
below ship with those platforms' next release.

### Breaking changes

- **TypeScript:** `gifts.records()` rejects with `NOT_AUTHENTICATED` (or
  `SESSION_EXPIRED`) once the session can no longer read, instead of answering.
  Merge what it returns into your saved copy by `cGift`; don't replace it.
- **iOS/Android:** a chain context's `getGiftRecords()` throws
  `NotAuthenticated` once the session can no longer read (Swift callers need
  `try`). The main SDK's version returns an empty list; merge, don't replace.
- A chain context from `createChainContext` now ends its own session on any
  lock. Its private reads fail with `KeysLocked` until you unlock and call
  `authenticate` on the chain context again.
- Reading the recovery phrase or keys from a locked account fails with
  `NOT_AUTHENTICATED` (`NotAuthenticated` on mobile), or `KEYS_LOCKED` while a
  read session is still open, instead of `KEY_MANAGEMENT_ERROR` /
  `InternalError`.
- An error thrown by a `tokenProvider` or `getExternalToken` callback is now a
  non-retryable `AUTHENTICATION_FAILED`. For a transient failure, throw with
  `retryable: true` (web) or the SDK's `NetworkError` / `RateLimited` (mobile).
- **iOS/Android:** `CredentialRequired` maps to `InvalidInput` instead of
  `AuthenticationFailed`. `MissingKeys` maps to `NotAuthenticated` and
  `KeyManagement` to `AuthenticationFailed` (both were `InternalError`).
- **React:** `useShieldStatus`, `useTransferStatus` and `useUnshieldStatus`
  poll the active chain client. `useEarn`, `useSwap` and `useGifts` act on the
  root SDK; pass `{ client: usePrivacyBoost() }` to follow their ids while a
  chain client is active.
- **CLI:** exit codes follow the error class: 2 validation or a dismissed
  prompt, 3 retryable or a prompt timeout, 4 auth (including locked keys and an
  account that needs setup), 1 everything else. Most of these used to exit 1.
- **CLI:** saved sessions are keyed by wallet and server, so sessions from
  older versions aren't reused; log in once. Bare `CLIENT_ID` and
  `CLIENT_SECRET` env vars are no longer read; use
  `PRIVACY_BOOST_CLIENT_ID` / `PRIVACY_BOOST_CLIENT_SECRET`.

### Added

- `persistence: { storage: 'memory', unlock: 'pin' }` (or `'password'`) keeps
  a PIN vault in memory only, for a second account on a page that already has
  a persisting instance. It defaults to `session.persist: false`.
- `sdk.portal.sweepRequirements()` returns the pool's current minimum portal
  deposit in base units, with separate ETH and WETH amounts, and works on a
  locked session. **React:** available from `usePortal()`.
- Gateway preflight errors include route observations and the actual and
  minimum output amounts when known.
- Unshield errors from the `unwrapWeth` step (`WAIT_TIMEOUT`,
  `REQUEST_FAILED`, `WETH_UNWRAP_FAILED`) carry the unshield's `requestId`, so
  you can follow up with `transactions.getUnshieldStatus()` instead of
  resubmitting.
- **TypeScript:** `ErrorCodes` lists every code the SDK and server can return,
  including the readiness and gateway quote codes.
- **CLI:** `logout` and `delete-vault` warn before deleting unclaimed gift
  records. `sessions -o json` prints a summary; a raw export needs
  `--include-secrets`.

### Changed

- Server errors keep their type, code and `retryable` flag: 4xx replies and
  non-temporary 5xx replies are no longer retried as network errors. A shield
  whose token lookup gets no answer is a retryable error instead of
  `InvalidInput`.
- Iframe mode restores the saved session after a reload, so `sessionRestored`
  fires and `auth.registrationStatus()` falls back to it, including for configs
  that set only `serverUrl` and `appId`.
- `deleteVault()` clears resident keys and the session token like `lock()`.
  Call `signOut()` afterwards to end a `signIn()` read session.
- Send, `sendBatch`, unshield, earn and swap reserve their input notes
  SDK-wide, so concurrent spends no longer fail with
  `NULLIFIER_ALREADY_USED`.
- The EIP-1193 adapter raises `WRONG_NETWORK` when a chain switch lands on
  another chain, even with `enforceChainId: false`.
- **CLI:** `login -o json` prints exactly one JSON document; notices go to
  stderr. Validation and auth errors print clearer messages.
- **CLI:** the built-in signer encodes EIP-712 typed data in full (nested
  structs, `salt`), so the same typed data can sign differently than in 1.0.x.
- **CLI:** saving over a passphrase-protected session requires
  `--session-passphrase`, and a session file the CLI can't read is left
  untouched instead of overwritten.

### Removed

- **TypeScript:** `PrivacyBoost.setKeyManager`, `sdk.keyVault.getKeyStatus()`
  and the test mocks published under `dist/__mocks__` and
  `dist/__integration__`.
- **React:** the `@sunnyside-io/privacy-boost-react/internal` subpath.
- Undocumented low-level portal helpers. Use `sdk.portal.*` instead.
- **CLI:** the daemon's `send_batch` command.

### Fixed

- A new account signed in on an instance another account used now sets up its
  own vault instead of unlocking the previous account's.
- Recovering a wallet-signature account with its phrase works again, and a
  phrase that belongs to a different account is refused before the vault is
  rewritten.
- Unshield with `unwrapWeth` no longer reports a submitted unshield as failed
  when only the unwrap step times out or fails.
- `resolveIdentity()` returns the privacy address in iframe mode and on
  `ChainClient`.
- **React:** `useRegisteredTokens` ignores stale responses, and the provider
  no longer builds two SDKs under StrictMode.
- **React Native:** overlapping calls no longer panic, and `authenticate()`
  without a key source defaults to wallet-derived keys.
- **iOS:** `DefaultKeychainDelegate` no longer loses a stored value when an
  overwrite fails.
- **CLI:** `gift-refund-by-record` works across runs, and session files are
  written atomically.

### Security

- Gift records (which hold refund secrets), chain-context balances, pending
  transactions and stored approval plans are no longer readable after a
  session ends.
- Transfers check value conservation in every build, unshield approval plans
  get the same integrity check as other plans, and sending to a recipient
  without a usable viewing key is refused.
- Debug output no longer includes note amounts, randomness, account IDs or
  keys.

## [1.2.5] - 2026-10-06

**Platforms:** TypeScript, React, CLI

### Breaking changes

- **React:** `useAuth().status` can be `'locked'` for a signed-in user whose
  keys are locked. It used to report `'connected'`.
- **iOS/Android:** the `AuthPrompts` interface is split into the optional
  `CredentialPrompt`, `RecoveryPrompt` and `AccountCreationRelay`; pass `null`
  for any you don't handle. The `CredentialPrompt` record is renamed
  `CredentialRequest`.

### Added

- `auth.signIn(adapter, options)` signs one message and resolves once the
  account can be read. Keys stay locked until the first spend (send, shield,
  unshield, swap, earn, gift, portal, approval plans), which unlocks through
  the same wallet or a PIN prompt. Reads never prompt.
- `auth.state` (`signedOut`, or `signedIn` with `account` and `locked`) is the
  state to render from; `authChange` fires when it moves.
  `auth.state.account.accountId` carries the AuthRegistry account ID.
- `prompts` in the config (`credential`, `recoveryPhrase`, `recover`,
  `createAccount`) answers unlock and onboarding questions;
  `auth.setPrompts()`, `auth.withPrompts()` and `auth.prompts` change them at
  runtime. **React:** `useAuthPrompts()`.
- `signIn()` resolves `{ status: 'setupRequired', setup }` for a new account
  when no `recoveryPhrase` prompt is set (local mode, Node and native). Show
  `setup.mnemonic`, then call `setup.complete()` (safe to retry) or
  `setup.abandon()`.
- `auth.ensureUnlocked()` unlocks at a moment the app chooses, and
  `auth.signOut()` ends the session.
- `session: { persist }` controls whether the session survives a reload. A
  persisted session restores reads without a wallet signature.
- Unanswered prompts fail with `PROMPT_TIMED_OUT` after 5 minutes (30 for
  recovery-phrase prompts).
- Signing in an approval-only account creates it on chain when it doesn't
  exist yet. If the wallet can't pay the fee, sign-in stops with
  `GAS_FUNDS_REQUIRED` before any wallet prompt; `error.gasFunds` has the
  amounts.
- `authenticateAsSafeMember()` restores a Safe owner's saved session after a
  reload without prompting the wallet, for up to 12 hours.
- **React:** `useAuth()` exposes `state`, `signIn`, `signInWithWalletAdapter`,
  `ensureUnlocked`, `lock` and `signOut`.
- **iOS/Android:** `sign_in()`, `auth_state()`,
  `account_setup()`, `complete_account_setup()`, `abandon_account_setup()` and
  `setPrompts()`. `SDKError` gains `AccountSetupRequired` and `KeysLocked`.

### Changed

- Balances and the `useContacts`, `useLabels`, `useGifts`, `usePortal` and
  `useFees` hooks read on a locked session instead of returning zero or an
  empty list.
- `listPendingApprovalPlans()` and `reconcilePendingApprovals()` work on a
  locked session; reconcile prompts only when an approved plan is ready to
  submit.
- `auth.lock()` returns `'locked'` or `'signedOut'`. On a `signIn()` session,
  lock and auto-lock keep reads available and the next write unlocks again.
- Concurrent spends on a locked session share one unlock prompt. A wrong PIN
  or password is asked again up to ten times, then fails with
  `INVALID_CREDENTIAL`.
- The login message moves to version 3, which names the deployment and what
  signing authorizes. Servers on older versions keep their message.
- Exported sessions move to version 2 and can be keyless (reads only).
  Version 1 sessions still import.
- The default iframe vault URL is `/v14/vault.html`; apps that pin `iframeUrl`
  must move to it. Safe-owner session restore needs it.
- **CLI:** `login` saves a keyless read session; reads run on it and writes
  unlock with the key. A new account's recovery phrase is printed to stderr.

### Deprecated

- `auth.authenticate()` (use `auth.signIn()`), `submitCredential`,
  `proceedAfterMnemonic`, `clearSession()` and `logout()` (use `lock()` or
  `signOut()`), and `isAuthenticated()` (use `auth.state` or
  `hasResidentKeys()`). They still work. **iOS/Android:**
  `is_authenticated()`; use `auth_state()`.

### Removed

- `auth.getSessionInfo()`.

### Fixed

- Signing in right after creating an approval-only account no longer fails
  with "Session account binding is no longer valid".
- An on-demand unlock refuses a wallet that isn't the session's own
  (`NOT_AUTHENTICATED`) instead of switching accounts.
- New approval plans no longer pick notes already held by a pending plan.
- Gift refunds, portal registry publishing and prebuilt approval-plan submits
  unlock on demand instead of refusing a locked session.

### Security

- `auth.signOut()` clears the unlocked vault, so an account signed in afterwards
  on the same instance can't read the previous account's recovery phrase.

## [1.2.3] - 2026-10-02

**Platforms:** TypeScript, React, CLI

### Changed

- Maintenance release with no API changes.

## [1.2.2] - 2026-10-01

**Platforms:** TypeScript, React, CLI

### Added

- `PrivacyBoostError.gatewayPreflight` carries the server's failure
  classification and suggested actions when a swap or earn preflight fails.
  The default iframe vault URL moves to `/v13/vault.html` to carry it.
- Tracked gateway operations record the outcome as soon as the server knows
  it: `gateway.settlement` (`executed`, `fallback`, `failed`),
  `gateway.receiptKind`, `gateway.rescueAvailableAtBlock` and
  `gateway.output`. A refunded swap no longer looks like a completed trade.
- `asGatewaySubmitErrorCode(error)` and `GatewaySubmitErrorCode` read the
  server's refusal code from a failed `swapFromQuote`, `swap` or earn
  submission.
- `ApprovalReconcileEntry` adds `code` and `gatewayPreflight`.

### Changed

- Approval reconcile reports a swap or earn plan refused for a low output as
  `stale`, an expired plan as `expired` and a used plan as `consumed`, instead
  of `failed`.

### Fixed

- A gateway operation that fails keeps the server's reason in `error`, so
  `TransactionFailedError` says why.

## [1.2.0] - 2026-09-30

**Platforms:** TypeScript, React, CLI

### Added

- **TypeScript:** `sdk.vault.buildSendBatchApprovalPlan({ tokenAddress,
  recipients, approvalExpiry })` lets an approval-only account pay several
  recipients in one transfer; submit it with `submitPrebuiltSendApprovalPlan`.
  Needs vault host `/v12/` (the new default iframe vault URL).

### Changed

- Multi-recipient plans use owner package format v5. Approvers need 1.2.0 or
  later to verify them; single-recipient plans stay on v3.

## [1.1.1] - 2026-09-22

**Platforms:** TypeScript, React, CLI

First TypeScript and React release since 1.0.5 (1.1.0 shipped only the CLI),
so it also includes everything listed under 1.1.0.

### Added

- **TypeScript:** `sdk.auth.repairRegistration()` repairs an account whose
  on-chain auth registration failed, asking for a signature or credential only
  when needed. The steps are also available on their own:
  `recoverRegistration()`, `openRegistrationRecoverySession()` and
  `unlockForRegistrationRecovery()`. Needs vault host `/v11/` (the new default
  iframe vault URL).
- **TypeScript:** `sdk.auth.registrationStatus(chainId?)` reports
  `registered`, `pending`, `failed` or `unknown`, with `needsRecovery` set for
  `failed`. It survives a reload.
- **TypeScript:** `sdk.auth.vaultUnlockKind()` (`'pin'`, `'password'`,
  `'walletSignature'`) and `sdk.auth.hasResidentKeys()`, plus the error codes
  `CREDENTIAL_REQUIRED` and `CREDENTIAL_NOT_ACCEPTED`.

### Changed

- **TypeScript:** JSON-RPC reads made at the same time share one request (up
  to ten calls), so balance refreshes no longer trip public-node rate limits.
  Check your RPC endpoint if it refuses JSON-RPC batches.

### Security

- Shield, transfer, unshield, swap and earn change, gift funding and gateway
  outputs are encrypted with fresh per-output ephemeral keys. Existing
  ciphertexts stay readable.
- Viewing private keys stay encrypted in memory while a session is unlocked.

## [1.1.0] - 2026-09-14

**Platforms:** CLI

This version shipped only the CLI. TypeScript and React received these changes
in 1.1.1; React Native, iOS and Android get them in their first release after
1.0.5.

### Breaking changes

- Gateway fees are quoted as `gatewayFeeRate` over `gatewayFeeRateDenominator`;
  `gatewayFeeBps` is removed from every `FeeRates` type. Use
  `calculateGatewayFee()` instead of computing the fee yourself.
- **React:** `useFees().calculateFee()` returns `bigint | null` and yields `null`
  while fee rates are loading, instead of `0n`. Handle the `null` case.
- Swap approval plans require a non-zero `minAcceptableOutputAmount`.
- **TypeScript:** `sdk.portal.withdraw()` and `sdk.portal.delegateAddress()` are
  async. Add `await`.
- **TypeScript:** `tokenProvider` receives a camelCase `LoginPayload` and must
  resolve with `expiresIn`. Convert to snake_case if you forward it to
  `/auth/token` yourself.
- **TypeScript:** The SDK config rejects unknown keys and unknown
  `persistenceStorage` values (`"memory"` is accepted), so a typo fails at
  construction instead of silently disabling persistence.
- **TypeScript:** Custom `KeyVault` implementations must add
  `revealMnemonic(options?)`.
- **iOS/Android:** `getRegisteredTokens()` is async (React Native also
  `resolveIdentity()`), and `TokenBalance.walletBalance` and `decimals` are
  optional instead of defaulting to `"0"` and `18`.
- **iOS/Android:** The keychain delegate's delete method is renamed `remove`, and
  the `send` / `unwrapWeth` parameter renames change Swift argument labels.
- **React Native:** `ExportedSession` is the opaque `{ version, data }` blob used
  by iOS and Android. Sessions saved by older builds still import.

### Added

- Multi-recipient transfers: `sdk.vault.sendBatch({ tokenAddress, recipients })`,
  `useVault().sendBatch`, `send_batch` on iOS/Android/React Native, and
  `privacy-boost send-batch`. History rows gain `counterparties` and
  `tokenValues`.
- History filters by `tokenId` and `direction` on every platform, and an opt-in
  collapsed view that shows each Gateway operation as one row (`collapseGateway`,
  `getCollapsedTransactionHistory`, `--collapse-gateway`).
- Claimable transfers (gifts) under `sdk.gifts`: `fund`, `fundToWallet`,
  `fundSecretBearer`, `claimByCGift`, `claimFromLink`, `refund`,
  `refundByRecord`, `decodeLink`. `records()` lives in memory only; persist the
  records yourself or funded gifts can't be refunded.
- Deposit recovery: `getDepositCancellation()` and `cancelDeposit()` reclaim
  escrow for a shield that never settled; `listShieldsByStatus(['failed'])` and
  `depositRequestIdsFromTransaction(txHash)` find the deposit. CLI:
  `privacy-boost deposit list | ids | status | cancel`.
- `sdk.auth.revealRecoveryPhrase()` shows the recovery phrase inside the vault
  without returning it to your page. Pass `{ strings }` to localize the screen.
- Safe accounts (TypeScript and CLI): `auth.prepareSafeAccount()`,
  `auth.authenticateAsSafeMember()` (the account ID is discovered),
  `auth.bootstrapSafeAccount()`, and `privacy-boost safe prepare | login | setup`.
  Safe owners can reveal the recovery phrase again.
- `siweOrigin` config sets the origin a Safe-member sign-in message names. It
  defaults to `location.origin` in a browser.
- Contacts, labels and campaign progress on every platform: `sdk.contacts`,
  `sdk.labels`, `sdk.campaigns.getStartaleProgress()`, the matching iOS, Android,
  React Native and WASM methods, and `privacy-boost contacts | labels | campaign`.
- **React:** `usePortal`, `useGifts`, `useEarn`, `useSwap`, `useContacts`,
  `useLabels` and `useCampaignProgress`.
- **iOS/Android:** Multi-chain through `createChainContext()` /
  `ChainContextHandle`, previously React Native only.
- **iOS/Android:** OS keychain persistence. Register a delegate with
  `registerKeychainDelegate(delegate, service)`; the platform-defaults factories
  register the bundled one.
- **iOS/Android:** Auto-lock (`idleTtlSecs`, `absoluteTtlSecs`), `lock()`, and
  typed earn and gateway models (`listEarnVaults()`, `getEarnVault()`,
  `getGatewayConfig()`, history and charts) next to the JSON accessors.
- Fee schema v2 with per-operation flat or BPS fees. TypeScript exports
  `calculateFee`, `formatFeeRate`, `validateFeeRates` and
  `validateFeeRatesFor`; Gateway fees can be looked up per calldata selector.
- **TypeScript:** `sdk.vault.getEarnVault(address)`, WalletConnect
  `qrModalOptions`, and the exported `WalletConnectAdapterConfig` /
  `CoinbaseWalletAdapterConfig` types.

### Changed

- The default iframe vault moves to `/v10/vault.html`. A custom vault host must
  serve `/v10/` for the new vault operations.
- Pending approval plans are stored on the server, so `listPendingApprovalPlans()`
  returns the same plans on every device and session. Plans saved locally
  migrate on first listing. Limit: 256 per chain and app.
- Rate-limited and temporarily failing server responses arrive as
  `RateLimited(retryAfterMs)` or a retryable `ApiError` instead of
  `NetworkError`. Check error handling that switches on the error type.
- **TypeScript:** Submits time out after 120 s and other requests after 30 s;
  both remain configurable with `timeoutMs`. `ApiError` now extends
  `PrivacyBoostError`.
- **TypeScript:** WalletConnect requires `eth_signTypedData_v4`, so a wallet
  without it is rejected at connect with `WALLET_CONNECTION_FAILED`.
  `disconnect()` now ends the session for every adapter on the page.
- **React:** `PrivacyBoostProvider` renders an error fallback when
  initialization fails and no `errorComponent` is set.
- Approval-only accounts must sign in with a wallet; `tokenProvider` sign-in is
  rejected in that mode.
- The vault iframe can be embedded only by `https://privacyboost.io` and
  `https://app.privacyboost.io`.

### Deprecated

- **TypeScript:** `to`, `recipientAddress` and `recipientPrivacyAddress` on money
  methods. Use `recipient`.
- The flat `gateway*` fields on transaction rows. Read `tx.gateway`, or use
  `transactionGateway(tx)`.

### Removed

- **React Native:** `setKeychainDelegate`, `setPasskeyDelegate` and
  `setBiometricDelegate`, which had no effect.
- **TypeScript:** The `PrepareLoginPayload` export. `resetWasm()` does nothing
  outside tests; use `PrivacyBoost.dispose()`.

### Fixed

- Portal, gift and deposit-cancellation operations work under the default
  iframe vault instead of throwing `UNSUPPORTED_OPERATION`.
- Unshield, earn, gift funding and consolidation pick notes the server's
  circuits can prove. Transfers no circuit supports fail early with
  `UNSUPPORTED_TRANSFER_SHAPE`.
- **iOS/Android/React Native/CLI:** History notes populate `counterparty`,
  `counterpartyType` and `amount`.
- **iOS/Android/React Native:** Restored sessions keep per-chain auth-key
  registration, so a failed registration is retried. Expect one extra signature
  prompt on the first sign-in after upgrading.
- **TypeScript:** `sdk.apps.getAppInfo()` works, and `listEarnVaults()` is typed
  as `EarnVaultsResponse`.
- **TypeScript:** Reloading the WASM module no longer corrupts memory, and
  calling `dispose()` twice is safe.
- **TypeScript:** WalletConnect shares one provider per page, fixing hung
  pairings and "No matching key" errors, and re-pairs old sessions that can't
  sign typed data.
- **React:** `useFees` no longer shows one token's fees against another.
- Signing in with an explicit mnemonic before the account has a server vault no
  longer fails with "Key manager not initialized".
- An unserved route reports its HTTP status and body instead of a parse error,
  and shield receipt timeouts stay retryable and include the transaction hash.
- **CLI:** Retries a "nonce too low" broadcast with the node's nonce, and prints
  custom revert errors with their arguments.

## [1.0.5] - 2026-06-26

**Platforms:** TypeScript, React, React Native, iOS, Android, CLI

First public React Native, iOS and Android release since 0.2.3.

### Breaking changes

- Sensitive requests fail instead of falling back to plaintext when encrypted
  transport can't be established. Plaintext development servers need an
  explicit opt-in.
- **TypeScript:** Browser apps default to the cross-origin iframe key vault.
  Code that used `sdk.wasm` or a `tokenProvider` must adapt or set
  `keyVault: { mode: 'local' }`, which now logs a warning. Node is unaffected.
- **iOS/Android/React Native:** Passkey unlock is rejected with a `ConfigError`,
  because vaults sealed that way could not be reopened. Use `Biometric`, `Pin` or
  `Password`.

### Added

- `sdk.vault.prepareShield()`, `buildShieldPayload()` and `finalizeShield()`
  build a shield transaction without a wallet so you can relay it yourself. The
  recipient can be a privacy address or a registered Ethereum address.
- **TypeScript:** `sdk.auth.lock()` clears keys from memory and keeps the stored
  vault. `idleTtlSecs` and `absoluteTtlSecs` lock automatically.
- `TransactionReverted` errors separate an on-chain revert from wallet and
  network failures on every platform.

### Changed

- Transfers and unshields retry while the account's auth-key registration is
  still pending on chain.
- Deposits the server rejects report `failed` instead of staying `pending`.
- **iOS/Android:** `isValidAddress()` accepts addresses without `0x` and skips
  checksum checks, and `isValidPrivacyAddress()` rejects malformed addresses,
  matching TypeScript.
- **iOS/Android/React Native:** Running out of gas surfaces as
  `InsufficientBalance` with the message "insufficient gas".
- **CLI:** Caps the transaction gas limit. The `op-sepolia` preset points at
  `https://optimism.sepolia.privacyboost.io`.

### Removed

- **TypeScript:** The page-level signing functions (`signSpending` and related).
  Spend with `shield`, `send` and `unshield`.

### Fixed

- PIN and password vaults created with an SDK-generated phrase keep the phrase,
  so `getMnemonic()` can show it.

### Security

- Each transfer output is encrypted under its own key.
- Vaults are bound to their account and device. Vaults created by 1.0.5 can't
  be opened by older SDK versions.
- The vault iframe can be embedded only by first-party `*.privacyboost.io`
  pages.
- Keys are zeroized after use and kept out of swap on native platforms, and
  signing is hardened. Signatures differ from earlier builds.
- Public keys and raw response bytes no longer appear in SDK logs.

## [1.0.4] - 2026-06-09

**Platforms:** TypeScript, React, CLI

### Added

- **TypeScript:** Node.js 18+ support. The package ships a Node build of the
  WASM core and selects it through the `node` export condition, so it imports
  from a plain Node ESM process.
- **TypeScript:** `@sunnyside-io/privacy-boost/package.json` is exported, so
  tooling that reads the package manifest works again.

### Changed

- **TypeScript:** The core package no longer depends on React; only
  `@sunnyside-io/privacy-boost-react` does.
- **TypeScript:** The published package is about a third smaller.

### Fixed

- `shield()` fails with an error when the wrap or approve transaction reverts,
  instead of continuing and spending gas on a deposit that will revert.
- Note consolidation keeps the rounds it already completed when a later round
  falls below the minimum transfer amount.
- Fetching unspent notes no longer repeats pages, which could inflate the
  reported balance.
- Requests no longer fail when the server's transport encryption key expires
  or the client clock is skewed; the SDK refreshes the key ahead of expiry.

## [1.0.3] - 2026-06-08

**Platforms:** TypeScript, React, CLI

### Added

- PIN and password vault unlock (`persistence.unlock: 'pin' | 'password'`).
  Each PIN attempt is checked through a rate-limited server round-trip, so a
  copied vault can't be brute-forced offline. PINs must be at least 6 digits.
- A wrong PIN or password fails with `INVALID_CREDENTIAL` instead of a generic
  decryption error. **iOS/Android:** it maps to `AuthenticationFailed`.
- Preconfirmations: notes report `confirmed` or `preconfirmed`, and balances
  split into `availableBalance` (spendable now), `pendingBalance` and
  `totalBalance`, with matching note counts.
- `transactions.waitForPreconfirmation()` and `transactions.waitForFinality()`,
  plus an `onPreconfirmed` callback. **React:** `useTransactions()` accepts it.
- `sdk.audit.queryTransactions()` and `sdk.audit.queryBalances()` for auditor
  accounts.
- `FeeRates.minTransferAmountUSD`. Transfers below the minimum are rejected
  before they are submitted.
- **iOS/Android:** `getTokenByAddress`, `getMnemonic`, `proceedAfterMnemonic`,
  `isRegistered`, `getAllPendingTransactions`, `getUnspentNotes`,
  `getMerkleTreeStats`, `getPoolStats`, `getAppInfo`, `toChecksumAddress`,
  `unwrapWeth` and `consolidateNotes`, matching the TypeScript SDK.

### Changed

- The registered-token list is fetched once per session and shared, instead
  of several identical requests at sign-in.
- Balances no longer dip briefly after `send()` or `unshield()`; they refresh
  when the transaction preconfirms.

### Fixed

- The `chainId` getter returns the auto-discovered chain instead of throwing.
  It throws `SDK_CHAIN_NOT_RESOLVED` only while the chain is still unknown.
- The WASM module loads under SES lockdown and in sandboxed iframes.
- Transfers and unshields fetch fresh tree state before submitting, avoiding
  failures from a stale root.
- Transaction history shows the correct counterparty.
- The shield fee is no longer reported as zero.

## [1.0.1] - 2026-04-21

**Platforms:** TypeScript, React, CLI

### Fixed

- Requests recover automatically when the server rotates its transport
  encryption key, instead of failing with `UNKNOWN_KEY_ID`.

## [1.0.0] - 2026-04-21

**Platforms:** TypeScript, React, CLI

First stable release, with the public API stabilized in 0.2.19.

### Fixed

- Balances report the correct `noteCount`.

## [0.2.19] - 2026-04-21

**Platforms:** TypeScript, React, CLI

npm packages moved from `@testinprod-io/privacy-boost` and
`@testinprod-io/privacy-boost-react` to `@sunnyside-io/privacy-boost` and
`@sunnyside-io/privacy-boost-react` starting with this version.

### Breaking changes

- **TypeScript/React:** `TokenBalance.shielded` and `TokenBalance.wallet` are
  renamed to `shieldedBalance` and `walletBalance`.
- **iOS/Android:** `getFees()` takes a token address instead of a token ID.
- **iOS/Android:** `ExportedSession` is an opaque `{ version, data }` value
  instead of exposing individual key fields.
- **iOS/Android:** `SDKError` adds `AuthenticationFailed`, `ConfigError` and
  `InvalidInput`; these were previously reported as `NetworkError`.
- **iOS/Android:** The no-op `setKeychainDelegate`, `setPasskeyDelegate` and
  `setBiometricDelegate` setters are removed.

### Added

- Errors carry `errorType` and `retryable` so apps can branch on the category.
  **iOS/Android:** `ErrorCategory` and `isRetryable`.
- **TypeScript:** `dispose()` releases an SDK instance's resources.
- **iOS/Android/CLI:** `deleteVault()`. **CLI:** `delete-vault` asks for
  confirmation; pass `--yes` to skip it.
- **CLI:** Prompts for the private key interactively. `--private-key` is
  hidden from help and warns when passed on the command line or in the
  environment.

### Changed

- Only idempotent requests (GET, HEAD, OPTIONS) are retried automatically, so
  a timed-out submit is never sent twice.
- A Rust panic surfaces as an SDK error instead of crashing the app.
- `shield()` and `unshield()` reject zero amounts, and `unshield()` checks the
  recipient address checksum.
- **Android:** The AAR ships consumer ProGuard rules, so R8 no longer strips
  the native bindings.

### Fixed

- **iOS/Android:** Wallet balances are no longer always reported as `0`.
- Signing in with client credentials (`clientId` and `clientSecret`) works.

### Security

- Recovery phrases and other key material are cleared from memory after use,
  and secret keys are generated from the OS random number generator.
- Error messages no longer include URL query strings or fragments of a
  recovery phrase.

## [0.2.16] - 2026-04-16

**Platforms:** TypeScript, React

### Changed

- Maintenance release with no API changes.

## [0.2.15] - 2026-04-16

**Platforms:** TypeScript, React

### Breaking changes

- Config fields are renamed: `indexerUrl` → `serverUrl`, `shieldContract` →
  `shieldContractAddress`, `wethContract` → `wethContractAddress`.
- `vault.getRegisteredTokens()`, `getRegisteredTokensWithMetadata()` and
  `getSupportedTokens()` are replaced by `vault.getTokens()`.
- `vault.syncBalance()` and `syncAllBalances()` are renamed to
  `refreshBalance()` and `refreshBalances()`.
- `vault.getBalance()` returns a `TokenBalance` instead of a `bigint`.
- `vault.getFees()` takes a token address.
- `parseAmount()` and `formatAmount()` are top-level exports instead of
  `vault` methods.
- **CLI:** `--indexer-url`, `--shield-contract` and `--weth-contract` are
  renamed to `--server-url`, `--shield-contract-address` and
  `--weth-contract-address`; `search-address` is now `resolve-identity`.

### Added

- `vault.consolidateNotes()` merges small notes into fewer, larger ones, and
  the SDK consolidates automatically when a token's note count grows large.
- `shield()` and `unshield()` report each step through `onProgress`.
- `unshield({ unwrapWeth: true })` waits for the unshield to settle and then
  unwraps WETH to ETH.
- `transactions.fetchHistory()` filters by token and direction, and merges
  results into the transaction store.
- **React:** `useAuth()` returns a `status` of `'disconnected'`,
  `'connected'` or `'authenticated'`; `useTransactions()` can poll pending
  transactions automatically.
- **iOS/Android:** `chainId` and the shield contract are optional in the
  config and auto-discovered from the server.
- **CLI:** `--client-id` and `--client-secret` sign in with client
  credentials.

### Changed

- Sign-in is faster: discovery, login and vault requests run in parallel.

## [0.2.14] - 2026-04-08

**Platforms:** TypeScript, React, CLI

### Added

- **React:** `useActiveClient()` and the `PrivacyBoostClient` type for the
  active chain client.

### Changed

- Balances refresh automatically when a pending transaction resolves.

## [0.2.13] - 2026-04-08

**Platforms:** TypeScript, React, CLI

### Added

- Returning users skip the wallet signature on reload when their stored
  session is still valid.
- Vault recovery: the recovery phrase can be shown again from inside the key
  vault, a vault that can't be decrypted returns a recovery-required result
  instead of an error, and `deleteVault()` removes the vault.
- Retryable errors (network, timeout, rate limit, unavailable) are retried
  with exponential backoff. `ApiError` exposes `retryable` and `retryAfterMs`.

### Fixed

- Shielding native ETH no longer stalls; the SDK waits for the wrap and approve
  transactions to confirm before depositing.
- Shielding native ETH records the pending transaction.
- Recovering from a recovery phrase saves the vault only after it decrypts.

### Security

- Only the limited sign-in token is stored in `localStorage`; the token that
  can read balances and history stays in memory.

## [0.2.12] - 2026-04-04

**Platforms:** TypeScript, React, CLI

### Fixed

- Requests in local key vault mode go through the encrypted transport,
  fixing `405 Method Not Allowed` errors.
- Iframe key vault mode routes requests to the right chain in multi-chain
  apps.

## [0.2.11] - 2026-04-04

**Platforms:** TypeScript, React, CLI

### Breaking changes

- **TypeScript:** The wallet interface passed to `auth.authenticate()` is
  renamed from `WalletAdapter` to `AuthWalletBridge`.
- **TypeScript:** `viem` is a peer dependency; install it alongside the SDK.
- **TypeScript:** Internal WASM key manager types are no longer exported.

### Added

- **TypeScript:** `IdentityResult`, `MnemonicGeneratedResult`, `AppInfo` and
  `AppsResource` are exported.

### Changed

- `shield()` skips the ERC-20 approve when the existing allowance already
  covers the amount.
- Amount parsing rejects non-numeric input and too many decimal places.
- **TypeScript:** `PrivateKeyWalletAdapter` is for development only; it warns
  when constructed and clears the key on disconnect.

### Fixed

- Change notes are encrypted so the owner can decrypt them again; previously
  some change outputs were unrecoverable.
- **TypeScript:** Disposing one SDK instance no longer breaks other instances
  sharing the WASM module.
- **React:** `PrivacyBoostProvider` no longer calls hooks conditionally, and
  `useKeyManager()` recreates its manager when its options change.
- Server API errors are no longer reported as network errors.

### Security

- Signatures use deterministic nonces, and key material is cleared from
  memory after use.

## [0.2.10] - 2026-04-02

**Platforms:** TypeScript, React, CLI

### Fixed

- **TypeScript:** Iframe key vault mode calls the right vault operations.

## [0.2.9] - 2026-04-02

**Platforms:** TypeScript, React, CLI

### Breaking changes

- Transfer fees are a flat amount per token. `getFees()` takes the token, and
  `FeeRates.transferFeeFlat` replaces `transferFeeBps`. Unshield fees are
  unchanged.

### Added

- **TypeScript:** Iframe key vault: with `keyVault: { mode: 'iframe',
  iframeUrl }`, private keys stay in a cross-origin iframe and only
  signatures and ciphertexts reach your page.
- A `preconfirmed` transaction status and an error for transfers below the
  minimum amount.

### Changed

- The first shield registers the account on-chain before any gas is spent.

## [0.2.8] - 2026-03-31

**Platforms:** TypeScript, React, CLI

### Breaking changes

- Deposit and withdraw are renamed to shield and unshield: `vault.deposit()`
  → `shield()`, `vault.withdraw()` → `unshield()`, `getDepositStatus()` →
  `getShieldStatus()`, `getWithdrawalStatus()` → `getUnshieldStatus()`.
  **React:** `useDepositStatus()` → `useShieldStatus()`,
  `useWithdrawalStatus()` → `useUnshieldStatus()`.
- The `unwrapWeth` option on withdrawals is removed. Call `unwrapWeth()` after
  the unshield settles.

### Added

- Shielding native ETH returns the wrap transaction hash as `wrapTxHash`.
- The SDK follows the wallet's account and chain changes.

## [0.2.7] - 2026-03-30

**Platforms:** TypeScript, React, CLI

### Changed

- Maintenance release with no API changes.

## [0.2.6] - 2026-03-30

**Platforms:** TypeScript, React

### Changed

- Maintenance release with no API changes.

## [0.2.5] - 2026-03-27

**Platforms:** TypeScript, React

### Added

- `logLevel` config option controls SDK console output; the default is
  `'silent'`.

## [0.2.4] - 2026-03-27

**Platforms:** TypeScript, React

### Breaking changes

- Transaction history is grouped per transaction: history calls return
  `Transaction` objects with `TransactionNote` entries, and the previous
  TypeScript `Transaction` type is renamed to `PendingTransaction`.

### Added

- Multi-chain support: `sdk.chain(config)` returns a `ChainClient` for each
  chain. **React:** `useChain()`.
- Keys are backed up to an encrypted server vault and restored on a new
  device with a single wallet signature.
- `sdk.apps` looks up app metadata, and transactions include their `appId`.
- `transactions.poll()` returns `{ pending, resolved }`.

### Changed

- Pending transactions are tracked in the shared core, so every platform
  behaves the same.
- Client-side sessions expire after 1 hour instead of 24.

### Security

- Sign-in requests that carry key material always use the encrypted
  transport.

## [0.2.3] - 2026-03-12

**Platforms:** TypeScript, React, iOS, Android, CLI

### Added

- `getDepositStatus()`, `getTransferStatus()` and `getWithdrawalStatus()`
  track a request by its `requestId`. **React:** `useDepositStatus()`,
  `useTransferStatus()` and `useWithdrawalStatus()`.
- Compliance screening: a `blocked` transaction status, the
  `COMPLIANCE_BLOCKED` error code and `isComplianceError()`.
- Token metadata (name, symbol, decimals) on token results.

### Fixed

- Queued transactions report their transaction hash once it is known.

## [0.2.2] - 2026-03-10

**Platforms:** TypeScript, React, iOS, Android, CLI

### Changed

- Maintenance release with no API changes.

## [0.2.1] - 2026-03-10

**Platforms:** TypeScript, React, iOS, Android, CLI

### Fixed

- The TypeScript and React packages install correctly from npm.

## [0.2.0] - 2026-03-10

**Platforms:** TypeScript, React, iOS, Android, CLI

First npm release, published as `@testinprod-io/privacy-boost` and
`@testinprod-io/privacy-boost-react`.

### Breaking changes

- `proverUrl` is removed from the config; the indexer URL serves both.
- Sign-in goes through a single `authenticate()` call, with an optional
  `tokenProvider` for app-issued tokens; `appId` is required.
- Identity results drop `accountId` and `ethereumAddress`; use `mpk`.
- Session export and import are removed from the web SDK. **iOS/Android:**
  the password-encrypted variants are removed; store sessions in the
  Keychain or Keystore.
- The address book (contacts) is removed.

### Added

- Configuration is auto-discovered from the server: only the server URL and
  `appId` are required, and `chainId`, the shield contract and the token
  registry are filled in on first use.
- Token and fee APIs: `getRegisteredTokens()`, `getToken()`,
  `getSupportedTokens()` and `getFees()`, with fees read from the server.
- Typed transaction validation error codes.
- Returning users skip the wallet popup at sign-in.
- `userAlias` on identity results.
- **TypeScript:** `createWalletAdapter()` and `authenticateWithWalletAdapter()`.
- Notes that can't be decrypted are flagged `isOpaque` and never selected as
  inputs.

### Fixed

- Transfers and withdrawals no longer fail on a note commitment mismatch.

## [0.1.4] - 2026-02-23

**Platforms:** iOS, Android, CLI

### Added

- Key management: keys come from a recovery phrase or a wallet signature and
  are kept in an encrypted vault that unlocks with a PIN, password, biometrics
  or passkey.
- **iOS/Android:** `KeychainDelegate` stores keys in the Keychain or Android
  Keystore.
- App-scoped sign-in with an `appId` and an auth method (app ID, client
  credentials or Privy token). **CLI:** `--app-id`, `--auth-method`,
  `--client-id` and `--client-secret`.

### Changed

- Key derivation asks the wallet for an EIP-712 signature bound to the chain
  and contract, so a signature can't be replayed on another chain.

## [0.1.3] - 2026-01-27

**Platforms:** iOS, Android, CLI

### Changed

- **CLI:** The `op-sepolia` network preset replaces `sepolia` and `mainnet`,
  with the OP Sepolia WETH address as the default.

## [0.1.2] - 2026-01-27

**Platforms:** iOS, Android, CLI

### Added

- **CLI:** `--shield-contract` and `--weth-contract` flags (or
  `PRIVACY_BOOST_SHIELD_CONTRACT` and `PRIVACY_BOOST_WETH_CONTRACT`).

### Changed

- Updated default configuration values.

## [0.1.1] - 2026-01-27

**Platforms:** iOS, Android, CLI

### Changed

- Maintenance release with no API changes.

## [0.1.0] - 2026-01-27

**Platforms:** iOS, Android, CLI

Initial release.

### Added

- Deposit tokens into the privacy pool, send private transfers (including
  batch sends), withdraw, and read shielded balances on iOS, Android and the
  CLI.
- An address book for saved recipients.
