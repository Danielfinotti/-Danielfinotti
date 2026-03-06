import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/common_widgets.dart';
import 'checkout_screen.dart';
import 'account_screen.dart';
import 'accessory_order_screen.dart';
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Carrinho (${cart.totalQuantity})'),
        actions: [
          if (cart.itemCount > 0)
            TextButton(
              onPressed: () => _confirmClear(context, cart),
              child: const Text('Limpar', style: TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: cart.itemCount == 0
          ? _EmptyCartView()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.itemCount,
                    itemBuilder: (context, i) =>
                        _CartItemCard(item: cart.items[i]),
                  ),
                ),
                _CartSummary(cart: cart),
              ],
            ),
    );
  }

  void _confirmClear(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpar carrinho?'),
        content: const Text('Todos os itens serão removidos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              cart.clear();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final config = item.config;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.blinds, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(config.category.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    if (config.fabric != null)
                      Text(config.fabric!.displayName,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => cart.removeItem(item.id),
              ),
            ],
          ),
          const Divider(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (config.width != null && config.height != null)
                _InfoChip('${config.width!.toStringAsFixed(2)}m × ${config.height!.toStringAsFixed(2)}m'),
              _InfoChip('Área: ${config.billedArea.toStringAsFixed(2)} m²'),
              if (config.fabric != null)
                _InfoChip(config.fabric!.displayName),
              if (config.fabricColor != null)
                _InfoChipColor(config.fabricColor!, config.fabric),
              if (config.installation != null)
                _InfoChip(config.installation!.displayName),
              _InfoChip('Comando: ${config.commandSide.displayName}'),
              ...config.accessories.map((a) => _InfoChip(a.displayName)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Controle de quantidade
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () => cart.updateQuantity(item.id, item.quantity - 1),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('${item.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () => cart.updateQuantity(item.id, item.quantity + 1),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                formatCurrency(item.totalPrice),
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip(this.label);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey700)),
    );
  }
}

class _InfoChipColor extends StatelessWidget {
  final String colorName;
  final FabricType? fabric;
  const _InfoChipColor(this.colorName, this.fabric);

  @override
  Widget build(BuildContext context) {
    Color? swatch;
    if (fabric != null) {
      try {
        swatch = fabric!.availableColors.firstWhere((c) => c.name == colorName).color;
      } catch (_) {}
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (swatch != null) ...[
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: swatch,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grey300, width: 0.5),
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(colorName, style: const TextStyle(fontSize: 11, color: AppColors.grey700)),
        ],
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CartProvider cart;
  const _CartSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${cart.itemCount} ${cart.itemCount == 1 ? "item" : "itens"}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('Subtotal: ${formatCurrency(cart.subtotal)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('* Frete calculado no próximo passo',
              style: TextStyle(fontSize: 11, color: AppColors.textHint)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: 'Finalizar Compra',
              icon: Icons.lock_outline,
              onPressed: () {
                final userProv = context.read<UserProvider>();
                if (!userProv.isLoggedIn || userProv.user?.id == 'guest') {
                  // Exige login antes do checkout
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Row(children: [
                        Icon(Icons.lock_outline, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Login necessário'),
                      ]),
                      content: const Text(
                        'Para finalizar sua compra você precisa estar logado.\n\nFaça login ou crie sua conta gratuitamente.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.login),
                          label: const Text('Fazer Login'),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AccountScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Estado de carrinho vazio com opção de pedir acessório ──────
class _EmptyCartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 56,
                color: AppColors.grey400,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Carrinho vazio',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adicione persianas usando o simulador ou\npeça acessórios avulsos',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: GradientButton(
                label: 'Ir para Simulador',
                icon: Icons.straighten_outlined,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.handyman_outlined),
                label: const Text('Pedir Acessórios Avulsos'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AccessoryOrderScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
