// ============================================================
// TELA: PEDIR SOMENTE ACESSÓRIO
// ============================================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/common_widgets.dart';

class AccessoryOrderScreen extends StatefulWidget {
  const AccessoryOrderScreen({super.key});

  @override
  State<AccessoryOrderScreen> createState() => _AccessoryOrderScreenState();
}

class _AccessoryOrderScreenState extends State<AccessoryOrderScreen> {
  // Acessórios selecionados (tipo → quantidade)
  final Map<AccessoryType, int> _selected = {};

  // Medidas (usadas apenas para cálculo dos acessórios por metro)
  final _widthCtrl = TextEditingController(text: '1.00');
  final _heightCtrl = TextEditingController(text: '1.00');
  final _obsCtrl = TextEditingController();

  double get _width => double.tryParse(_widthCtrl.text.replaceAll(',', '.')) ?? 1.0;
  double get _height => double.tryParse(_heightCtrl.text.replaceAll(',', '.')) ?? 1.0;

  double _itemPrice(AccessoryType acc, int qty) =>
      acc.calculatePrice(_width, _height) * qty;

  double get _subtotal =>
      _selected.entries.fold(0.0, (s, e) => s + _itemPrice(e.key, e.value));

  bool get _hasSelection => _selected.values.any((q) => q > 0);

  @override
  void dispose() {
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    _obsCtrl.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (!_hasSelection) return;

    final cart = context.read<CartProvider>();
    int added = 0;

    _selected.forEach((acc, qty) {
      if (qty <= 0) return;
      // Cria um SimulatorConfig mínimo apenas com o acessório
      final config = SimulatorConfig(
        category: ProductCategory.rolo, // placeholder — não afeta o preço da persiana
        accessories: [acc],
        width: _width,
        height: _height,
      );
      for (var i = 0; i < qty; i++) {
        cart.addItem(config);
      }
      added++;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text('$added acessório(s) adicionado(s) ao carrinho!'),
        ]),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'Ver Carrinho',
          textColor: Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pedir Acessório'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner informativo
                  _InfoBanner(),

                  const SizedBox(height: 20),

                  // Medidas (necessárias para acessórios cobrados por metro)
                  _buildDimensionsSection(),

                  const SizedBox(height: 20),

                  // Lista de acessórios
                  Text('Escolha os Acessórios',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  const Text(
                    'Selecione os itens e ajuste a quantidade desejada',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),

                  ...AccessoryType.values.map((acc) => _AccessoryCard(
                        accessory: acc,
                        quantity: _selected[acc] ?? 0,
                        unitPrice: acc.calculatePrice(_width, _height),
                        onQtyChanged: (q) => setState(() {
                          if (q <= 0) {
                            _selected.remove(acc);
                          } else {
                            _selected[acc] = q;
                          }
                        }),
                      )),

                  const SizedBox(height: 16),

                  // Observações
                  _buildObservationsField(),
                ],
              ),
            ),
          ),

          // Rodapé com total e botão
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildDimensionsSection() {
    final needsMeasure = _selected.keys.any((a) => a.isPerMeter);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: needsMeasure ? AppColors.primary.withValues(alpha: 0.4) : AppColors.grey200,
          width: needsMeasure ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.straighten,
                color: needsMeasure ? AppColors.primary : AppColors.grey500,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Medidas da Janela',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: needsMeasure ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              if (needsMeasure) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Necessário',
                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            needsMeasure
                ? 'Informe as medidas para calcular o preço dos acessórios por metro'
                : 'Informe as medidas se souber (usadas no cálculo de acessórios por metro)',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DimensionField(
                  controller: _widthCtrl,
                  label: 'Largura (m)',
                  hint: 'Ex: 1.20',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DimensionField(
                  controller: _heightCtrl,
                  label: 'Altura (m)',
                  hint: 'Ex: 1.80',
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildObservationsField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Observações',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _obsCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Ex: cor específica, modelo da persiana, outras informações...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_hasSelection)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal:',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  Text(
                    formatCurrency(_subtotal),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: _hasSelection ? 'Adicionar ao Carrinho' : 'Selecione um acessório',
              icon: Icons.shopping_cart_outlined,
              onPressed: _hasSelection ? _addToCart : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// WIDGETS AUXILIARES
// ─────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.handyman_outlined, color: Colors.white, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Peça Somente o Acessório',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                SizedBox(height: 2),
                Text(
                  'Ideal para quem já tem a persiana e precisa de motor, bandô, barra ou guias.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccessoryCard extends StatelessWidget {
  final AccessoryType accessory;
  final int quantity;
  final double unitPrice;
  final ValueChanged<int> onQtyChanged;

  const _AccessoryCard({
    required this.accessory,
    required this.quantity,
    required this.unitPrice,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = quantity > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF6A1B9A).withValues(alpha: 0.05)
            : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF6A1B9A)
              : AppColors.grey200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Row(
        children: [
          // Ícone / emoji
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isSelected ? const Color(0xFF6A1B9A) : AppColors.grey400)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(accessory.icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accessory.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  accessory.description,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                // Preço com destaque
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6A1B9A).withValues(alpha: 0.12)
                            : AppColors.grey100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        formatCurrency(unitPrice),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF6A1B9A)
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (accessory.isPerMeter) ...[
                      const SizedBox(width: 4),
                      const Text('/ unid.',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Controle de quantidade
          _QuantityControl(
            value: quantity,
            onChanged: onQtyChanged,
            color: const Color(0xFF6A1B9A),
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final Color color;

  const _QuantityControl({
    required this.value,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (value == 0) {
      return GestureDetector(
        onTap: () => onChanged(1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text('+ Adicionar',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onChanged(value - 1),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: Icon(value == 1 ? Icons.delete_outline : Icons.remove,
                  size: 16, color: color),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$value',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: color, fontSize: 14)),
          ),
          GestureDetector(
            onTap: () => onChanged(value + 1),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.add, size: 16, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _DimensionField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  const _DimensionField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: 'm',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
