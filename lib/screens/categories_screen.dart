import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/common_widgets.dart';
import 'simulator_screen.dart';
import 'educational_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  ProductCategory _selected = ProductCategory.rolo;
  int _heroImageIndex = 0;

  @override
  void didUpdateWidget(covariant CategoriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _heroImageIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Produtos')),
      body: Column(
        children: [
          _buildCategoryTabs(),
          Expanded(child: _buildProductDetail()),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: AppColors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: ProductCategory.values.map((cat) {
            final isSelected = _selected == cat;
            return GestureDetector(
              onTap: () => setState(() {
                _selected = cat;
                _heroImageIndex = 0;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.grey100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey300),
                ),
                child: Text(
                  cat.shortName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductDetail() {
    final fabrics = PricingModel.getFabricsForCategory(_selected);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductHero(),
          const SizedBox(height: 20),
          Text('Tecidos Disponíveis', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...fabrics.map((f) => _FabricCard(fabric: f, category: _selected)),
          const SizedBox(height: 20),
          _buildFeatures(),
          const SizedBox(height: 20),
          _buildDimensions(),
          const SizedBox(height: 16),
          _buildEducationalLink(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: 'Simular e Calcular Preço',
              icon: Icons.straighten,
              onPressed: () {
                context.read<SimulatorProvider>().setCategory(_selected);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SimulatorScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductHero() {
    final images = _selected.galleryImages;
    final current = images[_heroImageIndex % images.length];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              SizedBox(
                height: 220,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: current,
                  fit: BoxFit.cover,
                  key: ValueKey(current),
                  errorWidget: (_, __, ___) => Container(color: AppColors.grey200, child: const Icon(Icons.image, size: 60, color: AppColors.grey400)),
                ),
              ),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, AppColors.grey900.withValues(alpha: 0.75)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selected.displayName,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _selected.categoryDescription,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    // Gallery dots
                    if (images.length > 1)
                      Row(
                        children: List.generate(images.length, (i) => GestureDetector(
                          onTap: () => setState(() => _heroImageIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(left: 4),
                            width: i == _heroImageIndex ? 18 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: i == _heroImageIndex ? Colors.white : Colors.white54,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        )),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Thumbnail gallery
        if (images.length > 1)
          SizedBox(
            height: 64,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => setState(() => _heroImageIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: i == _heroImageIndex ? AppColors.primary : AppColors.grey300,
                      width: i == _heroImageIndex ? 2.5 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: images[i],
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(color: AppColors.grey200),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatures() {
    final Map<ProductCategory, List<String>> features = {
      ProductCategory.rolo: ['Acionamento por corrente ou motor', 'Ideal para ambientes modernos', 'Fácil de instalar', 'Disponível em mais de 50 cores'],
      ProductCategory.romana: ['Elegante e sofisticado', 'Dobras uniformes', 'Ideal para sala e escritório', 'Acabamento premium'],
      ProductCategory.doubleVision: ['Dupla camada de tecido', 'Controle de luminosidade preciso', 'Design moderno e funcional', 'Efeito visual único'],
      ProductCategory.painel: ['Ideal para grandes vãos', 'Sobreposição de painéis', 'Fácil de limpar', 'Movimento suave'],
      ProductCategory.horizontal25mm: ['Lâminas de alumínio', 'Regulagem precisa de luz', 'Resistente à umidade', 'Ideal para escritórios'],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Características', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        ...?features[_selected]?.map((f) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Text(f, style: const TextStyle(fontSize: 14)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDimensions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Limites de Medida', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          _DimensionRow('Largura máxima', '${_selected.maxWidth.toStringAsFixed(2)} m'),
          _DimensionRow('Altura máxima', '3,00 m'),
          _DimensionRow('Área mínima', '1,50 m²'),
          _DimensionRow('Área máxima', '5,00 m²'),
        ],
      ),
    );
  }

  Widget _buildEducationalLink() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EducationalScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.school_outlined, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Como medir e instalar?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Veja nossos guias completos com fotos e dicas', style: TextStyle(color: Colors.white70, fontSize: 12)),
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

class _DimensionRow extends StatelessWidget {
  final String label, value;
  const _DimensionRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _FabricCard extends StatelessWidget {
  final FabricType fabric;
  final ProductCategory category;
  const _FabricCard({required this.fabric, required this.category});

  @override
  Widget build(BuildContext context) {
    final price = PricingModel.getPricePerM2(category, fabric) ?? 0;
    final colors = fabric.availableColors;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 4)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Stacked color swatches
                SizedBox(
                  width: 72,
                  height: 46,
                  child: Stack(
                    children: colors.take(4).toList().asMap().entries.map((e) => Positioned(
                      left: e.key * 16.0,
                      child: Container(
                        width: 38,
                        height: 46,
                        decoration: BoxDecoration(
                          color: e.value.color,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)],
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fabric.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(fabric.lightBlock,
                                style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w500)),
                          ),
                          const SizedBox(width: 6),
                          Text('${colors.length} cores',
                              style: const TextStyle(fontSize: 10, color: AppColors.textHint)),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatCurrency(price),
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                    const Text('por m²', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            // Color swatches row
            if (colors.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: colors.map((fc) => Tooltip(
                  message: fc.name,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: fc.color,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.grey300, width: 1),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 2)],
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
