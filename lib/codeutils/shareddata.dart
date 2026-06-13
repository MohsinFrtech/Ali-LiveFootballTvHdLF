import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceResource{
  SharedPreferences? prefs;

  Future<SharedPreferences?> getSharedInstance() async {
    prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<void> saveRatingValue(bool value) async {
    // Save an boolean value to 'repeat' key.
    await prefs?.setBool('rating', value);
  }

  bool? getRatingValue(){
    final bool? ratingValue = prefs?.getBool('rating');
    return ratingValue;
  }

  ////save app opening...
  Future<void> appOpeningCount(int value) async {
    // Save an boolean value to 'repeat' key.
    await prefs?.setInt('appopen', value);
  }

  /// get app opening....
  int? getOpeningCount(){
    final int? appOpenValue = prefs?.getInt('appopen');
    return appOpenValue;
  }
}