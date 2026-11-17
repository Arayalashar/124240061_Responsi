import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../model/product.dart';

class DatabaseService {
  static late Box userBox;
  static late Box wishlistBox;
  static late Box sessionBox;

  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  static Future<void> init() async {
    userBox = await Hive.openBox('users');
    wishlistBox = await Hive.openBox('wishlist');
    sessionBox = await Hive.openBox('session');
  }

  static bool isLoggedIn() {
    return sessionBox.get('loginData', defaultValue: false) == true;
  }

  static String getSessionUsername() {
    return sessionBox.get('username', defaultValue: '') ?? '';
  }

  static void setSession(String username) {
    sessionBox.put('loginData', true);
    sessionBox.put('username', username);
  }

  static void clearSession() {
    sessionBox.put('loginData', false);
    sessionBox.delete('username');
  }

  static bool login(String username, String password) {
    final userData = userBox.get(username.trim());
    if (userData == null) return false;

    final hashedPassword = hashPassword(password.trim());
    return userData['password'] == hashedPassword;
  }

  static bool register(String username, String password) {
    final u = username.trim();
    if (userBox.containsKey(u)) return false;

    userBox.put(u, {
      'username': u,
      'password': hashPassword(password.trim()),
    });
    return true;
  }

  static String _makeKey(String username, int productId) {
    return '${username}_$productId';
  }

  static bool isWishlist(String username, int productId) {
    return wishlistBox.containsKey(_makeKey(username, productId));
  }

  static void addWishlist(String username, Product product) {
    wishlistBox.put(_makeKey(username, product.id), product.toJson());
  }

  static void removeWishlist(String username, int productId) {
    wishlistBox.delete(_makeKey(username, productId));
  }

  static List<Product> getWishlist(String username) {
    List<Product> list = [];
    for (var key in wishlistBox.keys) {
      if (key.toString().startsWith('${username}_')) {
        final data = wishlistBox.get(key);
        if (data != null) {
          list.add(Product.fromJson(Map<String, dynamic>.from(data)));
        }
      }
    }
    return list;
  }
}
