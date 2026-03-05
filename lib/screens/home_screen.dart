import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart' as badges;
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/common_widgets.dart';
import 'simulator_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'account_screen.dart';
import 'environment_simulator_screen.dart' as env_sim;
import '../services/services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const SimulatorScreen(),
    const CartScreen(),
    const AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: const Offset(0, -4)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Início'),
            const BottomNavigationBarItem(icon: Icon(Icons.category_outlined), activeIcon: Icon(Icons.category), label: 'Produtos'),
            const BottomNavigationBarItem(icon: Icon(Icons.straighten_outlined), activeIcon: Icon(Icons.straighten), label: 'Simulador'),
            BottomNavigationBarItem(
              icon: badges.Badge(
                showBadge: cart.totalQuantity > 0,
                badgeContent: Text('${cart.totalQuantity}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              activeIcon: badges.Badge(
                showBadge: cart.totalQuantity > 0,
                badgeContent: Text('${cart.totalQuantity}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                child: const Icon(Icons.shopping_cart),
              ),
              label: 'Carrinho',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person_outlined), activeIcon: Icon(Icons.person), label: 'Conta'),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildHeroBanner()),
          SliverToBoxAdapter(child: _buildQuickActions()),
          SliverToBoxAdapter(child: _buildCategories()),
          SliverToBoxAdapter(child: _buildFeaturedProducts()),
          SliverToBoxAdapter(child: _buildHowItWorks()),
          SliverToBoxAdapter(child: _buildWhyChooseUs()),
          SliverToBoxAdapter(child: _buildBanner()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      snap: true,
      backgroundColor: AppColors.primary,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.blinds, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Control Persianas', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text('Sob medida para você', style: TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () => _showSearch()),
        IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
        const SizedBox(width: 4),
      ],
    );
  }

  void _showSearch() {
    showSearch(context: context, delegate: _ProductSearchDelegate());
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 220,
      margin: const EdgeInsets.all(16),
      child: PageView(
        children: [
          _HeroBannerItem(
            title: 'Persianas\nSob Medida',
            subtitle: 'Simule no seu ambiente',
            ctaLabel: 'Simular Agora',
            gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)]),
            imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SimulatorScreen())),
          ),
          _HeroBannerItem(
            title: 'Double Vision\nExclusivo',
            subtitle: 'Controle de luminosidade',
            ctaLabel: 'Ver Produtos',
            gradient: const LinearGradient(colors: [Color(0xFF1A237E), Color(0xFF283593)]),
            imageUrl: 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=600',
            onTap: () {},
          ),
          _HeroBannerItem(
            title: 'Tela Solar\nScreen',
            subtitle: 'Proteção UV premium',
            ctaLabel: 'Comprar',
            gradient: const LinearGradient(colors: [Color(0xFF0277BD), Color(0xFF01579B)]),
            imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.straighten, 'label': 'Simular\nMedidas', 'color': AppColors.primary},
      {'icon': Icons.camera_alt, 'label': 'Foto do\nAmbiente', 'color': const Color(0xFF00796B)},
      {'icon': Icons.local_shipping_outlined, 'label': 'Calcular\nFrete', 'color': const Color(0xFFE65100)},
      {'icon': Icons.support_agent, 'label': 'Falar com\nEspecialista', 'color': const Color(0xFF6A1B9A)},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: actions.map((a) {
          return Expanded(
            child: GestureDetector(
              onTap: () => _handleQuickAction(a['label'] as String),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
                ),
                child: Column(
                  children: [
                    Icon(a['icon'] as IconData, color: a['color'] as Color, size: 24),
                    const SizedBox(height: 6),
                    Text(
                      a['label'] as String,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.grey700),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleQuickAction(String label) {
    if (label.contains('Simular')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SimulatorScreen()));
    } else if (label.contains('Foto')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const env_sim.EnvironmentSimulatorScreen()));
    } else if (label.contains('Frete')) {
      _showShippingCalculator();
    } else {
      _contactWhatsApp();
    }
  }

  void _showShippingCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const ShippingCalculatorSheet(),
    );
  }

  void _contactWhatsApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo WhatsApp para atendimento...')),
    );
  }

  Widget _buildCategories() {
    return Column(
      children: [
        const SizedBox(height: 24),
        SectionTitle(
          title: 'Nossas Persianas',
          subtitle: 'Escolha o modelo ideal',
          onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: ProductCategory.values.map((cat) => _CategoryChip(category: cat)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const SectionTitle(title: 'Mais Vendidos', subtitle: 'Aprovados por milhares de clientes'),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _ProductCard(
                category: ProductCategory.rolo,
                fabric: FabricType.blackout,
                imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
              ),
              _ProductCard(
                category: ProductCategory.doubleVision,
                fabric: FabricType.semiBlackout,
                imageUrl: 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=400',
              ),
              _ProductCard(
                category: ProductCategory.romana,
                fabric: FabricType.blackoutPremium,
                imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400',
              ),
              _ProductCard(
                category: ProductCategory.painel,
                fabric: FabricType.screen3,
                imageUrl: 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=400',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorks() {
    final steps = [
      {'icon': Icons.straighten, 'title': '1. Meça', 'desc': 'Use nosso simulador inteligente'},
      {'icon': Icons.palette_outlined, 'title': '2. Escolha', 'desc': 'Modelo, tecido e cor'},
      {'icon': Icons.payment, 'title': '3. Pague', 'desc': 'PIX ou parcelado no cartão'},
      {'icon': Icons.local_shipping_outlined, 'title': '4. Receba', 'desc': 'Entregamos em todo Brasil'},
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Como Funciona', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: steps.map((s) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                      child: Icon(s['icon'] as IconData, color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(s['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 2),
                    Text(s['desc'] as String, style: const TextStyle(color: Colors.white70, fontSize: 9), textAlign: TextAlign.center),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseUs() {
    final items = [
      {'icon': Icons.verified_outlined, 'title': 'Qualidade Garantida', 'desc': '5 anos de garantia em todos os produtos'},
      {'icon': Icons.speed_outlined, 'title': 'Entrega Rápida', 'desc': 'Prazo de produção de 7 a 10 dias úteis'},
      {'icon': Icons.support_agent_outlined, 'title': 'Suporte Especializado', 'desc': 'Assistência técnica disponível'},
      {'icon': Icons.price_check_outlined, 'title': 'Melhor Preço', 'desc': 'Direto da fábrica, sem intermediários'},
    ];
    return Column(
      children: [
        const SizedBox(height: 24),
        const SectionTitle(title: 'Por que nos escolher?', subtitle: 'Mais de 10.000 clientes satisfeitos'),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: InfoCard(
            icon: item['icon'] as IconData,
            title: item['title'] as String,
            subtitle: item['desc'] as String,
          ),
        )),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, color: Color(0xFFE65100), size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Frete Grátis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFE65100))),
                const Text('Nas compras acima de R\$ 500,00 para todo o Brasil', style: TextStyle(fontSize: 12, color: Color(0xFF795548))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGETS DA HOME
// ============================================================
class _HeroBannerItem extends StatelessWidget {
  final String title, subtitle, ctaLabel;
  final LinearGradient gradient;
  final String imageUrl;
  final VoidCallback onTap;

  const _HeroBannerItem({required this.title, required this.subtitle, required this.ctaLabel, required this.gradient, required this.imageUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: AppColors.grey200)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradient.colors.first, gradient.colors.last.withValues(alpha: 0.7)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.2)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: Text(ctaLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final ProductCategory category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(category: category))),
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.white,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(imageUrl: category.imageNetwork, fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: AppColors.grey200)),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, AppColors.grey900.withValues(alpha: 0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(category.shortName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductCategory category;
  final FabricType fabric;
  final String imageUrl;
  const _ProductCard({required this.category, required this.fabric, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final price = PricingModel.getPricePerM2(category, fabric) ?? 0;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(category: category))),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.white,
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, width: double.infinity,
                  errorWidget: (_, __, ___) => Container(color: AppColors.grey200, child: const Icon(Icons.image, color: AppColors.grey400, size: 40))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.shortName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                  Text(fabric.displayName, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('${formatCurrency(price)}/m²', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, ''));
  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);
  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final cats = ProductCategory.values.where((c) => c.displayName.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(
      children: cats.map((c) => ListTile(
        leading: const Icon(Icons.blinds, color: AppColors.primary),
        title: Text(c.displayName),
        onTap: () {
          close(context, c.displayName);
          Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(category: c)));
        },
      )).toList(),
    );
  }
}

// ============================================================
// SHIPPING CALCULATOR SHEET
// ============================================================
class ShippingCalculatorSheet extends StatefulWidget {
  const ShippingCalculatorSheet({super.key});
  @override
  State<ShippingCalculatorSheet> createState() => _ShippingCalculatorSheetState();
}

class _ShippingCalculatorSheetState extends State<ShippingCalculatorSheet> {
  final _cepController = TextEditingController();
  List<ShippingOption>? _options;
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Calcular Frete', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Seu CEP', hintText: '00000-000', prefixIcon: Icon(Icons.location_on_outlined)),
                  maxLength: 9,
                  onChanged: (v) {
                    if (v.length == 8 || (v.length == 9 && v.contains('-'))) _calculate();
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(onPressed: _calculate, child: const Text('Calcular')),
            ],
          ),
          if (_loading) ...[const SizedBox(height: 16), const Center(child: CircularProgressIndicator())],
          if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: AppColors.error))],
          if (_options != null) ...[
            const SizedBox(height: 16),
            ..._options!.map((opt) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(border: Border.all(color: AppColors.grey300), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opt.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(opt.deliveryText, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Text(formatCurrency(opt.price), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Future<void> _calculate() async {
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');
    if (cep.length != 8) return;
    setState(() { _loading = true; _error = null; _options = null; });
    try {
      final options = await ShippingService.calculateShipping(cep, 3.0);
      setState(() { _options = options; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Erro ao calcular frete. Tente novamente.'; _loading = false; });
    }
  }
}

// Import placeholder screens
class ProductDetailScreen extends StatelessWidget {
  final ProductCategory category;
  const ProductDetailScreen({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.displayName)),
      body: const Center(child: Text('Detalhes do Produto')),
    );
  }
}
