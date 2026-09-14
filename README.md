<div align="center">

# 🛡️ LeakLens

### **100% Air-Gapped, On-Device Credential Leak Detector & OCR Security Scanner**

*Catch secrets, API keys, private keys, and high-entropy environment variables before they hit git history — directly from your camera, clipboard, or code diffs.*

---

[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.2-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Air--Gapped-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://github.com/MoulendraBalaji/LeakLens/releases)
[![Security](https://img.shields.io/badge/Security-Zero%20Network%20Access-10B981?style=for-the-badge&logo=shield&logoColor=white)](#-air-gapped-security-architecture)
[![ML Kit](https://img.shields.io/badge/ML%20Kit-On--Device%20OCR-4285F4?style=for-the-badge&logo=google&logoColor=white)](https://developers.google.com/ml-kit)
[![Release](https://img.shields.io/badge/Release-v1.0-F43F5E?style=for-the-badge&logo=github&logoColor=white)](https://github.com/MoulendraBalaji/LeakLens/releases/tag/v1.0)

<br/>

</div>

---

## 📖 Table of Contents

- [Executive Overview](#-executive-overview)
- [Why LeakLens? (The Problem)](#-why-leaklens-the-problem)
- [Core Capabilities](#-core-capabilities)
  - [1. Optical Screen Scanner (Zero-Cloud OCR)](#1-optical-screen-scanner-zero-cloud-ocr)
  - [2. Shannon Entropy Engine](#2-shannon-entropy-engine)
  - [3. Multi-Vendor Credential Detectors](#3-multi-vendor-credential-detectors)
  - [4. Non-Destructive In-Place Redaction](#4-non-destructive-in-place-redaction)
  - [5. Plain-English Threat Analysis](#5-plain-english-threat-analysis)
- [Air-Gapped Security Architecture](#-air-gapped-security-architecture)
- [Design System & Aesthetics](#-design-system--aesthetics)
- [Technical Architecture](#-technical-architecture)
- [Supported Credential Signatures](#-supported-credential-signatures)
- [Getting Started & Installation](#-getting-started--installation)
- [Building the Release APK](#-building-the-release-apk)
- [CI/CD & GitHub Actions](#-cicd--github-actions)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Executive Overview

**LeakLens** is a mobile security utility engineered for developers, devops teams, and security researchers. It transforms any mobile camera or clipboard buffer into a real-time credential auditor.

Whether you are reviewing code on an external workstation, debugging terminal logs over a colleague's shoulder, or verifying your `.env` files before committing, **LeakLens catches hazardous credentials instantly**.

Best of all: **LeakLens operates with zero cloud dependencies and zero internet permissions**. It is physically impossible for LeakLens to exfiltrate or log your sensitive tokens.

```
┌─────────────────┐        ┌───────────────────────┐        ┌──────────────────────┐
│  Camera Capture │ ─────> │   Google ML Kit OCR   │ ─────> │                      │
│   (Laptop/CRT)  │        │  (100% Local Device)  │        │                      │
└─────────────────┘        └───────────────────────┘        │                      │
                                                            │   Scanner Engine     │
┌─────────────────┐        ┌───────────────────────┐        │  - Regex Signatures  │ ───> [ 🛡️ AUDIT REPORT ]
│ Clipboard Paste │ ─────> │ Reactive Buffer Input │ ─────> │  - Shannon Entropy   │      - Severity Levels
│ (.env / Diff)   │        │ (300ms Keystroke Deb) │        │  - Risk Explainer    │      - 1-Tap Redaction
└─────────────────┘        └───────────────────────┘        │                      │      - Mitigation Steps
                                                            └──────────────────────┘
```

---

## ⚡ Why LeakLens? (The Problem)

1. **Automated Scraping Bots**: Public GitHub commits are scraped by threat actors in under **2.4 seconds**. Once an AWS or Stripe key is committed, damage is immediate.
2. **Camera Insecurity**: Developers frequently share screenshots of terminals, error tracebacks, or configurations in Slack or Discord without realizing high-privilege bearer tokens or DB credentials are visible in the background.
3. **Cloud Auditing Risks**: Uploading proprietary code or `.env` files to cloud-based linting or scanning tools presents serious third-party compliance and supply-chain leakage concerns.

**LeakLens solves this by executing 100% of OCR and credential auditing entirely on your local silicon.**

---

## 🚀 Core Capabilities

### 1. Optical Screen Scanner (Zero-Cloud OCR)
- Point your device's camera at any physical monitor, IDE window, or terminal log.
- Utilizes Google ML Kit's Latin Script On-Device Text Recognizer.
- Features flash toggle, autofocus lock, and instant extraction pipeline.
- Automatically transfers OCR output into the interactive audit buffer for deep analysis.

### 2. Shannon Entropy Engine
Standard regex patterns fail on custom, unnamed secrets or ad-hoc API keys. LeakLens integrates a mathematical **Shannon Entropy Engine** to evaluate character distribution and randomness in `.env` pairs:

$$H(X) = -\sum_{i=1}^{n} P(x_i) \log_2 P(x_i)$$

- **Low Entropy (< 3.0 bits)**: Standard identifiers, human words, and common configs (e.g. `DEBUG=true`, `PORT=8080`) are ignored.
- **High Entropy (> 3.5 bits)**: Cryptographically generated secrets, hex digests, and random passwords trigger automated warnings.
- **Critical Entropy (> 4.2 bits)**: High-randomness cryptographic tokens are classified as `HIGH` severity.

### 3. Multi-Vendor Credential Detectors
Built-in heuristic parsers and verified regex engines specifically calibrated to recognize signatures from leading cloud and developer ecosystems:
- **Cloud Providers**: Amazon Web Services (Access Keys & Secret Keys), Google Cloud API keys.
- **Developer Platforms**: GitHub Personal Access Tokens (Classic `ghp_`, Fine-Grained `github_pat_`, OAuth `gho_`, User-to-Server `ghu_`, Refresh `ghr_`).
- **Payment Gateways**: Stripe Secret Keys (`sk_live_`), Restricted Keys (`rk_live_`), and Publishable Keys (`pk_live_`).
- **Collaboration**: Slack Bot and User tokens (`xoxb-`, `xoxp-`, `xoxa-`, `xoxr-`).
- **Database & Protocols**: PostgreSQL, MySQL, MongoDB, Redis connection URIs with embedded passwords.
- **Cryptographic Materials**: RSA, EC, DSA, and OpenSSH `-----BEGIN PRIVATE KEY-----` PEM blocks.
- **Authentication**: Signed JSON Web Tokens (JWT) and RFC 6750 Bearer Tokens.

### 4. Non-Destructive In-Place Redaction
Sharing code for debugging without leaking tokens is seamless:
- Preserves the **first 4** and **last 4** characters of the token for identification purposes.
- Replaces intermediate characters with unicode bullets (`••••••••`).
- **1-Tap "Redact All"**: Instantly generates a clean, sanitized clone of the document directly to your system clipboard, preserving indentation, comments, and spacing.

```diff
- DATABASE_URL=postgres://app_user:z9#kL2!vP0@xQ8^mC4&wR1@db.internal:5432/main
+ DATABASE_URL=postgres://app_user:z9#k•••••••••••••wR1@db.internal:5432/main

- AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
+ AWS_ACCESS_KEY_ID=AKIA••••••••••••MPLE

- STRIPE_SECRET_KEY=sk_test_51Abcdefghijklmnopqrstuvwx987654321
+ STRIPE_SECRET_KEY=sk_t••••••••••••••••••••••••••••4321
```

### 5. Plain-English Threat Analysis
Every detected secret produces an actionable security brief explaining:
- **Blast Radius**: What services an attacker can compromise with this credential.
- **Containment Guidance**: Exact vendor console steps to revoke and rotate the compromised credential.
- **Local Gemma / MediaPipe Ready**: Designed with built-in prompts for upcoming offline local LLM expansion.

---

## 🔒 Air-Gapped Security Architecture

LeakLens was intentionally constructed with a strict zero-trust posture toward internet connectivity:

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<!-- NOTE: android.permission.INTERNET is intentionally excluded.
     LeakLens is 100% on-device and air-gapped. Zero network calls guaranteed. -->
```

| Security Property | LeakLens Implementation |
|:---|:---|
| **Internet Access** | ❌ **Completely Absent** (`android.permission.INTERNET` removed from Manifest) |
| **OCR Processing** | 💻 **Local Device Only** via Google ML Kit On-Device Vision Engine |
| **Credential Analysis** | ⚙️ **In-Memory Dart Runtime** (zero disk caching of raw secrets) |
| **Telemetry / Analytics** | 🚫 **Zero Tracking** (no Firebase Analytics, no Sentry, no Crashlytics) |
| **Third-Party APIs** | 🌐 **Zero Remote Endpoints** |

---

## 🎨 Design System & Aesthetics

LeakLens utilizes a custom-built design language blending **Google Pixel's human-centric Material You** with **Apple's dynamic translucency** and **cyberpunk OLED obsidian aesthetics**:

- **Color Palette**:
  - `Background`: OLED Obsidian `#080B10`
  - `Surface Elevated`: Slate Graphite `#111622`
  - `Cyber Cyan Accent`: `#06B6D4`
  - `Safe Emerald`: `#10B981`
  - `Alert Crimson`: `#F43F5E`
  - `Solar Amber`: `#F59E0B`
- **Typography**:
  - **Headings & Body**: `Plus Jakarta Sans` (Geometric Neo-Grotesque)
  - **Code & Redacted Tokens**: `JetBrains Mono`
- **Micro-Interactions**:
  - Translucent frosted glass bottom dock with backdrop blur filters.
  - Pulsing real-time emerald beacon indicating air-gapped protection status.
  - Haptic feedback on security actions and clipboard copies.
  - Live animated severity count badges.

---

## 🏗️ Technical Architecture

```
lib/
├── dialogs/
│   └── trust_dialog.dart        # Air-Gapped guarantee & security modal sheet
├── models/
│   └── finding.dart             # Credential finding model, severity enum, and redaction logic
├── screens/
│   ├── camera_scan_screen.dart  # Camera viewfinder, flash control & ML Kit OCR pipeline
│   ├── home_screen.dart         # Scaffold host with floating navigation dock & PageView
│   └── paste_scan_screen.dart   # Interactive text editor, debounced audit, and preset samples
├── services/
│   ├── ocr_service.dart         # Google ML Kit on-device text recognition wrapper
│   ├── risk_explainer_service.dart # Blast radius & mitigation advice generator
│   └── scanner_service.dart     # Regex matching, Shannon entropy, & redaction generator
├── theme/
│   └── terminal_theme.dart      # OLED theme, typography system, and color tokens
└── widgets/
    ├── finding_card.dart        # Expandable finding card with severity pill and mitigation
    ├── floating_nav_bar.dart    # Translucent glassmorphic floating dock
    ├── status_banner.dart       # Reactive "Safe to Push" / alert header with counters
    └── terminal_app_bar.dart    # App bar with pulsing air-gapped beacon & brand mark
```

---

## 📋 Supported Credential Signatures

| Provider / Type | Detection Pattern | Severity | Blast Radius |
|:---|:---|:---:|:---|
| **AWS Access Key ID** | `\bAKIA[0-9A-Z]{16}\b` | `HIGH` | Rogue EC2 provisioning, S3 exfiltration, IAM escalation |
| **AWS Secret Access Key** | Labeled 40-char Base64 Key | `HIGH` | Root / programmatic AWS infrastructure access |
| **GitHub Tokens** | `ghp_`, `github_pat_`, `gho_`, `ghu_` | `HIGH` | Source code theft, CI/CD pipeline supply-chain attack |
| **Google API Key** | `\bAIza[0-9A-Za-z\-_]{34,35}\b` | `HIGH` | Cloud API billing abuse, Firebase database compromise |
| **Stripe Secret Key** | `sk_live_[0-9a-zA-Z]{24,99}` | `HIGH` | Merchant funds draining, customer billing exfiltration |
| **Stripe Publishable** | `pk_live_[0-9a-zA-Z]{24,99}` | `MEDIUM` | Public API scope, frontend customer session tagging |
| **Slack Token** | `xox[baprs]-[0-9a-zA-Z]{10,48}` | `HIGH` | Workspace chat exfiltration, bot webhook impersonation |
| **Private Keys (PEM)** | `-----BEGIN * PRIVATE KEY-----` | `HIGH` | SSH root server access, TLS traffic decryption |
| **Database URIs** | `postgres://`, `mysql://`, `mongodb://` | `HIGH` | Direct production database read/write access |
| **JSON Web Token** | `eyJ...eyJ...` 3-part Base64URL | `HIGH` | User session hijacking, unauthorized API impersonation |
| **Bearer Tokens** | `Bearer [a-zA-Z0-9_\-\.]{24,}` | `HIGH` | Direct HTTP authentication bypass |
| **High-Entropy Secret** | Shannon Entropy $H > 3.5$ on sensitive keys | `MED/HIGH`| Custom generated secrets, master passwords, salts |

---

## 🛠️ Getting Started & Installation

### Prerequisites
- **Flutter SDK**: `^3.13.2` or later (tested on Flutter 3.47.2)
- **Dart SDK**: `^3.13.2`
- **Android SDK**: API level 21 (Lollipop) or higher (compileSdk: 37)
- **Physical Device**: Required for testing camera OCR capabilities

### Local Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/MoulendraBalaji/LeakLens.git
   cd LeakLens
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify code quality & run automated test suite**:
   ```bash
   flutter analyze
   flutter test
   ```

4. **Launch on an Android device or emulator**:
   ```bash
   flutter run
   ```

---

## 📦 Building the Release APK

To build a standalone, signed production Android APK:

```bash
# Clean previous builds
flutter clean
flutter pub get

# Compile optimized release APK
flutter build apk --release
```

The compiled APK will be output to:
```
build/app/outputs/flutter-apk/app-release.apk
```

You can install it directly onto your connected Android device using:
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## 🤖 CI/CD & GitHub Actions

LeakLens includes an automated CI/CD pipeline configured at `.github/workflows/build-and-release.yml`:

- **Static Analysis**: Runs `flutter analyze` on every commit and pull request.
- **Unit Testing**: Runs complete test suite with coverage checks.
- **Automated Android Build**: Compiles release APK artifact on Ubuntu runners.
- **Automated Releases**: Whenever a git tag matching `v*` (e.g. `v1.0`) is pushed, the workflow automatically publishes a GitHub Release and attaches the compiled `.apk` binary.

---

## 🏷️ v1.0 Release

You can download the pre-compiled production Android APK directly from the GitHub Releases section:

👉 **[Download LeakLens v1.0 APK](https://github.com/MoulendraBalaji/LeakLens/releases/tag/v1.0)**

---

## 👥 Authors

Developed by:
- **[Moulendra Balaji](https://github.com/MoulendraBalaji)**
- **[Shashvat Reddy](https://github.com/pshashvatreddy)**

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
