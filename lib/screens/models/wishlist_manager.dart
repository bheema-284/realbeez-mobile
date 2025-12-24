import 'package:flutter/foundation.dart';
import 'package:real_beez/screens/models/property.dart';

class WishlistManager with ChangeNotifier {
  static final WishlistManager _instance = WishlistManager._internal();

  factory WishlistManager() => _instance;

  WishlistManager._internal();

  final List<Property> _wishlistItems = [];

  /// Read-only wishlist
  List<Property> get wishlist => List.unmodifiable(_wishlistItems);

  /// ✅ Preferred method (used in UI)
  bool isWishlisted(Property property) {
    return _wishlistItems.any((p) => p.id == property.id);
  }

  /// 🔁 Backward compatibility (if used elsewhere)
  bool isInWishlist(Property property) {
    return isWishlisted(property);
  }

  /// ✅ Add only if not already present
  void addToWishlist(Property property) {
    if (!isWishlisted(property)) {
      _wishlistItems.add(property);
      notifyListeners();
    }
  }

  /// ✅ Remove by ID
  void removeFromWishlist(Property property) {
    _wishlistItems.removeWhere((p) => p.id == property.id);
    notifyListeners();
  }

  /// (Optional) Clear all wishlist items
  void clearWishlist() {
    _wishlistItems.clear();
    notifyListeners();
  }
}
