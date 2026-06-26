# PrivacyBoost SDK

Cross-platform SDK for integrating the PrivacyBoost privacy protocol into web, mobile, and native apps. A Rust core compiled to WASM, iOS, Android, and React Native gives every platform the same crypto, key management, and protocol behavior.

## Packages

| Platform | Package | Version |
|----------|---------|---------|
| TypeScript / Web | [`@sunnyside-io/privacy-boost`](https://www.npmjs.com/package/@sunnyside-io/privacy-boost) | 1.0.5 |
| React | [`@sunnyside-io/privacy-boost-react`](https://www.npmjs.com/package/@sunnyside-io/privacy-boost-react) | 1.0.5 |
| React Native | [`@sunnyside-io/privacy-boost-react-native`](https://www.npmjs.com/package/@sunnyside-io/privacy-boost-react-native) | 1.0.5 |
| iOS (Swift) | XCFramework (release asset) | 1.0.5 |
| Android (Kotlin) | AAR (release asset) | 1.0.5 |
| CLI | Prebuilt binary | 1.0.5 |

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

Requires React Native 0.74+. The package ships prebuilt native
bindings for iOS and Android — run `pod install` in your iOS project
after installing.

### iOS (Swift) / Android (Kotlin)

For native (non-React-Native) apps, download the platform SDK from
[Releases](https://github.com/sunnyside-io/privacy-boost-sdk/releases):

| Platform | Asset |
|----------|-------|
| iOS | `PrivacyBoost-iOS.zip` (XCFramework + Swift package) |
| Android | `PrivacyBoost-Android.zip` (AAR + Kotlin bindings) |

### CLI

Download the binary for your platform from [Releases](https://github.com/sunnyside-io/privacy-boost-sdk/releases):

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
  serverUrl: 'https://indexer.example.com',
  appId: 'my-app',
});

await sdk.auth.authenticate(walletBridge);

await sdk.vault.shield({
  tokenAddress: '0x...',
  amount: 1_000_000n,
});
```

`chainId` and the shield contract address are auto-discovered from the server — no manual config needed.

### React

```tsx
import {
  PrivacyBoostProvider,
  useAuth,
  useVault,
} from '@sunnyside-io/privacy-boost-react';

function App() {
  return (
    <PrivacyBoostProvider
      config={{ serverUrl: 'https://indexer.example.com', appId: 'my-app' }}
    >
      <Wallet />
    </PrivacyBoostProvider>
  );
}

function Wallet() {
  const { isAuthenticated, authenticateWithWalletAdapter } = useAuth();
  const { shield, unshield } = useVault();
  // ...
}
```

Additional hooks: `useBalances`, `useTransactions`, `useFees`, `useRegisteredTokens`, `useShieldStatus`, `useTransferStatus`, `useUnshieldStatus`, `useChain`.

### CLI

```bash
privacy-boost --help
privacy-boost auth login --server https://indexer.example.com
privacy-boost vault shield --token 0x... --amount 1000000
```

## Compatibility

| Runtime | Minimum |
|---------|---------|
| Node.js | 18 |
| Browsers | Any with WASM + BigInt (Chrome 85+, Safari 15+, Firefox 78+) |
| React | 18 or 19 |

## Documentation

Guides and API reference: https://docs.sunnyside.io/

## Support

- Issues: https://github.com/sunnyside-io/privacy-boost-sdk/issues
- Security disclosures: `contact@sunnyside.io`
