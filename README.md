# PrivacyBoost SDK

Cross-platform SDK for integrating the PrivacyBoost privacy protocol into web, mobile, and native apps. A Rust core compiled to WASM, iOS, Android, and React Native gives every platform the same crypto, key management, and protocol behavior.

## Packages

| Platform | Package | Version |
|----------|---------|---------|
| TypeScript / Web | [`@sunnyside-io/privacy-boost`](https://www.npmjs.com/package/@sunnyside-io/privacy-boost) | 1.0.0 |
| React | [`@sunnyside-io/privacy-boost-react`](https://www.npmjs.com/package/@sunnyside-io/privacy-boost-react) | 1.0.0 |
| CLI | Prebuilt binary | 1.0.0 |

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
