import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  static SharedPreferences? prefs;

  static Future<void> init() async {
    if(prefs != null){
      return; 
    }

    prefs = await SharedPreferences.getInstance();
  }

  static void saveWishlist(String wishlist) {
    prefs!.setString("wishlist", wishlist);
  }

  static String? getWishlist() {
    return prefs!.getString("wishlist");
  }
}