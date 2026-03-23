import 'dart:io';

class AdService {
  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7309558191901550/5077797040';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7309558191901550/5077797040'; // Using the same as provided, usually they differ but user only gave one.
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7309558191901550/7542643432';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7309558191901550/7542643432';
    }
    throw UnsupportedError('Unsupported platform');
  }
}
