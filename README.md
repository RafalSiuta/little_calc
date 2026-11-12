# bizcalc

Flutter calculator app. The Android application ID is
`org.firstapp.rafalsiuta.fitcalc`.

## Native desktop windows

Keep the platform runners when updating Flutter. Windows implements the
transparent, rounded Acrylic window in `windows/runner/flutter_window.cpp` and
`windows/runner/win32_window.cpp`; `windows/runner/main.cpp` sets its initial
size. macOS implements its transparent, rounded `NSVisualEffectView` window in
`macos/Runner/MainFlutterWindow.swift`. The custom minimize, width-toggle and
close icons are Flutter widgets in `lib/widgets/window/window_title_bar.dart`
and `lib/widgets/icons/window_icons.dart`. Both runners communicate with Flutter
through the `bizcalc/window` method channel. Regenerating a platform directory
without restoring these files would remove the desktop window behavior.

## Play Store release

The Java release APK uses the same application ID and is signed by the key in
`D:/DEV/FLUTTER/FLUTTER_PROJECTS/NEW 2025/sign_apps/fit_calc/fitcalcrafalsiuta.jks`.
The previous production APK has version code 12 (version name 1.1).
This Flutter project uses version `1.2.0+13`.

The Android release build reads the ignored `android/key.properties` file for
`storeFile` and `keyAlias`. Add `storePassword` and `keyPassword` to that file,
or to the ignored `notes/signing_credentials.properties` file. The latter
overrides duplicate properties in `android/key.properties`. The example file at
`android/key.properties.example` shows the required keys. Keep both password
files and the JKS out of Git. On this Windows machine, run
`./scripts/build_android_release.ps1` in PowerShell. It uses local Java 20,
synchronizes the version from `pubspec.yaml`, and creates the signed AAB.
Verify the resulting AAB and Play Console version before uploading. The current
Flutter Android build has minimum SDK 24; the old Java APK had minimum SDK 21.
