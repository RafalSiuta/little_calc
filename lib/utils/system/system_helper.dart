import 'dart:io' show Platform;

enum AppSystem {
  android,
  ios,
  macos,
  windows,
  linux,
  fuchsia,
}

class SystemHelper {
  const SystemHelper._();

  static AppSystem get currentSystem {
    if (Platform.isAndroid) {
      return AppSystem.android;
    }
    if (Platform.isIOS) {
      return AppSystem.ios;
    }
    if (Platform.isMacOS) {
      return AppSystem.macos;
    }
    if (Platform.isWindows) {
      return AppSystem.windows;
    }
    if (Platform.isLinux) {
      return AppSystem.linux;
    }
    if (Platform.isFuchsia) {
      return AppSystem.fuchsia;
    }

    return AppSystem.windows;
  }

  static bool get isMobileSystem => Platform.isAndroid || Platform.isIOS;

  static bool get isDesktopSystem =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}
