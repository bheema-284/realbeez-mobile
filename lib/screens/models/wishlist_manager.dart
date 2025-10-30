import 'package:flutter/foundation.dart';
import 'package:real_beez/screens/models/property.dart';

class WishlistManager with ChangeNotifier {
  static final WishlistManager _instance = WishlistManager._internal();
  
  factory WishlistManager() => _instance;

  WishlistManager._internal();

  final List<Property> _wishlistItems = [];

  List<Property> get wishlist => List.unmodifiable(_wishlistItems);

  bool isInWishlist(Property property) {
    return _wishlistItems.any((p) => p.id == property.id);
  }

  void addToWishlist(Property property) {
    // Prevent duplicates using id instead of title for better accuracy
    if (!_wishlistItems.any((p) => p.id == property.id)) {
      _wishlistItems.add(property);
      notifyListeners(); // Important for UI updates
    }
  }

  void removeFromWishlist(Property property) {
    _wishlistItems.removeWhere((p) => p.id == property.id);
    notifyListeners(); // Important for UI updates
  }
}