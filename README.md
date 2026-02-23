# PrivacyBoost SDK

Cross-platform privacy boost SDK. Pre-built binaries for iOS, Android, Web, and CLI.

> **Beta**: This package is under active development.

## Installation

### TypeScript / React (npm)

Packages are published to GitHub Packages under the `@testinprod-io` scope.

**1. Install:**

```bash
# TypeScript SDK
npm install @testinprod-io/privacy-boost

# React hooks (optional)
npm install @testinprod-io/privacy-boost-react
```

**2. Usage:**

```typescript
import { PrivacyBoost } from '@testinprod-io/privacy-boost';

const sdk = new PrivacyBoost({
  indexerUrl: 'https://indexer.example.com',
  proverUrl: 'https://prover.example.com',
  chainId: 1,
});

await sdk.auth.connect(walletAdapter);
await sdk.auth.authenticate();
```

### CLI

Download the binary for your platform from [Releases](https://github.com/testinprod-io/privacy-boost-sdk/releases):

| Platform | Asset |
|----------|-------|
| Linux x64 | `privacy-boost-linux-x64.tar.gz` |
| Linux ARM64 | `privacy-boost-linux-arm64.tar.gz` |
| macOS x64 | `privacy-boost-darwin-x64.tar.gz` |
| macOS ARM64 (Apple Silicon) | `privacy-boost-darwin-arm64.tar.gz` |
| Windows x64 | `privacy-boost-windows-x64.zip` |

```bash
# Example: macOS Apple Silicon
curl -LO https://github.com/testinprod-io/privacy-boost-sdk/releases/latest/download/privacy-boost-darwin-arm64.tar.gz
tar -xzf privacy-boost-darwin-arm64.tar.gz
./privacy-boost --help
```

### iOS (Swift Package Manager)

Add this repository as a Swift package dependency:

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/testinprod-io/privacy-boost-sdk", from: "0.1.0")
]
```

Or in Xcode: **File > Add Package Dependencies** and enter:
```
https://github.com/testinprod-io/privacy-boost-sdk
```

Then import in your Swift code:
```swift
import PrivacyBoost
```

### Android

Download the latest `PrivacyBoost-Android.zip` from [Releases](https://github.com/testinprod-io/privacy-boost-sdk/releases).

**Option A: Local Gradle module**

1. Unzip and copy `PrivacyBoostSDK/` into your project root
2. Add to `settings.gradle.kts`:
   ```kotlin
   include(":PrivacyBoostSDK")
   ```
3. Add dependency in your app's `build.gradle.kts`:
   ```kotlin
   dependencies {
       implementation(project(":PrivacyBoostSDK"))
   }
   ```

**Option B: Manual integration**

1. Copy `jniLibs/` into `app/src/main/jniLibs/`
2. Copy Kotlin sources from `kotlin/` into your source tree
3. Add required dependencies:
   ```kotlin
   dependencies {
       implementation("net.java.dev.jna:jna:5.13.0@aar")
       implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
       implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
   }
   ```

## Verifying Downloads

Each release asset includes a `.sha256` checksum file:

```bash
shasum -a 256 -c privacy-boost-darwin-arm64.tar.gz.sha256
```

## Documentation

Full documentation is available at [docs.privacyboost.io](https://docs.privacyboost.io).
