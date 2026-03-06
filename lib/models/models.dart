// ============================================================
// MODELOS DE DADOS - Control Persianas Online
// ============================================================
import 'package:flutter/material.dart';

enum ProductCategory {
  rolo,
  romana,
  doubleVision,
  painel,
  horizontal25mm,
}

extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.rolo: return 'Persiana Rolô';
      case ProductCategory.romana: return 'Persiana Romana';
      case ProductCategory.doubleVision: return 'Double Vision';
      case ProductCategory.painel: return 'Cortina Painel';
      case ProductCategory.horizontal25mm: return 'Persiana Horizontal 25mm';
    }
  }

  String get shortName {
    switch (this) {
      case ProductCategory.rolo: return 'Rolô';
      case ProductCategory.romana: return 'Romana';
      case ProductCategory.doubleVision: return 'Double Vision';
      case ProductCategory.painel: return 'Painel';
      case ProductCategory.horizontal25mm: return 'Horizontal';
    }
  }

  double get maxWidth {
    switch (this) {
      case ProductCategory.rolo: return 2.50;
      case ProductCategory.romana: return 2.50;
      case ProductCategory.doubleVision: return 2.20;
      case ProductCategory.painel: return 2.89;
      case ProductCategory.horizontal25mm: return 2.50;
    }
  }

  String get imageAsset {
    switch (this) {
      case ProductCategory.rolo: return 'assets/images/rolo.jpg';
      case ProductCategory.romana: return 'assets/images/romana.jpg';
      case ProductCategory.doubleVision: return 'assets/images/double_vision.jpg';
      case ProductCategory.painel: return 'assets/images/painel.jpg';
      case ProductCategory.horizontal25mm: return 'assets/images/horizontal.jpg';
    }
  }

  String get imageNetwork {
    switch (this) {
      case ProductCategory.rolo:
        return 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80';
      case ProductCategory.romana:
        return 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80';
      case ProductCategory.doubleVision:
        return 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=600&q=80';
      case ProductCategory.painel:
        return 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=600&q=80';
      case ProductCategory.horizontal25mm:
        return 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&q=80';
    }
  }

  String get categoryDescription {
    switch (this) {
      case ProductCategory.rolo: return 'Prática e versátil para todos os ambientes';
      case ProductCategory.romana: return 'Elegância clássica com dobras uniformes';
      case ProductCategory.doubleVision: return 'Controle total de luz com dupla camada';
      case ProductCategory.painel: return 'Ideal para grandes vãos e portas de vidro';
      case ProductCategory.horizontal25mm: return 'Durável e resistente à umidade';
    }
  }

  List<String> get galleryImages {
    switch (this) {
      case ProductCategory.rolo:
        return [
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=80',
          'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=800&q=80',
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80',
        ];
      case ProductCategory.romana:
        return [
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80',
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
          'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800&q=80',
        ];
      case ProductCategory.doubleVision:
        return [
          'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800&q=80',
          'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=800&q=80',
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=80',
        ];
      case ProductCategory.painel:
        return [
          'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=800&q=80',
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80',
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=80',
        ];
      case ProductCategory.horizontal25mm:
        return [
          'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=80',
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
          'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800&q=80',
        ];
    }
  }
}

enum FabricType {
  blackout,
  screen1,
  screen3,
  screen5,
  blackoutPremium,
  translucido,
  semiBlackout,
  translucidaDV,
  aluminio25,
  manual25,
}

extension FabricTypeExtension on FabricType {
  String get displayName {
    switch (this) {
      case FabricType.blackout: return 'Blackout';
      case FabricType.screen1: return 'Tela Solar Screen 1%';
      case FabricType.screen3: return 'Tela Solar Screen 3%';
      case FabricType.screen5: return 'Tela Solar Screen 5%';
      case FabricType.blackoutPremium: return 'Blackout Premium';
      case FabricType.translucido: return 'Translúcido';
      case FabricType.semiBlackout: return 'Semi-blackout';
      case FabricType.translucidaDV: return 'Translúcida';
      case FabricType.aluminio25: return 'Alumínio 25mm';
      case FabricType.manual25: return 'Manual 25mm';
    }
  }

