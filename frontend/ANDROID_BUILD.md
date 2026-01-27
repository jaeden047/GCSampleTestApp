# Building the Android Version of Future Mind Challenges

This document describes how to build and run the Android app from this Flutter project. The same Dart codebase runs on **web** and **Android**; no separate “Android app” codebase exists.

---

## Prerequisites

1. **Flutter SDK**  
   - Installed and on your `PATH`.  
   - Run `flutter doctor` and fix any issues (especially “Android toolchain” and “Android Studio”).

2. **Android Studio** (or Android SDK + command-line tools)  
   - Needed for:
     - Android SDK and build tools
     - Android Emulator (for testing)
   - You do **not** need to use Android Studio as your editor; Cursor/VS Code is fine.

3. **Project directory**  
   - All commands below are run from the **project root** (the directory containing `pubspec.yaml`), i.e. `frontend/` in this repo.

---

## One-Time Setup

From the **project root** (`frontend/`):

```bash
cd /path/to/GCSampleTestApp/frontend

# 1. Get dependencies and ensure Flutter generates local/android config
flutter pub get

# 2. Confirm Android is set up
flutter doctor -v
```

If `flutter doctor` reports “Android toolchain” or “Android Studio” as missing or broken, install/configure the Android SDK and optional Android Studio, then run `flutter doctor -v` again.

---

## Running on Android (Emulator or Device)

1. **List devices**
   ```bash
   flutter devices
   ```
   Ensure an “Android” device or emulator is listed.

2. **Run the app**
   ```bash
   flutter run
   ```
   If more than one device is available, choose the Android one when prompted, or run:
   ```bash
   flutter run -d <device-id>
   ```

The app will build, install, and launch on the selected Android device/emulator. Behavior and UI (including responsiveness and decorations) match the web app.

---

## Building a Release APK

From the project root (`frontend/`):

```bash
# Single “fat” APK (all ABIs). Easiest for local install.
flutter build apk

# Output:
# build/app/outputs/flutter-apk/app-release.apk
```

To build **split APKs** (smaller, per-ABI):

```bash
flutter build apk --split-per-abi
```

Outputs:
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `build/app/outputs/flutter-apk/app-x86_64-release.apk`

Install a built APK on a connected device with:

```bash
flutter install
```

Or copy the APK to the device and open it there (with “Install from unknown sources” allowed if needed).

---

## Android Project Layout (Reference)

The Android-specific files live under `android/` and are used only when building/running for Android. They do **not** change how the web app is built or run.

```
frontend/
├── android/
│   ├── app/
│   │   ├── build.gradle           # App-level Gradle config (applicationId, minSdk, etc.)
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       ├── kotlin/com/greencontributor/futuremind/
│   │       │   └── MainActivity.kt
│   │       └── res/
│   │           ├── drawable/      # ic_launcher, launch_background
│   │           └── values/       # styles, colors
│   ├── build.gradle
│   ├── gradle.properties
│   ├── gradle/wrapper/
│   │   └── gradle-wrapper.properties
│   └── settings.gradle
├── lib/                           # Shared Dart code (web + Android)
├── web/                           # Web-only (index.html, etc.)
└── pubspec.yaml
```

- **`lib/`**: All app logic and UI. Same code for web and Android.
- **`android/`**: Android app shell (manifest, icons, themes, Gradle). Generated/updated by Flutter when needed; you only edit it for app name, icon, permissions, or Gradle/Android-specific tweaks.

---

## App Identity (Android)

- **Application ID**: `com.greencontributor.futuremind`  
- **Display name**: “Future Mind Challenges”  
- **minSdk**: 21  
- **targetSdk**: 34  

These are set in `android/app/build.gradle` and `android/app/src/main/AndroidManifest.xml`. Changing them (e.g. for a different product) is done there.

---

## Regenerating the Android Folder (Optional)

If you ever need to recreate or repair the `android/` folder from Flutter’s default template (e.g. after a Flutter upgrade), run from the **project root** (`frontend/`):

```bash
flutter create . --platforms=android
```

This overwrites or updates files under `android/`. If you’ve changed app name, application ID, or launcher icon, re-apply those changes after regenerating. Prefer fixing Gradle/Android config by hand if you understand the issue, and use this only when the official template is required.

---

## Troubleshooting

### “flutter.sdk not set in local.properties”

- Run `flutter pub get` (or any `flutter` command) from the **project root** (`frontend/`).  
- Flutter will create or update `android/local.properties` with `flutter.sdk` and `sdk.dir`.  
- Do **not** commit `local.properties`; it is machine-specific (and usually in `.gitignore`).

### “Android toolchain” or “Android licenses” errors

- Run:
  ```bash
  flutter doctor --android-licenses
  ```
- Fix any Android SDK path or license issues reported by `flutter doctor -v`.

### Gradle / build errors

- From the project root:
  ```bash
  flutter clean
  flutter pub get
  flutter build apk
  ```
- If the error points to `android/` (e.g. Gradle or plugin versions), check:
  - `android/settings.gradle` (plugin versions)
  - `android/app/build.gradle` (AGP, Kotlin, `compileSdk` / `minSdk` / `targetSdk`)

### App looks or behaves differently than on web

- The same `lib/` code is used for both. Differences usually come from:
  - Screen size / `MediaQuery` (different on phone vs desktop).  
  - Keyboard / soft input (e.g. `windowSoftInputMode` in `AndroidManifest.xml` is set to `adjustResize`).  
- If you see a specific mismatch (e.g. layout, font, or navigation), it can be tuned in shared Dart code or, if strictly Android-only, in `android/` (e.g. theme or manifest).

---

## Summary

- **Build Android**: from `frontend/`, run `flutter build apk`.  
- **Run on Android**: from `frontend/`, run `flutter run` and pick an Android device.  
- **Codebase**: one Flutter app in `lib/` for web and Android; `android/` only configures the Android build and app identity.

For more on Flutter Android builds and release signing, see:  
https://docs.flutter.dev/deployment/android
