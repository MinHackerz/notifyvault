# NotifyVault 🛡️

A secure, privacy-focused notification history capture, management, and categorization assistant. Designed with premium visual aesthetics and optimized for smooth, lightning-fast performance.

---

## ✨ Features

- 🎨 **Latch-Inspired Visual Design:** Minimalist editorial typography, curated off-white canvas layouts, elegant brand colors, and clean boundaries without distracting drop-shadows or gradients.
- 🎨 **Illustrative Key-Bell Branding:** High-resolution custom branding combining a security vault key and a ringing alert bell.
- ⚡ **Buttery Smooth Scroll:** Optimized flat list sliver rendering architecture for liquid-smooth 60fps/120fps list scrolling.
- 📱 **Native App Icons:** Dynamically fetches and displays actual app logos (e.g. WhatsApp, Gmail, Slack, banking apps) from captured notifications on disk.
- 🔍 **Search Query Builder:** Advanced debounced search combined with active filter chips to let you query keywords specifically under selected categories or read/unread status.
- 📅 **Interactive Timeline Filters:** Tap the filter icon on the timeline to filter alerts dynamically by read status or category.
- 📂 **16 Smart Categories:** Real-time automatic classification (OTP, Banking, Payments, Messages, Work, Government, Health, Spam, etc.) using packet identifiers and title keywords.
- 🔥 **Firebase Integration:** Robust cloud sync and authentication support using Google Sign-In and Cloud Firestore.

---

## 🛠️ Tech Stack

- **Framework:** Flutter (Android & iOS)
- **Database:** Drift (SQLite) for ultra-fast, local, reactive persistence
- **State Management:** Riverpod 2.x (class-based Notifiers)
- **Cloud Backend:** Google Firebase (Auth, Firestore, Analytics)
- **Icons:** HugeIcons (Outlined/Stroke variant)
- **Styling:** Vanilla CSS-equivalent Material Design 3 tokens

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (v3.19.0 or higher recommended)
- Android Studio / VS Code
- Firebase CLI (for cloud sync features)

### Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/MinHackerz/notifyvault.git
   cd notifyvault
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Link your Firebase Project:**
   - Create a project in the [Firebase Console](https://console.firebase.google.com/).
   - Register your Android app with package ID `com.notifyvault.app`.
   - Extract your local debug keystore SHA-1 fingerprint:
     ```bash
     keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android
     ```
   - Add the SHA-1 to your Firebase project settings (required for Google Sign-In).
   - Download `google-services.json` and place it in `android/app/google-services.json`.

4. **Run the App in Debug Mode:**
   ```bash
   flutter run
   ```

---

## 📦 Production Build

To build an optimized, tree-shaken, and minified production APK:

```bash
flutter build apk --release --split-per-abi
```

The resulting standalone binaries will be located under `build/app/outputs/flutter-apk/` and will average only **~24 MB**!

---

## 🛡️ License

This project is licensed under the MIT License.