  String get lightBlock {
    switch (this) {
      case FabricType.blackout: return '100% bloqueio';
      case FabricType.screen1: return '99% bloqueio UV';
      case FabricType.screen3: return '97% bloqueio UV';
      case FabricType.screen5: return '95% bloqueio UV';
      case FabricType.blackoutPremium: return '100% bloqueio premium';
      case FabricType.translucido: return 'Difusor de luz';
      case FabricType.semiBlackout: return '80% bloqueio';
      case FabricType.translucidaDV: return 'Passagem de luz';
      case FabricType.aluminio25: return 'Regulável';
      case FabricType.manual25: return 'Regulável manual';
    }
  }

  String get colorHex {
    switch (this) {
      case FabricType.blackout: return '#2C2C2C';
      case FabricType.screen1: return '#4A4A4A';
      case FabricType.screen3: return '#6B6B6B';
      case FabricType.screen5: return '#8C8C8C';
      case FabricType.blackoutPremium: return '#1A1A1A';
      case FabricType.translucido: return '#F5F0E8';
      case FabricType.semiBlackout: return '#A0A0A0';
      case FabricType.translucidaDV: return '#D4C9B8';
      case FabricType.aluminio25: return '#C0C0C0';
      case FabricType.manual25: return '#B8B8B8';
    }
  }

  List<FabricColor> get availableColors {
    switch (this) {
      case FabricType.blackout:
        return [
          FabricColor('Preto', '#1A1A1A'),
          FabricColor('Chumbo', '#3A3A3A'),
          FabricColor('Cinza Escuro', '#555555'),
          FabricColor('Marrom', '#5C3D2E'),
          FabricColor('Azul Marinho', '#1A2744'),
          FabricColor('Vinho', '#6B1C2A'),
        ];
      case FabricType.blackoutPremium:
        return [
          FabricColor('Preto Ébano', '#0D0D0D'),
          FabricColor('Chumbo', '#2E2E2E'),
          FabricColor('Cinza Grafite', '#404040'),
          FabricColor('Azul Noite', '#0F1F3D'),
          FabricColor('Chocolate', '#3B2314'),
        ];
      case FabricType.translucido:
        return [
          FabricColor('Branco', '#FFFFFF'),
          FabricColor('Off-White', '#F8F4EE'),
          FabricColor('Creme', '#F0E8D5'),
          FabricColor('Bege', '#E8D9C0'),
          FabricColor('Areia', '#D9C9A8'),
          FabricColor('Linho', '#CFC0A0'),
          FabricColor('Cinza Claro', '#DCDCDC'),
          FabricColor('Azul Bebê', '#C8DCF0'),
        ];
      case FabricType.screen1:
        return [
          FabricColor('Cinza Chumbo', '#5A5A5A'),
          FabricColor('Cinza Médio', '#7A7A7A'),
          FabricColor('Areia', '#C8B89A'),
          FabricColor('Bronze', '#8C7355'),
          FabricColor('Preto Tela', '#2A2A2A'),
        ];
      case FabricType.screen3:
        return [
          FabricColor('Cinza Chumbo', '#606060'),
          FabricColor('Cinza Claro', '#909090'),
          FabricColor('Areia', '#C0A880'),
          FabricColor('Bronze', '#907055'),
          FabricColor('Branco Tela', '#E0DDD8'),
          FabricColor('Preto', '#303030'),
        ];
      case FabricType.screen5:
        return [
          FabricColor('Cinza Médio', '#787878'),
          FabricColor('Cinza Claro', '#ABABAB'),
          FabricColor('Areia Clara', '#CFC0A0'),
          FabricColor('Branco Tela', '#E8E5E0'),
          FabricColor('Prata', '#B0B0B0'),
        ];
      case FabricType.semiBlackout:
        return [
          FabricColor('Branco/Cinza', '#E0E0E0'),
          FabricColor('Bege/Areia', '#D8C8A8'),
          FabricColor('Cinza/Cinza', '#A8A8A8'),
          FabricColor('Preto/Cinza', '#484848'),
          FabricColor('Marrom/Bege', '#987060'),
        ];
      case FabricType.translucidaDV:
        return [
          FabricColor('Branco/Branco', '#F8F8F8'),
          FabricColor('Bege/Bege', '#E8D8B8'),
          FabricColor('Cinza/Branco', '#D0CCCC'),
          FabricColor('Areia/Creme', '#DDD0B0'),
        ];
      case FabricType.aluminio25:
        return [
          FabricColor('Branco', '#F5F5F5'),
          FabricColor('Off-White', '#EEEBE5'),
          FabricColor('Bege', '#E0D0B8'),
          FabricColor('Prata', '#C8C8C8'),
          FabricColor('Cinza', '#A0A0A0'),
          FabricColor('Marrom', '#8C6848'),
          FabricColor('Preto', '#282828'),
        ];
      case FabricType.manual25:
        return [
          FabricColor('Branco', '#F5F5F5'),
          FabricColor('Off-White', '#EEEAE4'),
          FabricColor('Bege', '#DDD0B5'),
          FabricColor('Prata', '#C5C5C5'),
          FabricColor('Cinza Escuro', '#606060'),
          FabricColor('Preto', '#252525'),
        ];
    }
  }
}

