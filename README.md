# PrivacyBoost SDK

Cross-platform SDK for integrating the PrivacyBoost privacy protocol into web, mobile, and native apps. A Rust core compiled to WASM, iOS, Android, and React Native gives every platform the same crypto, key management, and protocol behavior.

This repository publishes the SDK's builds: the Swift package, the iOS and Android archives, and the CLI binaries. The JavaScript packages are on npm. Every version's changes are in [CHANGELOG.md](CHANGELOG.md).

## Packages

| Platform | Package | Version |
|----------|---------|---------|
| TypeScript / Web | [`@sunnyside-io/privacy-boost`](https://www.npmjs.com/package/@sunnyside-io/privacy-boost) | 1.3.1 |
| React | [`@sunnyside-io/privacy-boost-react`](https://www.npmjs.com/package/@sunnyside-io/privacy-boost-react) | 1.3.1 |
| React Native | [`@sunnyside-io/privacy-boost-react-native`](https://www.npmjs.com/package/@sunnyside-io/privacy-boost-react-native) | 1.3.1 |
| iOS (Swift) | Swift package in this repository, or `PrivacyBoost-iOS.zip` | 1.3.1 |
| Android (Kotlin) | `PrivacyBoost-Android.zip` | 1.3.1 |
| CLI | Prebuilt binaries | 1.3.1 |

All platforms share one version line, but a release can ship only some of them, so their latest versions can differ. Prereleases are published to npm under the `beta` dist-tag and marked as pre-releases here.

## Install

### TypeScript / Web

```bash
npm install @sunnyside-io/privacy-boost
```

### React

```bash
npm install @sunnyside-io/privacy-boost-react @sunnyside-io/privacy-boost
```

Requires React 18 or 19.

### React Native

```bash
npm install @sunnyside-io/privacy-boost-react-native
```

Requires React Native 0.74+. The package ships prebuilt native bindings for iOS and Android; run `pod install` in your iOS project after installing.

### iOS (Swift Package Manager)

In Xcode, choose **File → Add Package Dependencies…**, enter `https://github.com/sunnyside-io/privacy-boost-sdk`, and pick **Up to Next Major Version** from 1.3.1. Or add it to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sunnyside-io/privacy-boost-sdk", from: "1.3.1"),
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "PrivacyBoost", package: "privacy-boost-sdk"),
            // Optional: default Keychain and passkey delegates.
            .product(name: "PrivacyBoostDefaults", package: "privacy-boost-sdk"),
        ]
    ),
]
```

Requires iOS 16+ or macOS 13+ and Swift 5.7+. iOS releases up to 1.3.0 can't be resolved by version with Swift Package Manager; for those, use `PrivacyBoost-iOS.zip` from their release.

### iOS / Android archives

Each native release attaches:

| Platform | Asset |
|----------|-------|
| iOS | `PrivacyBoost-iOS.zip` (XCFramework and Swift sources) |
| Android | `PrivacyBoost-Android.zip` (AAR and Kotlin bindings) |

### CLI

```bash
# macOS (Apple Silicon); see the table below for other platforms
curl -L https://github.com/sunnyside-io/privacy-boost-sdk/releases/latest/download/privacy-boost-darwin-arm64.tar.gz | tar xz
sudo mv privacy-boost /usr/local/bin/
```

| Platform | Asset |
|----------|-------|
| Linux x64 | `privacy-boost-linux-x64.tar.gz` |
| Linux ARM64 | `privacy-boost-linux-arm64.tar.gz` |
| macOS x64 | `privacy-boost-darwin-x64.tar.gz` |
| macOS ARM64 (Apple Silicon) | `privacy-boost-darwin-arm64.tar.gz` |
| Windows x64 | `privacy-boost-windows-x64.zip` |

### Verifying downloads

Every release asset ships with a matching `.sha256` checksum file:

```bash
shasum -a 256 -c privacy-boost-darwin-arm64.tar.gz.sha256
```

## Quick start

### TypeScript

```typescript
import { PrivacyBoost } from '@sunnyside-io/privacy-boost';

const sdk = await PrivacyBoost.create({
  serverUrl: 'https://optimism.sepolia.privacyboost.io',
  appId: 'my-app',
});

// Call signIn() on every page load. A returning user signs nothing.
const outcome = await sdk.auth.signIn(walletAdapter);
if (outcome.status === 'setupRequired') {
  // A new account: show outcome.setup.mnemonic to the user, then create it.
  await outcome.setup.complete();
}

await sdk.vault.shield({ tokenAddress: '0x...', amount: 1_000_000n });
```

`walletAdapter` connects the user's wallet; see [Authentication](https://docs.privacyboost.io/sdk/concepts/authentication). `chainId` and the shield contract address are discovered from the server.

### React

```tsx
import { PrivacyBoostProvider, useAuth, useVault } from '@sunnyside-io/privacy-boost-react';

function App() {
  return (
    <PrivacyBoostProvider config={{ serverUrl: 'https://optimism.sepolia.privacyboost.io', appId: 'my-app' }}>
      <Wallet />
    </PrivacyBoostProvider>
  );
}

function Wallet() {
  const { status, privacyAddress, signInWithWalletAdapter } = useAuth();
  const { shield, send, unshield } = useVault();

  if (status === 'disconnected' || status === 'connected') {
    return <button onClick={() => signInWithWalletAdapter()}>Connect wallet</button>;
  }
  return <p>Privacy address: {privacyAddress}</p>;
}
```

### CLI

```bash
privacy-boost login --network op-sepolia
privacy-boost balances
privacy-boost shield --token 0x... --amount 1.0 --human
```

## Compatibility

| Runtime | Minimum |
|---------|---------|
| Node.js | 18 |
| Browsers | Any with WASM + BigInt (Chrome 85+, Safari 15+, Firefox 78+) |
| React | 18 or 19 |
| React Native | 0.74 |
| iOS / macOS | 16 / 13 |

## Documentation

Guides and API reference: https://docs.privacyboost.io

## Support

- Issues: https://github.com/sunnyside-io/privacy-boost-sdk/issues
- Security: see [SECURITY.md](SECURITY.md). Please don't report vulnerabilities in public issues.
