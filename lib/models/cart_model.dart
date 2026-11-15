import 'package:flutter/foundation.dart';

class CartItem {
  final String name;
  final double price;
  final String imagePath;
  final String provider;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.provider,
    this.quantity = 1,
  });

  // Identifica el producto (mismo nombre + proveedor = mismo producto)
  String get id => '$name|$provider';
  double get total => price * quantity;
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get totalItems => _items.fold<int>(0, (sum, i) => sum + i.quantity);
  double get totalPrice => _items.fold<double>(0, (sum, i) => sum + i.total);

  void add(CartItem item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void increment(CartItem item) {
    item.quantity++;
    notifyListeners();
  }

  void decrement(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void remove(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