class FabricColor {
  final String name;
  final String hex;
  const FabricColor(this.name, this.hex);

  Color get color => Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
}

class PricingModel {
  static const Map<String, Map<FabricType, double>> prices = {
    'rolo': {
      FabricType.blackout: 219.90,
      FabricType.screen1: 240.80,
      FabricType.screen3: 227.60,
      FabricType.screen5: 219.90,
      FabricType.blackoutPremium: 280.90,
      FabricType.translucido: 219.90,
    },
    'painel': {
      FabricType.blackout: 219.90,
      FabricType.screen1: 240.80,
      FabricType.screen3: 227.60,
      FabricType.screen5: 219.90,
      FabricType.blackoutPremium: 280.90,
      FabricType.translucido: 219.90,
    },
    'romana': {
      FabricType.blackout: 299.00,
      FabricType.screen1: 316.05,
      FabricType.screen3: 306.25,
      FabricType.screen5: 299.00,
      FabricType.blackoutPremium: 377.30,
      FabricType.translucido: 299.00,
    },
    'doubleVision': {
      FabricType.semiBlackout: 429.70,
      FabricType.translucidaDV: 319.90,
    },
    'horizontal25mm': {
      FabricType.aluminio25: 199.90,
      FabricType.manual25: 270.90,
    },
  };

  static List<FabricType> getFabricsForCategory(ProductCategory category) {
    switch (category) {
      case ProductCategory.rolo:
        return [FabricType.blackout, FabricType.screen1, FabricType.screen3, FabricType.screen5, FabricType.blackoutPremium, FabricType.translucido];
      case ProductCategory.painel:
        return [FabricType.blackout, FabricType.screen1, FabricType.screen3, FabricType.screen5, FabricType.blackoutPremium, FabricType.translucido];
      case ProductCategory.romana:
        return [FabricType.blackout, FabricType.screen1, FabricType.screen3, FabricType.screen5, FabricType.blackoutPremium, FabricType.translucido];
      case ProductCategory.doubleVision:
        return [FabricType.semiBlackout, FabricType.translucidaDV];
      case ProductCategory.horizontal25mm:
        return [FabricType.aluminio25, FabricType.manual25];
    }
  }

  static double? getPricePerM2(ProductCategory category, FabricType fabric) {
    String key;
    switch (category) {
      case ProductCategory.rolo: key = 'rolo'; break;
      case ProductCategory.painel: key = 'painel'; break;
      case ProductCategory.romana: key = 'romana'; break;
      case ProductCategory.doubleVision: key = 'doubleVision'; break;
      case ProductCategory.horizontal25mm: key = 'horizontal25mm'; break;
    }
    return prices[key]?[fabric];
  }
}

