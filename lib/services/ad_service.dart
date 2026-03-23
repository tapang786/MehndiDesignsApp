import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7309558191901550/5077797040';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7309558191901550/5077797040';
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

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7309558191901550/7103659735';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7309558191901550/7103659735';
    }
    throw UnsupportedError('Unsupported platform');
  }

  static InterstitialAd? _interstitialAd;

  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      loadInterstitialAd();
    }
  }
}
