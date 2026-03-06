import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:badges/badges.dart' as badges;
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/common_widgets.dart';
import 'simulator_screen.dart';
import 'accessory_order_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'account_screen.dart';
import 'educational_screen.dart';
import '../services/services.dart';
import 'admin_panel_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const CategoriesScreen(),
      const SimulatorScreen(),
      const CartScreen(),
      const AccountScreen(),
    ];
  }

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
          SliverToBoxAdapter(child: _buildMaisQueridinhas()),
          SliverToBoxAdapter(child: _buildFeaturedProducts()),
          SliverToBoxAdapter(child: _buildHowItWorks()),
          SliverToBoxAdapter(child: _buildWhyChooseUs()),
          SliverToBoxAdapter(child: _buildInspirationGallery()),
          SliverToBoxAdapter(child: _buildEducationalSection()),
          SliverToBoxAdapter(child: _buildBanner()),
          SliverToBoxAdapter(child: _buildWhatsAppBanner()),
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
        // Botão Admin — visível apenas para o administrador logado
        if (context.watch<UserProvider>().isAdmin)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white),
            tooltip: 'Painel Admin',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen())),
          ),
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
            subtitle: 'Calcule online, receba em casa',
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
      {'icon': Icons.handyman_outlined, 'label': 'Pedir\nAcessório', 'color': const Color(0xFF6A1B9A)},
      {'icon': Icons.local_shipping_outlined, 'label': 'Calcular\nFrete', 'color': const Color(0xFFE65100)},
      {'icon': Icons.support_agent, 'label': 'Falar com\nEspecialista', 'color': const Color(0xFF00796B)},
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
    } else if (label.contains('Acessório')) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AccessoryOrderScreen()));
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

  Widget _buildEducationalSection() {
    final articles = [
      {
        'title': 'Como medir\ncorretamente',
        'subtitle': 'Guia completo passo a passo',
        'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
        'color': AppColors.primary,
        'tab': 0,
      },
      {
        'title': 'Qual persiana\nescolher?',
        'subtitle': 'Conheça todos os modelos',
        'imageUrl': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80',
        'color': const Color(0xFF00897B),
        'tab': 1,
      },
      {
        'title': 'Tipos de\ninstalação',
        'subtitle': 'Dentro ou fora do vão?',
        'imageUrl': 'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=600&q=80',
        'color': const Color(0xFF6A1B9A),
        'tab': 2,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        SectionTitle(
          title: 'Aprenda Mais',
          subtitle: 'Guias e dicas de especialistas',
          onSeeAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EducationalScreen())),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: articles.length,
            itemBuilder: (context, i) {
              final a = articles[i];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EducationalScreen(initialTab: a['tab'] as int),
                  ),
                ),
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: a['imageUrl'] as String,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: AppColors.grey200),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, (a['color'] as Color).withValues(alpha: 0.85)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        right: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(a['title'] as String,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, height: 1.2)),
                            const SizedBox(height: 2),
                            Text(a['subtitle'] as String,
                                style: const TextStyle(color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInspirationGallery() {
    final photos = [
      {
        'url': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&q=80',
        'label': 'Sala de Estar',
      },
      {
        'url': 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=600&q=80',
        'label': 'Home Office',
      },
      {
        'url': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80',
        'label': 'Quarto',
      },
      {
        'url': 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=600&q=80',
        'label': 'Cozinha',
      },
      {
        'url': 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=600&q=80',
        'label': 'Escritório',
      },
      {
        'url': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
        'label': 'Varanda',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SectionTitle(
          title: 'Inspire-se',
          subtitle: 'Ambientes decorados com nossas persianas',
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: photos.length,
            itemBuilder: (context, i) {
              final p = photos[i];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: p['url']!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(color: AppColors.grey200),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        p['label']!,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // AS MAIS QUERIDINHAS — preço isca
  // ──────────────────────────────────────────
  Widget _buildMaisQueridinhas() {
    final items = [
      {
        'category': ProductCategory.rolo,
        'fabric': 'Blackout',
        'originalPrice': 329.90,
        'promoPrice': 219.90,
        'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
        'tag': '🔥 Mais Vendida',
      },
      {
        'category': ProductCategory.doubleVision,
        'fabric': 'Semi-Blackout',
        'originalPrice': 529.90,
        'promoPrice': 429.70,
        'imageUrl': 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=600&q=80',
        'tag': '⭐ Destaque',
      },
      {
        'category': ProductCategory.horizontal25mm,
        'fabric': 'Alumínio 25mm',
        'originalPrice': 279.90,
        'promoPrice': 199.90,
        'imageUrl': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&q=80',
        'tag': '💎 Melhor Custo',
      },
      {
        'category': ProductCategory.romana,
        'fabric': 'Blackout Premium',
        'originalPrice': 449.90,
        'promoPrice': 299.00,
        'imageUrl': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80',
        'tag': '✨ Elegante',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFFF7043)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Text('💖', style: TextStyle(fontSize: 22)),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('As Mais Queridinhas',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Preços especiais · Estoque limitado',
                        style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.local_fire_department, color: Colors.white, size: 28),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final cat = item['category'] as ProductCategory;
              final originalPrice = item['originalPrice'] as double;
              final promoPrice = item['promoPrice'] as double;
              final discount = (((originalPrice - promoPrice) / originalPrice) * 100).round();

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetailScreen(category: cat)),
                ),
                child: Container(
                  width: 175,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 10)],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagem
                      Stack(
                        children: [
                          SizedBox(
                            height: 140,
                            width: double.infinity,
                            child: CachedNetworkImage(
                              imageUrl: item['imageUrl'] as String,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(color: AppColors.grey200),
                            ),
                          ),
                          // Badge de desconto
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('-$discount%',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                            ),
                          ),
                          // Tag
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              color: Colors.black.withValues(alpha: 0.45),
                              child: Text(
                                item['tag'] as String,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Conteúdo
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cat.shortName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(item['fabric'] as String,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Text(
                              'R\$ ${originalPrice.toStringAsFixed(2).replaceAll('.', ',')}/m²',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textHint,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              'R\$ ${promoPrice.toStringAsFixed(2).replaceAll('.', ',')}/m²',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFE53935),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────
  // BANNER WHATSAPP
  // ──────────────────────────────────────────
  Widget _buildWhatsAppBanner() {
    return GestureDetector(
      onTap: () async {
        final url = Uri.parse(WhatsAppService.buildUrl(message: WhatsAppService.supportMessage()));
        if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF25D366).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.chat, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fale conosco no WhatsApp',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('Tire dúvidas, peça orçamento ou acompanhe seu pedido',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
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

// ============================================================
// PRODUCT DETAIL SCREEN — tela completa de detalhe do produto
// ============================================================
class ProductDetailScreen extends StatefulWidget {
  final ProductCategory category;
  const ProductDetailScreen({super.key, required this.category});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _heroIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;
    final images = cat.galleryImages;
    final fabrics = PricingModel.getFabricsForCategory(cat);
    // Lê textos do provider (editável pelo Painel Admin)
    final detailsProv = context.watch<ProductDetailsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar com galeria
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _heroIndex = i),
                    itemBuilder: (_, i) => CachedNetworkImage(
                      imageUrl: images[i],
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.grey200),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.grey200,
                        child: const Icon(Icons.image, size: 48, color: AppColors.grey400),
                      ),
                    ),
                  ),
                  // Gradiente inferior
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  // Dots
                  Positioned(
                    bottom: 12, left: 0, right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(images.length, (i) => Container(
                        width: _heroIndex == i ? 18 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _heroIndex == i ? Colors.white : Colors.white54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                  ),
                ],
              ),
            ),
            title: Text(cat.displayName, style: const TextStyle(fontSize: 16)),
          ),

          // Conteúdo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge categoria
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(cat.displayName,
                        style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 10),

                  // Título + tagline
                  Text(cat.displayName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(detailsProv.getTagline(cat),
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),

                  const SizedBox(height: 16),

                  // Descrição longa
                  Text('Sobre este Produto',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    detailsProv.getDescription(cat),
                    style: const TextStyle(fontSize: 13.5, height: 1.55, color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 20),

                  // Vantagens
                  Text('Vantagens', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...detailsProv.getAdvantagesList(cat).map((adv) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(adv, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  )),

                  const SizedBox(height: 20),

                  // Limites de medida
                  _buildDimensions(cat),

                  const SizedBox(height: 20),

                  // Tecidos disponíveis
                  Text('Tecidos Disponíveis',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...fabrics.map((f) => _FabricTile(fabric: f, category: cat)),

                  const SizedBox(height: 24),

                  // Botão Simular
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.straighten),
                      label: const Text('Calcular Preço com Minhas Medidas'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final simProv = context.read<SimulatorProvider>();
                        simProv.setCategory(cat);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const SimulatorScreen()),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensions(ProductCategory cat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.straighten, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text('Limites de Medida',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
          ]),
          const SizedBox(height: 12),
          _DimRow('Largura máxima', '${cat.maxWidth.toStringAsFixed(2)} m'),
          _DimRow('Altura máxima', '3,00 m'),
          _DimRow('Área mínima', '1,50 m²'),
          _DimRow('Área máxima', '5,00 m²'),
        ],
      ),
    );
  }
}

class _DimRow extends StatelessWidget {
  final String label, value;
  const _DimRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FabricTile extends StatelessWidget {
  final FabricType fabric;
  final ProductCategory category;
  const _FabricTile({required this.fabric, required this.category});
  @override
  Widget build(BuildContext context) {
    final price = PricingModel.getPricePerM2(category, fabric);
    final colorHex = fabric.colorHex.replaceAll('#', '');
    final color = Color(int.parse('FF$colorHex', radix: 16));
    final colors = fabric.availableColors.take(5).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
      ),
      child: Row(
        children: [
          // Cor principal do tecido
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fabric.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(fabric.lightBlock,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                // Mini paleta de cores
                Row(children: colors.map((c) {
                  final hex = c.hex.replaceAll('#', '');
                  final col = Color(int.parse('FF$hex', radix: 16));
                  return Container(
                    width: 16, height: 16, margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: col,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.grey200),
                    ),
                  );
                }).toList()),
              ],
            ),
          ),
          if (price != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('a partir de', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                Text('R\$ ${price.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14)),
                const Text('/m²', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
        ],
      ),
    );
  }
}
