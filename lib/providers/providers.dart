import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

// ============================================================
// PRODUCT DETAILS PROVIDER
// Armazena textos editáveis dos produtos para sincronizar
// o Painel Admin com a tela de Detalhes do Produto.
// ============================================================
class ProductDetailsProvider extends ChangeNotifier {

  // ── Taglines ─────────────────────────────────────────────
  final Map<ProductCategory, String> _taglines = {
    ProductCategory.rolo:           'Prática e versátil para todos os ambientes',
    ProductCategory.romana:         'Elegância clássica com dobras uniformes',
    ProductCategory.doubleVision:   'Controle total de luz com dupla camada',
    ProductCategory.painel:         'Ideal para grandes vãos e portas de vidro',
    ProductCategory.horizontal25mm: 'Durável e resistente à umidade',
  };

  // ── Descrições completas ──────────────────────────────────
  final Map<ProductCategory, String> _descriptions = {
    ProductCategory.rolo:
        'A Persiana Rolô é a escolha mais popular para ambientes modernos e práticos. '
        'Com acionamento por corrente ou motor elétrico, ela permite controle total da '
        'luminosidade com um único movimento. O tecido é enrolado em um tubo de alumínio '
        'com acabamento impecável, sem acúmulo de poeira. Ideal para escritórios, salas, quartos e cozinhas.',
    ProductCategory.romana:
        'A Persiana Romana é sinônimo de elegância e sofisticação. Com dobras harmoniosas '
        'que se formam ao abrir, ela confere charme e personalidade ao ambiente. '
        'O tecido estruturado cai em pregas perfeitas, valorizando janelas e porta-janelas. '
        'Fabricamos com varetas de alumínio internas para manter o formato impecável.',
    ProductCategory.doubleVision:
        'A Double Vision combina duas camadas de tecido translúcida e opaca que deslizam '
        'uma sobre a outra, permitindo regular a entrada de luz com precisão. '
        'É a persiana mais versátil do mercado: filtra a luz do dia sem escurecer totalmente '
        'ou bloqueia completamente quando necessário. Design clean e moderno.',
    ProductCategory.painel:
        'A Cortina Painel é a solução ideal para grandes vãos, porta-sacadas e janelas '
        'panorâmicas. Os painéis deslizam lateralmente em trilho de alumínio de forma '
        'suave e silenciosa. Permite combinar diferentes tecidos e cores no mesmo trilho, '
        'criando efeito decorativo único.',
    ProductCategory.horizontal25mm:
        'A Persiana Horizontal 25mm é fabricada em lâminas de alumínio de alta resistência, '
        'perfeita para ambientes com alta umidade como cozinhas e banheiros. '
        'As lâminas giram 180° para controle total de privacidade e luminosidade. '
        'Muito durável, fácil de limpar e com vida útil superior a 10 anos.',
  };

  // ── Vantagens (lista por linha) ───────────────────────────
  final Map<ProductCategory, String> _advantages = {
    ProductCategory.rolo:
        'Acionamento por corrente ou motor\nDesign clean e minimalista\nFácil limpeza com pano úmido\nDisponível em blackout e screen solar\nTravamento automático em qualquer posição',
    ProductCategory.romana:
        'Dobras harmoniosas e elegantes\nVaretas internas de alumínio\nTecido estruturado de alta qualidade\nAcionamento por corrente\nPerfeita para salas e quartos',
    ProductCategory.doubleVision:
        'Dupla camada translúcida + opaca\nRegulagem precisa de luminosidade\nSem visibilidade externa à noite\nMecanismo de travamento suave\nLimpeza prática sem desmontar',
    ProductCategory.painel:
        'Ideal para grandes vãos\nTrilho de alumínio silencioso\nCombina diferentes tecidos\nSubstituição de painéis individual\nModerno e decorativo',
    ProductCategory.horizontal25mm:
        'Lâminas de alumínio 25mm\nResistente à umidade e vapor\nGiro 180° de privacidade total\nFácil limpeza com pano\nVida útil superior a 10 anos',
  };

  // ── WhatsApp editável ─────────────────────────────────────
  String _whatsappNumber = '5561981276447';

  // ── Getters ───────────────────────────────────────────────
  String getTagline(ProductCategory cat) => _taglines[cat] ?? '';
  String getDescription(ProductCategory cat) => _descriptions[cat] ?? '';
  String getAdvantages(ProductCategory cat) => _advantages[cat] ?? '';
  String get whatsappNumber => _whatsappNumber;

  /// Retorna a lista de vantagens como List<String> (para uso no ProductDetailScreen)
  List<String> getAdvantagesList(ProductCategory cat) {
    final raw = _advantages[cat] ?? '';
    return raw
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .map((l) => '✓ ${l.trim()}')
        .toList();
  }

  // ── Setters ───────────────────────────────────────────────
  void setTagline(ProductCategory cat, String value) {
    _taglines[cat] = value;
    notifyListeners();
  }

  void setDescription(ProductCategory cat, String value) {
    _descriptions[cat] = value;
    notifyListeners();
  }

  void setAdvantages(ProductCategory cat, String value) {
    _advantages[cat] = value;
    notifyListeners();
  }

  void setWhatsappNumber(String value) {
    _whatsappNumber = value.replaceAll(RegExp(r'\D'), '');
    notifyListeners();
  }
}

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

  void setCommandSide(CommandSide side) {
    _config = _config.copyWith(commandSide: side);
    notifyListeners();
  }

  void toggleAccessory(AccessoryType accessory) {    final current = List<AccessoryType>.from(_config.accessories);
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

  /// Retorna true se o usuário logado é o administrador
  bool get isAdmin =>
      _isLoggedIn && _user != null && AuthService.isAdmin(_user!.email);

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