enum AccessoryType {
  motorWifi,
  bando,
  barraEstabilizadora,
  guiaLateral,
}

extension AccessoryTypeExtension on AccessoryType {
  String get displayName {
    switch (this) {
      case AccessoryType.motorWifi: return 'Motor WiFi + Controle';
      case AccessoryType.bando: return 'Bandô';
      case AccessoryType.barraEstabilizadora: return 'Barra Estabilizadora';
      case AccessoryType.guiaLateral: return 'Guia Lateral';
    }
  }

  double get price {
    switch (this) {
      case AccessoryType.motorWifi: return 1297.00;
      case AccessoryType.bando: return 99.90;
      case AccessoryType.barraEstabilizadora: return 50.00;
      case AccessoryType.guiaLateral: return 140.00;
    }
  }

  String get description {
    switch (this) {
      case AccessoryType.motorWifi: return 'Automação via app smartphone';
      case AccessoryType.bando: return 'Acabamento superior da persiana';
      case AccessoryType.barraEstabilizadora: return 'Mantém a persiana alinhada';
      case AccessoryType.guiaLateral: return 'Guia nas laterais';
    }
  }

  String get icon {
    switch (this) {
      case AccessoryType.motorWifi: return '⚡';
      case AccessoryType.bando: return '🪟';
      case AccessoryType.barraEstabilizadora: return '📏';
      case AccessoryType.guiaLateral: return '↔️';
    }
  }
}

enum InstallationType {
  dentroVao,
  foraParedeVao,
  foraAteTeto,
}

extension InstallationTypeExtension on InstallationType {
  String get displayName {
    switch (this) {
      case InstallationType.dentroVao: return 'Dentro do Vão';
      case InstallationType.foraParedeVao: return 'Fora do Vão (Parede)';
      case InstallationType.foraAteTeto: return 'Fora do Vão (Até o Teto)';
    }
  }

  String get description {
    switch (this) {
      case InstallationType.dentroVao: return 'Persiana instalada dentro da moldura da janela';
      case InstallationType.foraParedeVao: return 'Persiana fixada na parede acima da janela';
      case InstallationType.foraAteTeto: return 'Persiana instalada do teto até o piso';
    }
  }

  String get measureTip {
    switch (this) {
      case InstallationType.dentroVao: return 'Meça a largura e altura internas do vão';
      case InstallationType.foraParedeVao: return 'Adicione 10cm em cada lado para melhor cobertura';
      case InstallationType.foraAteTeto: return 'Meça do teto até o piso ou soleira';
    }
  }
}

enum OrderStatus {
  pagamentoPendente,
  pagamentoAprovado,
  emProducao,
  emSeparacao,
  enviado,
  entregue,
  cancelado,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pagamentoPendente: return 'Aguardando Pagamento';
      case OrderStatus.pagamentoAprovado: return 'Pagamento Aprovado';
      case OrderStatus.emProducao: return 'Em Produção';
      case OrderStatus.emSeparacao: return 'Em Separação';
      case OrderStatus.enviado: return 'Enviado';
      case OrderStatus.entregue: return 'Entregue';
      case OrderStatus.cancelado: return 'Cancelado';
    }
  }

  String get colorHex {
    switch (this) {
      case OrderStatus.pagamentoPendente: return '#FF9800';
      case OrderStatus.pagamentoAprovado: return '#4CAF50';
      case OrderStatus.emProducao: return '#2196F3';
      case OrderStatus.emSeparacao: return '#9C27B0';
      case OrderStatus.enviado: return '#FF5722';
      case OrderStatus.entregue: return '#2E7D32';
      case OrderStatus.cancelado: return '#F44336';
    }
  }

  int get step {
    switch (this) {
      case OrderStatus.pagamentoPendente: return 0;
      case OrderStatus.pagamentoAprovado: return 1;
      case OrderStatus.emProducao: return 2;
      case OrderStatus.emSeparacao: return 3;
      case OrderStatus.enviado: return 4;
      case OrderStatus.entregue: return 5;
      case OrderStatus.cancelado: return -1;
    }
  }
}

