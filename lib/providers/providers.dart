import 'package:flutter/foundation.dart';
import '../models/models.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  void addItem(SimulatorConfig config) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _items.add(CartItem(id: id, config: config));
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void updateQuantity(String id, int quantity) {
    final idx = _items.indexWhere((item) => item.id == id);
    if (idx >= 0) {
      if (quantity <= 0) {
        _items.removeAt(idx);
      } else {
        _items[idx] = _items[idx].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class SimulatorProvider extends ChangeNotifier {
  SimulatorConfig _config = const SimulatorConfig(category: ProductCategory.rolo);
  int _currentStep = 0;

  SimulatorConfig get config => _config;
  int get currentStep => _currentStep;

  void setCategory(ProductCategory category) {
    _config = SimulatorConfig(category: category);
    notifyListeners();
  }

  void setFabric(FabricType fabric) {
    _config = _config.copyWith(fabric: fabric, fabricColor: null);
    notifyListeners();
  }

  void setFabricColor(String colorName) {
    _config = _config.copyWith(fabricColor: colorName);
    notifyListeners();
  }

  void setInstallation(InstallationType installation) {
    _config = _config.copyWith(installation: installation);
    notifyListeners();
  }

  void setWidth(double width) {
    _config = _config.copyWith(width: width);
    notifyListeners();
  }

  void setHeight(double height) {
    _config = _config.copyWith(height: height);
    notifyListeners();
  }

  void toggleAccessory(AccessoryType accessory) {
    final current = List<AccessoryType>.from(_config.accessories);
    if (current.contains(accessory)) {
      current.remove(accessory);
    } else {
      current.add(accessory);
    }
    _config = _config.copyWith(accessories: current);
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    _currentStep++;
    notifyListeners();
  }

  void prevStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void reset() {
    _config = const SimulatorConfig(category: ProductCategory.rolo);
    _currentStep = 0;
    notifyListeners();
  }
}

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  void login(UserModel user) {
    _user = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  void setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  void addOrder(Order order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void updateStatus(String orderId, OrderStatus status) {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      final o = _orders[idx];
      _orders[idx] = Order(
        id: o.id,
        orderNumber: o.orderNumber,
        items: o.items,
        address: o.address,
        shipping: o.shipping,
        status: status,
        createdAt: o.createdAt,
        subtotal: o.subtotal,
        shippingCost: o.shippingCost,
        paymentMethod: o.paymentMethod,
        trackingCode: o.trackingCode,
      );
      notifyListeners();
    }
  }
}
