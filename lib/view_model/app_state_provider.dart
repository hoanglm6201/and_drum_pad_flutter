import 'package:and_drum_pad_flutter/view_model/ads_provider.dart';
import 'package:and_drum_pad_flutter/view_model/purchase_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider with ChangeNotifier {
  AdsProvider adsProvider;
  PurchaseProvider purchaseProvider;
  bool _isFirstOpenApp = false;


  bool get isFirstOpenApp => _isFirstOpenApp;
  bool get shouldShowAds => adsProvider.adsEnabled && !purchaseProvider.isSubscribed;

  AppStateProvider(this.adsProvider, this.purchaseProvider) {
    getFirstOpenApp().then((value) {
      _isFirstOpenApp = value;
      notifyListeners();
      // purchaseProvider.loadSubscription().then((_) {
      //   initializeAds();
      // });
      //
      // if (_isFirstOpenApp) {
      //   AnalyticsTracker.trackInstallEvent();
      // }
    });
  }

  DateTime? _lastAdTime;
  bool _isLoading = false;

  DateTime? get lastAdTime => _lastAdTime;
  bool get isLoading => _isLoading;

  void setLastAdTime(DateTime? dateTime){
    _lastAdTime = dateTime;
    notifyListeners();
  }

  void setIsLoading(bool isLoading){
    _isLoading = isLoading;
    notifyListeners();
  }

  void updateDependencies(AdsProvider adsProvider, PurchaseProvider purchaseProvider) {
    adsProvider = adsProvider;
    purchaseProvider = purchaseProvider;
    notifyListeners();
  }

  void updateAdsState(bool isEnabled) {
    adsProvider.updateAdsState(isEnabled);
    notifyListeners();
  }

  void togglePurchase() {
    // purchaseProvider.togglePurchase();
    notifyListeners();
  }

  void initializeAds() {
    // AdController.shared.initialize(
    //   isAdDisabled: !shouldShowAds,
    //   configurations: getAdConfigurations(_isFirstOpenApp),
    //   adjustConfig: AdjustConfig("s7auhvppayv4", AdjustEnvironment.production),
    // );
  }

  Future<bool> getFirstOpenApp() async {
    final prefs = await SharedPreferences.getInstance();
    bool? savedValue = prefs.getBool('isFirstTime');
    return savedValue ?? true;
  }

  Future<void> setFirstOpenApp() async {
    _isFirstOpenApp = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }
}