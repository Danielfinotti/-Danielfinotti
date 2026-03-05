import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/common_widgets.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Meus Pedidos')),
      body: orders.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Nenhum pedido ainda',
              subtitle: 'Seus pedidos aparecerão aqui após a compra',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, i) => _OrderCard(order: orders[i]),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(int.parse(
        'FF${order.status.colorHex.replaceAll('#', '')}',
        radix: 16));

    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))),
      child: Container(
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
                Text('Pedido #${order.orderNumber}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${order.items.length} ${order.items.length == 1 ? "item" : "itens"} • ${order.items.map((i) => i.config.category.shortName).join(", ")}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(order.createdAt),
              style:
                  const TextStyle(color: AppColors.textHint, fontSize: 11),
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.paymentMethod,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                Text(
                  formatCurrency(order.total),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _OrderProgressBar(status: order.status),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

class _OrderProgressBar extends StatelessWidget {
  final OrderStatus status;
  const _OrderProgressBar({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelado) {
      return const Row(
        children: [
          Icon(Icons.cancel_outlined, color: AppColors.error, size: 16),
          SizedBox(width: 6),
          Text('Pedido cancelado',
              style: TextStyle(color: AppColors.error, fontSize: 12)),
        ],
      );
    }

    final steps = [
      OrderStatus.pagamentoAprovado,
      OrderStatus.emProducao,
      OrderStatus.emSeparacao,
      OrderStatus.enviado,
      OrderStatus.entregue,
    ];
    final currentStep = status.step.clamp(0, steps.length);

    return Row(
      children: List.generate(steps.length, (i) {
        final done = i < currentStep;
        final current = i == currentStep - 1;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done || current
                      ? AppColors.success
                      : AppColors.grey300,
                ),
              ),
              if (i < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: done ? AppColors.success : AppColors.grey200,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

// ============================================================
// ORDER DETAIL SCREEN
// ============================================================
class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = Color(int.parse(
        'FF${order.status.colorHex.replaceAll('#', '')}',
        radix: 16));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Pedido #${order.orderNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _shareOrder(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(_getStatusIcon(order.status),
                      color: statusColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.status.displayName,
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(_getStatusMessage(order.status),
                            style: TextStyle(
                                color: statusColor.withValues(alpha: 0.8),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Timeline
            _StatusTimeline(status: order.status),

            const SizedBox(height: 20),

            // Itens
            Text('Itens do Pedido',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            ...order.items.map((item) => _OrderItemTile(item: item)),

            const SizedBox(height: 20),

            // Endereço
            Text('Endereço de Entrega',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            InfoCard(
              icon: Icons.location_on_outlined,
              title: order.address.city,
              subtitle: order.address.fullAddress,
            ),

            const SizedBox(height: 20),

            // Resumo financeiro
            Text('Resumo Financeiro',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
              ),
              child: Column(
                children: [
                  _FinanceRow('Subtotal dos produtos', formatCurrency(order.subtotal)),
                  _FinanceRow('Frete', formatCurrency(order.shippingCost)),
                  _FinanceRow('Forma de pagamento', order.paymentMethod),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(formatCurrency(order.total),
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20)),
                    ],
                  ),
                ],
              ),
            ),

            if (order.trackingCode != null) ...[
              const SizedBox(height: 20),
              InfoCard(
                icon: Icons.local_shipping_outlined,
                title: 'Código de Rastreio',
                subtitle: order.trackingCode!,
                iconColor: AppColors.successLight,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus s) {
    switch (s) {
      case OrderStatus.pagamentoPendente: return Icons.schedule;
      case OrderStatus.pagamentoAprovado: return Icons.check_circle_outline;
      case OrderStatus.emProducao: return Icons.factory_outlined;
      case OrderStatus.emSeparacao: return Icons.inventory_2_outlined;
      case OrderStatus.enviado: return Icons.local_shipping_outlined;
      case OrderStatus.entregue: return Icons.home_outlined;
      case OrderStatus.cancelado: return Icons.cancel_outlined;
    }
  }

  String _getStatusMessage(OrderStatus s) {
    switch (s) {
      case OrderStatus.pagamentoPendente: return 'Aguardando confirmação do pagamento';
      case OrderStatus.pagamentoAprovado: return 'Pagamento confirmado! Iniciando produção';
      case OrderStatus.emProducao: return 'Sua persiana está sendo fabricada';
      case OrderStatus.emSeparacao: return 'Preparando para envio';
      case OrderStatus.enviado: return 'A caminho da sua casa!';
      case OrderStatus.entregue: return 'Pedido entregue com sucesso!';
      case OrderStatus.cancelado: return 'Pedido cancelado';
    }
  }

  void _shareOrder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compartilhando resumo do pedido...')),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final OrderStatus status;
  const _StatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (OrderStatus.pagamentoAprovado, Icons.check_circle_outline, 'Pagamento\nAprovado'),
      (OrderStatus.emProducao, Icons.factory_outlined, 'Em\nProdução'),
      (OrderStatus.emSeparacao, Icons.inventory_2_outlined, 'Em\nSeparação'),
      (OrderStatus.enviado, Icons.local_shipping_outlined, 'Enviado'),
      (OrderStatus.entregue, Icons.home_outlined, 'Entregue'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final isDone = step.$1.step <= status.step && status.step > 0;
          final isCurrent = step.$1.step == status.step;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == 0
                            ? Colors.transparent
                            : (isDone ? AppColors.success : AppColors.grey200),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? AppColors.success
                            : isCurrent
                                ? AppColors.primary
                                : AppColors.grey200,
                      ),
                      child: Icon(
                        step.$2,
                        size: 14,
                        color: isDone || isCurrent
                            ? Colors.white
                            : AppColors.grey400,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == steps.length - 1
                            ? Colors.transparent
                            : (isDone ? AppColors.success : AppColors.grey200),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  step.$3,
                  style: TextStyle(
                    fontSize: 9,
                    color: isDone
                        ? AppColors.success
                        : isCurrent
                            ? AppColors.primary
                            : AppColors.grey400,
                    fontWeight:
                        isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final CartItem item;
  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.blinds, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.config.category.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (item.config.fabric != null)
                  Text(item.config.fabric!.displayName,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                if (item.config.width != null && item.config.height != null)
                  Text(
                    '${item.config.width!.toStringAsFixed(2)}m × ${item.config.height!.toStringAsFixed(2)}m',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textHint),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${item.quantity}x',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              Text(formatCurrency(item.totalPrice),
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinanceRow extends StatelessWidget {
  final String label, value;
  const _FinanceRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
