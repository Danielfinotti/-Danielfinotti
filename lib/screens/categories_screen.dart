import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/common_widgets.dart';
import 'simulator_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  ProductCategory _selected = ProductCategory.rolo;

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
              onTap: () => setState(() => _selected = cat),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          SizedBox(
            height: 220,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: _selected.imageNetwork,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: AppColors.grey200, child: const Icon(Icons.image, size: 60, color: AppColors.grey400)),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.grey900.withValues(alpha: 0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Text(
                _selected.displayName,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
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
    final colorHex = fabric.colorHex;
    final color = Color(int.parse('FF${colorHex.replaceAll('#', '')}', radix: 16));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey300),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fabric.displayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(fabric.lightBlock, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatCurrency(price), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
              const Text('por m²', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