class SimulatorConfig {
  final ProductCategory category;
  final FabricType? fabric;
  final InstallationType? installation;
  final double? width;
  final double? height;
  final List<AccessoryType> accessories;
  final String? fabricColor;

  const SimulatorConfig({
    required this.category,
    this.fabric,
    this.installation,
    this.width,
    this.height,
    this.accessories = const [],
    this.fabricColor,
  });

  static const double minArea = 1.50;
  static const double maxArea = 5.00;
  static const double maxHeight = 3.00;

  double get area {
    if (width == null || height == null) return 0;
    return width! * height!;
  }

  double get billedArea {
    final a = area;
    return a < minArea ? minArea : a;
  }

  double get basePrice {
    if (fabric == null) return 0;
    final priceM2 = PricingModel.getPricePerM2(category, fabric!);
    if (priceM2 == null) return 0;
    return billedArea * priceM2;
  }

  double get accessoriesPrice {
    return accessories.fold(0.0, (sum, acc) => sum + acc.price);
  }

  double get totalPrice => basePrice + accessoriesPrice;

  double? get pricePerM2 {
    if (fabric == null) return null;
    return PricingModel.getPricePerM2(category, fabric!);
  }

  bool get exceedsMaxArea => area > maxArea;
  bool get exceedsMaxHeight => (height ?? 0) > maxHeight;
  bool get exceedsMaxWidth => (width ?? 0) > category.maxWidth;
  bool get exceedsLimits => exceedsMaxArea || exceedsMaxHeight || exceedsMaxWidth;
  bool get shouldSuggestSplit => (width ?? 0) > 2.40;

  SimulatorConfig copyWith({
    ProductCategory? category,
    FabricType? fabric,
    InstallationType? installation,
    double? width,
    double? height,
    List<AccessoryType>? accessories,
    String? fabricColor,
  }) {
    return SimulatorConfig(
      category: category ?? this.category,
      fabric: fabric ?? this.fabric,
      installation: installation ?? this.installation,
      width: width ?? this.width,
      height: height ?? this.height,
      accessories: accessories ?? this.accessories,
      fabricColor: fabricColor ?? this.fabricColor,
    );
  }
}

class CartItem {
  final String id;
  final SimulatorConfig config;
  final int quantity;

  CartItem({
    required this.id,
    required this.config,
    this.quantity = 1,
  });

  double get totalPrice => config.totalPrice * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(id: id, config: config, quantity: quantity ?? this.quantity);
  }
}

class ShippingOption {
  final String name;
  final String carrier;
  final double price;
  final int minDays;
  final int maxDays;
  final String service;

  const ShippingOption({
    required this.name,
    required this.carrier,
    required this.price,
    required this.minDays,
    required this.maxDays,
    required this.service,
  });

  String get deliveryText => '$minDays - $maxDays dias úteis';
}

class Address {
  final String cep;
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;

  const Address({
    required this.cep,
    required this.street,
    required this.number,
    this.complement = '',
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  String get fullAddress => '$street, $number${complement.isNotEmpty ? " - $complement" : ""}, $neighborhood, $city - $state, CEP: $cep';

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      cep: json['cep'] ?? '',
      street: json['logradouro'] ?? '',
      number: json['numero'] ?? '',
      complement: json['complemento'] ?? '',
      neighborhood: json['bairro'] ?? '',
      city: json['localidade'] ?? '',
      state: json['uf'] ?? '',
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final List<CartItem> items;
  final Address address;
  final ShippingOption shipping;
  final OrderStatus status;
  final DateTime createdAt;
  final double subtotal;
  final double shippingCost;
  final String paymentMethod;
  final String? trackingCode;

  Order({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.address,
    required this.shipping,
    required this.status,
    required this.createdAt,
    required this.subtotal,
    required this.shippingCost,
    required this.paymentMethod,
    this.trackingCode,
  });

  double get total => subtotal + shippingCost;
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<Address> addresses;
  final List<Order> orders;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.addresses = const [],
    this.orders = const [],
  });
}
