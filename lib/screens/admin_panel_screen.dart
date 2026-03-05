import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedTab = 0;

  final List<_AdminTab> _tabs = [
    _AdminTab(Icons.dashboard_outlined, 'Dashboard'),
    _AdminTab(Icons.receipt_long_outlined, 'Pedidos'),
    _AdminTab(Icons.inventory_2_outlined, 'Produtos'),
    _AdminTab(Icons.bar_chart_outlined, 'Relatórios'),
  ];

  // Mock data
  final List<Map<String, dynamic>> _mockOrders = [
    {'number': 'CPO202501001', 'client': 'João Silva', 'value': 1250.00, 'status': OrderStatus.emProducao, 'items': 2},
    {'number': 'CPO202501002', 'client': 'Maria Santos', 'value': 849.90, 'status': OrderStatus.pagamentoAprovado, 'items': 1},
    {'number': 'CPO202501003', 'client': 'Carlos Oliveira', 'value': 2180.00, 'status': OrderStatus.enviado, 'items': 3},
    {'number': 'CPO202501004', 'client': 'Ana Costa', 'value': 699.90, 'status': OrderStatus.entregue, 'items': 1},
    {'number': 'CPO202501005', 'client': 'Pedro Lima', 'value': 1540.00, 'status': OrderStatus.emSeparacao, 'items': 2},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Painel Administrativo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Control Persianas Online', style: TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: const Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.primaryDark,
      child: Row(
        children: _tabs.asMap().entries.map((e) {
          final isSelected = e.key == _selectedTab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = e.key),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(e.value.icon,
                        color: isSelected ? Colors.white : Colors.white54,
                        size: 20),
                    const SizedBox(height: 2),
                    Text(e.value.label,
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white54,
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: return _buildDashboard();
      case 1: return _buildOrders();
      case 2: return _buildProducts();
      case 3: return _buildReports();
      default: return _buildDashboard();
    }
  }

  // ============================================================
  // DASHBOARD
  // ============================================================
  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Visão Geral', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('Resumo do mês atual', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),

          // KPI Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _KpiCard('Faturamento', 'R\$ 18.420', Icons.attach_money, const Color(0xFF2E7D32), '+12%'),
              _KpiCard('Pedidos', '47', Icons.receipt_long, AppColors.primary, '+8%'),
              _KpiCard('m² Vendidos', '83,4 m²', Icons.crop_square, const Color(0xFF6A1B9A), '+15%'),
              _KpiCard('Ticket Médio', 'R\$ 391,91', Icons.trending_up, const Color(0xFFE65100), '+3%'),
            ],
          ),

          const SizedBox(height: 20),

          Text('Pedidos Recentes', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ..._mockOrders.take(3).map((order) => _AdminOrderTile(order: order, onStatusChange: _changeStatus)),

          const SizedBox(height: 20),

          Text('Mais Vendidos', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...[
            ('Persiana Rolô Blackout', 38, 0.78),
            ('Double Vision Semi-Blackout', 22, 0.52),
            ('Romana Blackout Premium', 15, 0.36),
            ('Painel Screen 3%', 10, 0.24),
          ].map((item) => _TopProductTile(name: item.$1, sales: item.$2, progress: item.$3)),
        ],
      ),
    );
  }

  // ============================================================
  // PEDIDOS
  // ============================================================
  Widget _buildOrders() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.white,
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar pedido...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<OrderStatus?>(
                icon: const Icon(Icons.filter_list, color: AppColors.primary),
                onSelected: (_) {},
                itemBuilder: (_) => [
                  const PopupMenuItem(value: null, child: Text('Todos')),
                  ...OrderStatus.values.map((s) => PopupMenuItem(value: s, child: Text(s.displayName))),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: _mockOrders.map((order) => _AdminOrderTile(
              order: order,
              onStatusChange: _changeStatus,
              showActions: true,
            )).toList(),
          ),
        ),
      ],
    );
  }

  void _changeStatus(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alterar Status', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text('Pedido #${order['number']}', style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ...OrderStatus.values.where((s) => s != OrderStatus.cancelado).map((s) {
              final statusColor = Color(int.parse('FF${s.colorHex.replaceAll('#', '')}', radix: 16));
              return ListTile(
                leading: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                ),
                title: Text(s.displayName),
                onTap: () {
                  setState(() => order['status'] = s);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Status atualizado: ${s.displayName}'), backgroundColor: AppColors.success),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PRODUTOS
  // ============================================================
  Widget _buildProducts() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: AppColors.white,
            child: const TabBar(
              tabs: [
                Tab(text: 'Categorias'),
                Tab(text: 'Tecidos'),
                Tab(text: 'Acessórios'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildCategoryManager(),
                _buildFabricManager(),
                _buildAccessoryManager(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryManager() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: ProductCategory.values.map((cat) {
        final fabrics = PricingModel.getFabricsForCategory(cat);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.blinds, color: AppColors.primary, size: 20),
            ),
            title: Text(cat.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${fabrics.length} tecidos • Larg. máx: ${cat.maxWidth.toStringAsFixed(2)}m',
                style: const TextStyle(fontSize: 11)),
            children: [
              ...fabrics.map((f) {
                final price = PricingModel.getPricePerM2(cat, f) ?? 0;
                return ListTile(
                  dense: true,
                  leading: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: Color(int.parse('FF${f.colorHex.replaceAll('#', '')}', radix: 16)),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.grey300),
                    ),
                  ),
                  title: Text(f.displayName, style: const TextStyle(fontSize: 13)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formatCurrency(price),
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit_outlined, size: 16, color: AppColors.grey500),
                    ],
                  ),
                  onTap: () => _editPrice(context, cat, f, price),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _editPrice(BuildContext context, ProductCategory cat, FabricType fabric, double currentPrice) {
    final ctrl = TextEditingController(text: currentPrice.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Editar Preço'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${cat.shortName} — ${fabric.displayName}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 12),
            TextFormField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Preço por m²',
                prefixText: 'R\$ ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Preço atualizado: R\$ ${ctrl.text}/m²'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFabricManager() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: () => _addFabric(context),
          icon: const Icon(Icons.add),
          label: const Text('Adicionar Tecido'),
        ),
        const SizedBox(height: 16),
        ...FabricType.values.map((f) {
          final color = Color(int.parse('FF${f.colorHex.replaceAll('#', '')}', radix: 16));
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey300),
                ),
              ),
              title: Text(f.displayName),
              subtitle: Text(f.lightBlock, style: const TextStyle(fontSize: 11)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error), onPressed: () {}),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _addFabric(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Novo Tecido'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(decoration: const InputDecoration(labelText: 'Nome do tecido')),
            const SizedBox(height: 12),
            TextFormField(decoration: const InputDecoration(labelText: 'Nível de bloqueio de luz')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Adicionar')),
        ],
      ),
    );
  }

  Widget _buildAccessoryManager() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Adicionar Acessório'),
        ),
        const SizedBox(height: 16),
        ...AccessoryType.values.map((acc) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Text(acc.icon, style: const TextStyle(fontSize: 24)),
            title: Text(acc.displayName),
            subtitle: Text(acc.description, style: const TextStyle(fontSize: 11)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(formatCurrency(acc.price),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.edit_outlined, size: 16), onPressed: () {}),
              ],
            ),
          ),
        )),
      ],
    );
  }

  // ============================================================
  // RELATÓRIOS
  // ============================================================
  Widget _buildReports() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Relatórios', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('Dados do período atual', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),

          // Period selector
          Row(
            children: ['7 dias', '30 dias', '3 meses', '1 ano'].map((p) {
              final isSelected = p == '30 dias';
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.grey300),
                ),
                child: Text(p,
                    style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Revenue chart placeholder
          Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Faturamento Mensal', style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ('Jan', 65.0), ('Fev', 78.0), ('Mar', 55.0), ('Abr', 90.0),
                    ('Mai', 72.0), ('Jun', 100.0), ('Jul', 88.0),
                  ].map((item) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 28,
                          height: item.$2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(item.$1, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _ReportCard('Total de Pedidos', '247', Icons.receipt_long, AppColors.primary),
              _ReportCard('m² Produzidos', '428,6', Icons.crop_square, const Color(0xFF6A1B9A)),
              _ReportCard('Clientes Novos', '89', Icons.person_add_outlined, const Color(0xFF00897B)),
              _ReportCard('Taxa de Retorno', '34%', Icons.repeat, const Color(0xFFE65100)),
            ],
          ),

          const SizedBox(height: 20),
          Text('Produtos Mais Vendidos', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          ...[
            ('Persiana Rolô Blackout', 'R\$ 6.245,10', 89),
            ('Double Vision Semi-Blackout', 'R\$ 4.890,50', 68),
            ('Romana Blackout Premium', 'R\$ 3.221,80', 47),
            ('Painel Screen 3%', 'R\$ 1.890,20', 32),
            ('Horizontal 25mm Alumínio', 'R\$ 1.340,00', 24),
          ].map((item) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.blinds, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('${item.$3} unidades', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text(item.$2, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN WIDGETS
// ============================================================
class _AdminTab {
  final IconData icon;
  final String label;
  _AdminTab(this.icon, this.label);
}

class _KpiCard extends StatelessWidget {
  final String title, value, trend;
  final IconData icon;
  final Color color;
  const _KpiCard(this.title, this.value, this.icon, this.color, this.trend);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(trend, style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _AdminOrderTile extends StatelessWidget {
  final Map<String, dynamic> order;
  final Function(Map<String, dynamic>) onStatusChange;
  final bool showActions;

  const _AdminOrderTile({required this.order, required this.onStatusChange, this.showActions = false});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as OrderStatus;
    final statusColor = Color(int.parse('FF${status.colorHex.replaceAll('#', '')}', radix: 16));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${order['number']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(order['client'] as String,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status.displayName,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${order['items']} itens',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const Spacer(),
              Text(formatCurrency(order['value'] as double),
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
              if (showActions) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => onStatusChange(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Atualizar', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TopProductTile extends StatelessWidget {
  final String name;
  final int sales;
  final double progress;
  const _TopProductTile({required this.name, required this.sales, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              Text('$sales vendas', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _ReportCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 22)),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
