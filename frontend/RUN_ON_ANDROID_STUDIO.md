# Running Future Mind Challenges in Android Studio

Follow these steps to open the project in Android Studio and run it on an emulator or device.

---

## 1. Install Flutter and Android in Android Studio

1. Open **Android Studio**.
2. Go to **File → Settings** (Windows/Linux) or **Android Studio → Settings** (macOS).
3. Open **Languages & Frameworks → Flutter**.
   - Set **Flutter SDK path** to your Flutter installation (e.g. `C:\flutter` or `/Volumes/ExternalT7/flutter`).
   - If Flutter is not listed, use **Plugins**, search for **Flutter**, install it, then set the path.
4. Open **Languages & Frameworks → Android SDK** and ensure:
   - **Android SDK** is installed.
   - At least one **Android SDK Platform** (e.g. 34) is installed.
5. Click **Apply** / **OK**.

---

## 2. Open the Flutter Project (Not Only the android/ Folder)

You must open the **Flutter project root** (the folder that contains `pubspec.yaml`), i.e. the **`frontend`** folder.

1. In Android Studio: **File → Open**.
2. Go to your project and select the **`frontend`** folder:
   - Full path example: `GCSampleTestApp/frontend`  
     (or `.../GCSampleTestApp/frontend`).
3. Click **Open**.
4. If asked “Open in New Window” or “Replace”, choose what you prefer.
5. Wait until Gradle and Flutter finish syncing (bottom status bar). If it asks to “Get dependencies” or “Pub get”, accept.

**Important:** Open `frontend`, not `GCSampleTestApp` and not `frontend/android`. Opening only `android/` will not give you Flutter Run/Debug.

---

## 3. Create an Android Virtual Device (Emulator) if Needed

1. **Tools → Device Manager** (or the phone/tablet icon in the toolbar).
2. Click **Create Device** (or “+”).
3. Pick a **Phone** (e.g. Pixel 6), click **Next**.
4. Pick a **System Image** (e.g. “Tiramisu” API 34 or “UpsideDownCake” API 34).
   - If the image is not downloaded, click **Download** next to it, then **Next**.
5. Name the AVD (or leave default), click **Finish**.
6. In Device Manager, click the **Run** (▶) button for that AVD to start the emulator. Keep it running for the next step.

---

## 4. Run the App

1. At the top of the window, use the **device dropdown** (next to the Run button) and select:
   - Your **Android Emulator** (e.g. “Pixel 6 API 34”), or  
   - A **physical Android device** (connected via USB with USB debugging enabled).
2. Click the green **Run** button (▶), or use **Run → Run 'main.dart'** (or **Shift+F10**).

The first run will：

- Run `flutter pub get` if needed  
- Build the Android app  
- Install and launch it on the selected device  

Later runs are faster.

---

## 5. If “Flutter” or “main.dart” Is Not Available

- Confirm you opened the **`frontend`** folder (the one with `pubspec.yaml` and `lib/main.dart`).
- Confirm the **Flutter** plugin is installed and the Flutter SDK path is set (step 1).
- Use **View → Tool Windows → Run** and check the run configuration: it should be **main.dart** or **Flutter**.
- If needed: **Run → Edit Configurations → + → Flutter**; set **Dart entrypoint** to `lib/main.dart` and **Working directory** to the `frontend` folder.

---

## 6. Useful Shortcuts (Android Studio)

| Action            | Shortcut (Windows/Linux) | Shortcut (macOS)   |
|------------------|--------------------------|--------------------|
| Run              | `Shift+F10`              | `Ctrl+R`           |
| Debug            | `Shift+F9`               | `Ctrl+D`           |
| Stop             | `Ctrl+F2`                 | `Cmd+F2`           |
| Hot reload       | `Ctrl+\`                  | `Cmd+\`            |
| Device Manager   | —                         | **Tools → Device Manager** |

---

## 7. Run vs Open “android” Only

| You open…           | You get…                                                                 |
|---------------------|---------------------------------------------------------------------------|
| **`frontend`**      | Full Flutter project → Run/Debug, hot reload, `main.dart`, device selector ✅ |
| **`frontend/android`** | Only the Android native project → no Flutter run, only Gradle/Android edits ⚠️ |

So to *run* the app, always open **`frontend`**.

---

## 8. Physical Android Device

1. On the phone: **Settings → Developer options** → enable **USB debugging**.
2. Connect the phone via USB.
3. Accept the “Allow USB debugging?” prompt on the phone.
4. In Android Studio’s device dropdown, your device should appear; select it and run as in step 4.

---

## Quick Checklist

- [ ] Flutter plugin installed and Flutter SDK path set in Android Studio.  
- [ ] Project opened is the **`frontend`** folder.  
- [ ] An Android emulator is created and/or a device is connected.  
- [ ] Device/emulator selected in the toolbar.  
- [ ] Green **Run** (▶) clicked to run `main.dart`.

If something fails, check the **Run** and **Build** tool windows at the bottom of Android Studio for errors.

---

## 9. AndroidManifest.xml “Unresolved class” or “Attribute not allowed” in the Problems tab

If the **Problems** tab shows errors on `AndroidManifest.xml` (e.g. “Unresolved class 'FutureMindApplication'”, “Unresolved class 'MainActivity'”, or “Attribute android:icon is not allowed here”):

1. **Use the source manifest, not Merged Manifest**  
   In the manifest editor, open the **AndroidManifest.xml** tab (not “Merged Manifest”). Some errors appear only in the merged view.

2. **Sync and refresh the IDE**  
   - **File → Sync Project with Gradle Files** (or the Gradle sync button in the toolbar).  
   - Then **File → Invalidate Caches… → Invalidate and Restart**.  
   This forces the IDE to re‑index the Android module and its Kotlin sources.

3. **Confirm project and module**  
   The project should be the **`frontend`** folder. The manifest is under `android/app/src/main/AndroidManifest.xml`. The classes `FutureMindApplication` and `MainActivity` live in `android/app/src/main/kotlin/com/greencontributor/futuremind/`. After a full sync, the IDE should resolve them.

4. **Spelling (“Typo”) only**  
   Warnings like “Typo: 'greencontributor'” or “'futuremind'” are from the spell‑checker, not the build. You can add those words to the dictionary or disable that inspection.

The app should still **build and run** with Run (▶) even if the Problems tab shows these for the manifest, as long as the Kotlin files and manifest are in the paths above. If the Run fails, use the **Build** output for the real error.
