import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';

// ============================================================
// PAINEL ADMIN — Control Persianas Online
// Abas: Dashboard | Pedidos | Produtos | Tecidos/Cores |
//       Detalhes | Mídias | Textos | Relatórios
// ============================================================
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _tab = 0;

  final List<_AdminTab> _tabs = const [
    _AdminTab(Icons.dashboard_outlined,      'Dashboard'),
    _AdminTab(Icons.shopping_bag_outlined,   'Pedidos'),
    _AdminTab(Icons.inventory_2_outlined,    'Produtos'),
    _AdminTab(Icons.palette_outlined,        'Tecidos'),
    _AdminTab(Icons.description_outlined,    'Detalhes'),
    _AdminTab(Icons.play_circle_outline,     'Mídias'),
    _AdminTab(Icons.edit_note_outlined,      'Textos'),
    _AdminTab(Icons.bar_chart_outlined,      'Relatórios'),
  ];

  @override
  Widget build(BuildContext context) {
    // ── Verificação de acesso admin ────────────────────────────
    final userProv = context.watch<UserProvider>();
    if (!userProv.isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Acesso Negado')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock, color: AppColors.error, size: 64),
                ),
                const SizedBox(height: 24),
                const Text('Acesso Restrito',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  'O Painel Admin é exclusivo para o administrador do sistema.\n\nFaça login com sua conta de administrador para acessar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Voltar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.admin_panel_settings, size: 20),
          SizedBox(width: 8),
          Text('Painel Admin'),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Tabs horizontais scrolláveis
          Container(
            color: AppColors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: _tabs.asMap().entries.map((e) {
                  final sel = _tab == e.key;
                  return GestureDetector(
                    onTap: () => setState(() => _tab = e.key),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primary : AppColors.grey100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(e.value.icon, size: 14,
                            color: sel ? Colors.white : AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(e.value.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                              color: sel ? Colors.white : AppColors.textPrimary,
                            )),
                      ]),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: const [
                _DashboardTab(),
                _OrdersAdminTab(),
                _ProductsAdminTab(),
                _FabricsColorsAdminTab(),
                _ProductDetailsAdminTab(),
                _MediaAdminTab(),
                _TextsAdminTab(),
                _ReportsAdminTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTab {
  final IconData icon;
  final String label;
  const _AdminTab(this.icon, this.label);
}

// ============================================================
// TAB 1 — DASHBOARD
// ============================================================
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    final totalRevenue = orders.fold<double>(0, (s, o) => s + o.subtotal + o.shippingCost);

    final stats = [
      _Stat('Total de Pedidos', '${orders.length}', Icons.shopping_bag_outlined, AppColors.primary),
      _Stat('Receita Total', 'R\$ ${totalRevenue.toStringAsFixed(2)}', Icons.attach_money, AppColors.success),
      _Stat('Em Produção', '${orders.where((o) => o.status == OrderStatus.emProducao).length}', Icons.precision_manufacturing_outlined, const Color(0xFFFF6F00)),
      _Stat('Aguard. Pgto', '${orders.where((o) => o.status == OrderStatus.pagamentoPendente).length}', Icons.hourglass_empty, const Color(0xFFE53935)),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.6,
            children: stats.map((s) => _StatCard(stat: s)).toList(),
          ),
          const SizedBox(height: 20),
          Text('Últimos Pedidos', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          if (orders.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Nenhum pedido ainda', style: TextStyle(color: AppColors.textSecondary)),
            ))
          else
            ...orders.take(5).map((o) => _OrderMiniCard(order: o)),
          const SizedBox(height: 20),
          Text('Ações Rápidas', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          _QuickActionCard(
            icon: Icons.price_change_outlined,
            title: 'Atualizar Preços',
            subtitle: 'Ajustar preços por m² de qualquer produto',
            color: const Color(0xFF00897B),
            onTap: () {},
          ),
          _QuickActionCard(
            icon: Icons.chat_outlined,
            title: 'Atendimento WhatsApp',
            subtitle: 'Abrir conversa com clientes',
            color: const Color(0xFF25D366),
            onTap: () async {
              final url = Uri.parse(AppConfig.whatsappUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TAB 2 — PEDIDOS
// ============================================================
class _OrdersAdminTab extends StatefulWidget {
  const _OrdersAdminTab();
  @override
  State<_OrdersAdminTab> createState() => _OrdersAdminTabState();
}

class _OrdersAdminTabState extends State<_OrdersAdminTab> {
  OrderStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    final filtered = _filter == null ? orders : orders.where((o) => o.status == _filter).toList();

    return Column(
      children: [
        // Filtro por status
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _FilterChip(label: 'Todos', selected: _filter == null,
                  onTap: () => setState(() => _filter = null)),
              ...OrderStatus.values.map((s) => _FilterChip(
                label: s.displayName,
                selected: _filter == s,
                onTap: () => setState(() => _filter = s),
              )),
            ]),
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('Nenhum pedido neste status'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _AdminOrderCard(order: filtered[i]),
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 11,
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            )),
      ),
    );
  }
}

// ============================================================
// TAB 3 — PRODUTOS & PREÇOS
// ============================================================
class _ProductsAdminTab extends StatefulWidget {
  const _ProductsAdminTab();
  @override
  State<_ProductsAdminTab> createState() => _ProductsAdminTabState();
}

class _ProductsAdminTabState extends State<_ProductsAdminTab> {
  final Map<String, double> _prices = {
    'rolo_blackout': 219.90,
    'rolo_screen1': 240.80,
    'rolo_screen3': 227.60,
    'rolo_screen5': 219.90,
    'rolo_blackoutPremium': 280.90,
    'rolo_translucido': 219.90,
    'romana_blackout': 299.00,
    'romana_screen1': 316.05,
    'romana_screen3': 306.25,
    'romana_screen5': 299.00,
    'romana_blackoutPremium': 377.30,
    'romana_translucido': 299.00,
    'painel_blackout': 219.90,
    'painel_screen1': 240.80,
    'painel_screen3': 227.60,
    'painel_screen5': 219.90,
    'painel_blackoutPremium': 280.90,
    'painel_translucido': 219.90,
    'doubleVision_semiBlackout': 429.70,
    'doubleVision_translucidaDV': 319.90,
    'horizontal25mm_aluminio25': 199.90,
    'horizontal25mm_manual25': 270.90,
    'motor_wifi': 1297.00,
    'bando': 99.90,
    'barraEstabilizadora': 50.00,
    'guiaLateral': 140.00,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Produtos & Preços', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _showAddProductDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Novo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                textStyle: const TextStyle(fontSize: 13),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          const Text('Toque no valor para editar o preço por m²',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ...ProductCategory.values.map((cat) => _CategoryPriceSection(
            category: cat, prices: _prices,
            onPriceChanged: (k, v) => setState(() => _prices[k] = v),
          )),
          const SizedBox(height: 8),
          _SectionHeader('Acessórios'),
          const SizedBox(height: 8),
          _PriceEditTile('Motor WiFi', 'motor_wifi', _prices, (k, v) => setState(() => _prices[k] = v)),
          _PriceEditTile('Bandô', 'bando', _prices, (k, v) => setState(() => _prices[k] = v)),
          _PriceEditTile('Barra Estabilizadora', 'barraEstabilizadora', _prices, (k, v) => setState(() => _prices[k] = v)),
          _PriceEditTile('Guia Lateral', 'guiaLateral', _prices, (k, v) => setState(() => _prices[k] = v)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ Preços salvos!'), backgroundColor: AppColors.success)),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar Todos os Preços'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Novo Produto / Tecido'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome do Produto')),
          const SizedBox(height: 12),
          TextField(controller: priceCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Preço por m² (R\$)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Produto "${nameCtrl.text}" adicionado!')));
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TAB 4 — TECIDOS & CORES (CRUD completo)
// ============================================================
class _FabricsColorsAdminTab extends StatefulWidget {
  const _FabricsColorsAdminTab();
  @override
  State<_FabricsColorsAdminTab> createState() => _FabricsColorsAdminTabState();
}

class _FabricsColorsAdminTabState extends State<_FabricsColorsAdminTab> {
  FabricType _selectedFabric = FabricType.blackout;

  // Cores editáveis por tecido (cópia mutável das cores do modelo)
  late Map<FabricType, List<_EditableColor>> _fabricColors;

  @override
  void initState() {
    super.initState();
    _fabricColors = {};
    for (final fabric in FabricType.values) {
      _fabricColors[fabric] = fabric.availableColors
          .map((c) => _EditableColor(name: c.name, hex: c.hex))
          .toList();
    }
  }

  List<_EditableColor> get _colors => _fabricColors[_selectedFabric]!;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Seletor de tecido
      Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: FabricType.values.map((f) {
              final sel = f == _selectedFabric;
              final colorHex = f.colorHex.replaceAll('#', '');
              final col = Color(int.parse('FF$colorHex', radix: 16));
              return GestureDetector(
                onTap: () => setState(() => _selectedFabric = f),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.grey100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppColors.primary : AppColors.grey200),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: col, shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(f.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          color: sel ? Colors.white : AppColors.textPrimary,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        )),
                  ]),
                ),
              );
            }).toList(),
          ),
        ),
      ),

      // Cabeçalho
      Container(
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Cores de: ${_selectedFabric.displayName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text('${_colors.length} cor(es) cadastrada(s)',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ]),
          ),
          ElevatedButton.icon(
            onPressed: _addColor,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Nova Cor'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
          ),
        ]),
      ),

      // Lista de cores
      Expanded(
        child: _colors.isEmpty
            ? const Center(
                child: Text('Nenhuma cor cadastrada.\nToque em "Nova Cor" para adicionar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary)))
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _colors.length,
                itemBuilder: (_, i) {
                  final c = _colors[i];
                  Color col;
                  try {
                    final hex = c.hex.replaceAll('#', '').padLeft(6, '0');
                    col = Color(int.parse('FF$hex', radix: 16));
                  } catch (_) {
                    col = Colors.grey;
                  }
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey200),
                      boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
                    ),
                    child: Row(children: [
                      // Amostra de cor
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: col,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.grey200),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(c.hex, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ]),
                      ),
                      // Botão editar
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                        onPressed: () => _editColor(i),
                        tooltip: 'Editar',
                      ),
                      // Botão excluir
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                        onPressed: () => _deleteColor(i),
                        tooltip: 'Excluir',
                      ),
                    ]),
                  );
                },
              ),
      ),
    ]);
  }

  void _addColor() {
    final nameCtrl = TextEditingController();
    final hexCtrl = TextEditingController(text: '#');
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text('Nova Cor — ${_selectedFabric.displayName}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome da cor (ex: Azul Petróleo)'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: hexCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Código HEX (ex: #1A3A5C)',
                    hintText: '#RRGGBB',
                  ),
                  onChanged: (_) => setSt(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Builder(builder: (_) {
                Color preview = Colors.grey;
                try {
                  final h = hexCtrl.text.replaceAll('#', '').padLeft(6, '0');
                  if (h.length == 6) preview = Color(int.parse('FF$h', radix: 16));
                } catch (_) {}
                return Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: preview,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.grey300),
                  ),
                );
              }),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || hexCtrl.text.length < 4) return;
                setState(() => _colors.add(_EditableColor(
                  name: nameCtrl.text.trim(),
                  hex: hexCtrl.text.trim().startsWith('#')
                      ? hexCtrl.text.trim()
                      : '#${hexCtrl.text.trim()}',
                )));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cor "${nameCtrl.text}" adicionada!'),
                      backgroundColor: AppColors.success));
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editColor(int index) {
    final c = _colors[index];
    final nameCtrl = TextEditingController(text: c.name);
    final hexCtrl = TextEditingController(text: c.hex);
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Editar Cor'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome da cor'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: hexCtrl,
                  decoration: const InputDecoration(labelText: 'Código HEX'),
                  onChanged: (_) => setSt(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Builder(builder: (_) {
                Color preview = Colors.grey;
                try {
                  final h = hexCtrl.text.replaceAll('#', '').padLeft(6, '0');
                  if (h.length == 6) preview = Color(int.parse('FF$h', radix: 16));
                } catch (_) {}
                return Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: preview,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.grey300),
                  ),
                );
              }),
            ]),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _colors[index] = _EditableColor(
                    name: nameCtrl.text.trim(),
                    hex: hexCtrl.text.trim(),
                  );
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Cor atualizada!'), backgroundColor: AppColors.success));
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteColor(int index) {
    final name = _colors[index].name;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Cor'),
        content: Text('Deseja excluir a cor "$name"?\nEsta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() => _colors.removeAt(index));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cor "$name" excluída.'), backgroundColor: AppColors.error));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _EditableColor {
  String name;
  String hex;
  _EditableColor({required this.name, required this.hex});
}

// ============================================================
// TAB 5 — DETALHES DO PRODUTO (descrição, tagline, vantagens)
// Sincronizado via ProductDetailsProvider — edições aparecem
// imediatamente na tela de Detalhes do Produto.
// ============================================================
class _ProductDetailsAdminTab extends StatefulWidget {
  const _ProductDetailsAdminTab();
  @override
  State<_ProductDetailsAdminTab> createState() => _ProductDetailsAdminTabState();
}

class _ProductDetailsAdminTabState extends State<_ProductDetailsAdminTab> {
  ProductCategory _sel = ProductCategory.rolo;

  // Controllers locais para edição — preenchidos no initState e ao trocar categoria
  final TextEditingController _taglineCtrl = TextEditingController();
  final TextEditingController _descCtrl    = TextEditingController();
  final TextEditingController _advCtrl     = TextEditingController();
  final TextEditingController _waCtrl      = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromProvider());
  }

  void _loadFromProvider() {
    final p = context.read<ProductDetailsProvider>();
    _taglineCtrl.text = p.getTagline(_sel);
    _descCtrl.text    = p.getDescription(_sel);
    // Remove os "✓ " adicionados pelo getter de lista para edição limpa
    _advCtrl.text     = p.getAdvantages(_sel);
    _waCtrl.text      = p.whatsappNumber;
    setState(() {});
  }

  @override
  void dispose() {
    _taglineCtrl.dispose();
    _descCtrl.dispose();
    _advCtrl.dispose();
    _waCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final p = context.read<ProductDetailsProvider>();
    p.setTagline(_sel, _taglineCtrl.text.trim());
    p.setDescription(_sel, _descCtrl.text.trim());
    p.setAdvantages(_sel, _advCtrl.text.trim());
    p.setWhatsappNumber(_waCtrl.text.trim());
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('✅ Detalhes de "${_sel.displayName}" salvos! Visíveis no app imediatamente.'),
      backgroundColor: AppColors.success,
    ));
  }

  @override
  Widget build(BuildContext context) {
    // watch para atualizar preview em tempo real
    final detProv = context.watch<ProductDetailsProvider>();

    return Column(children: [
      // Seletor de categoria
      Container(
        color: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ProductCategory.values.map((cat) {
              final sel = cat == _sel;
              return GestureDetector(
                onTap: () {
                  setState(() => _sel = cat);
                  // Preenche controllers com os dados desta categoria
                  _taglineCtrl.text = detProv.getTagline(cat);
                  _descCtrl.text    = detProv.getDescription(cat);
                  _advCtrl.text     = detProv.getAdvantages(cat);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.grey100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(cat.shortName,
                      style: TextStyle(
                        fontSize: 12,
                        color: sel ? Colors.white : AppColors.textPrimary,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      )),
                ),
              );
            }).toList(),
          ),
        ),
      ),

      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Cabeçalho
            Row(children: [
              const Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('Editando: ${_sel.displayName}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
            ]),
            const SizedBox(height: 4),
            const Text('Textos exibidos na tela de detalhes do produto no app.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 16),

            // ── WhatsApp ──────────────────────────────────
            _TextEditCard(
              title: '📱 Número WhatsApp',
              subtitle: 'Número completo com DDI: 5561912345678',
              controller: _waCtrl,
              maxLines: 1,
              icon: Icons.phone_outlined,
            ),

            // ── Tagline ───────────────────────────────────
            _TextEditCard(
              title: '🏷️ Tagline / Subtítulo',
              subtitle: 'Frase curta abaixo do nome do produto',
              controller: _taglineCtrl,
              maxLines: 2,
              icon: Icons.label_outline,
            ),

            // ── Descrição ─────────────────────────────────
            _TextEditCard(
              title: '📝 Descrição Completa',
              subtitle: 'Texto de apresentação na tela de detalhes',
              controller: _descCtrl,
              maxLines: 8,
              icon: Icons.text_snippet_outlined,
            ),

            // ── Vantagens ─────────────────────────────────
            _TextEditCard(
              title: '✅ Vantagens (uma por linha)',
              subtitle: 'Lista de diferenciais — será exibida com "✓" automático',
              controller: _advCtrl,
              maxLines: 8,
              icon: Icons.check_circle_outline,
            ),

            // ── Preview ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.preview_outlined, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text('Pré-visualização (como aparece no app)',
                      style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 10),
                Text(_sel.displayName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(_taglineCtrl.text.isEmpty ? detProv.getTagline(_sel) : _taglineCtrl.text,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text(_descCtrl.text.isEmpty ? detProv.getDescription(_sel) : _descCtrl.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 8),
                // Mini lista de vantagens
                ...(_advCtrl.text.isEmpty
                    ? detProv.getAdvantagesList(_sel)
                    : _advCtrl.text
                        .split('\n')
                        .where((l) => l.trim().isNotEmpty)
                        .take(3)
                        .map((l) => '✓ ${l.trim()}')
                        .toList()
                ).map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(v,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                )),
              ]),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: Text('Salvar & Publicar — ${_sel.displayName}'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    ]);
  }
}

// ============================================================
// TAB 6 — MÍDIAS (Fotos e Vídeos)
// ============================================================
class _MediaAdminTab extends StatefulWidget {
  const _MediaAdminTab();
  @override
  State<_MediaAdminTab> createState() => _MediaAdminTabState();
}

class _MediaAdminTabState extends State<_MediaAdminTab> {
  final List<_MediaItem> _items = [
    _MediaItem('Banner Principal — Rolô Blackout', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', 'foto', 'banner'),
    _MediaItem('Persiana Romana em Sala', 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400', 'foto', 'produto'),
    _MediaItem('Double Vision — Escritório', 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=400', 'foto', 'produto'),
    _MediaItem('Como Instalar — Tutorial', '', 'video', 'educativo'),
    _MediaItem('Simulador de Medidas — Demo', '', 'video', 'educativo'),
  ];

  @override
  Widget build(BuildContext context) {
    final fotos = _items.where((m) => m.type == 'foto').toList();
    final videos = _items.where((m) => m.type == 'video').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: ElevatedButton.icon(
            onPressed: _addPhoto,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Adicionar Foto'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
          )),
          const SizedBox(width: 10),
          Expanded(child: OutlinedButton.icon(
            onPressed: _addVideo,
            icon: const Icon(Icons.video_library_outlined),
            label: const Text('Adicionar Vídeo'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
          )),
        ]),
        const SizedBox(height: 20),

        _SectionHeader('Fotos (${fotos.length})'),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1, crossAxisSpacing: 10, mainAxisSpacing: 10,
          children: fotos.map((item) => _MediaCard(
            item: item,
            onDelete: () => setState(() => _items.remove(item)),
            onEdit: () => _editItem(item),
          )).toList(),
        ),
        const SizedBox(height: 20),

        _SectionHeader('Vídeos (${videos.length})'),
        const SizedBox(height: 10),
        ...videos.map((item) => _VideoCard(
          item: item,
          onDelete: () => setState(() => _items.remove(item)),
          onEdit: () => _editItem(item),
        )),
        const SizedBox(height: 12),
        // Link YouTube rápido
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFCC80)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [
              Icon(Icons.ondemand_video_outlined, color: Color(0xFFE53935)),
              SizedBox(width: 8),
              Text('Link de Vídeo (YouTube / Vimeo)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Expanded(child: TextField(
                decoration: InputDecoration(
                  hintText: 'https://youtube.com/watch?v=...',
                  isDense: true, border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              )),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addVideo,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
                child: const Text('Add'),
              ),
            ]),
          ]),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  void _addPhoto() {
    final urlCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    String cat = 'produto';
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setSt) => AlertDialog(
        title: const Text('Adicionar Foto'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
          const SizedBox(height: 10),
          TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL da imagem')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: cat,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: const [
              DropdownMenuItem(value: 'banner', child: Text('Banner')),
              DropdownMenuItem(value: 'produto', child: Text('Produto')),
              DropdownMenuItem(value: 'educativo', child: Text('Educativo')),
            ],
            onChanged: (v) => setSt(() => cat = v ?? 'produto'),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() => _items.add(_MediaItem(titleCtrl.text, urlCtrl.text, 'foto', cat)));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto adicionada!')));
            },
            child: const Text('Adicionar'),
          ),
        ],
      )),
    );
  }

  void _addVideo() {
    final urlCtrl = TextEditingController();
    final titleCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar Vídeo'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título do vídeo')),
          const SizedBox(height: 10),
          TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL (YouTube, Vimeo...)')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() => _items.add(_MediaItem(titleCtrl.text, urlCtrl.text, 'video', 'educativo')));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vídeo adicionado!')));
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _editItem(_MediaItem item) {
    final titleCtrl = TextEditingController(text: item.title);
    final urlCtrl = TextEditingController(text: item.url);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar Mídia'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
          const SizedBox(height: 10),
          TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              setState(() { item.title = titleCtrl.text; item.url = urlCtrl.text; });
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TAB 7 — TEXTOS DO SITE
// ============================================================
class _TextsAdminTab extends StatefulWidget {
  const _TextsAdminTab();
  @override
  State<_TextsAdminTab> createState() => _TextsAdminTabState();
}

class _TextsAdminTabState extends State<_TextsAdminTab> {
  final Map<String, TextEditingController> _ctrl = {
    'whatsapp':   TextEditingController(text: AppConfig.whatsappNumber),
    'garantia':   TextEditingController(text: '5 anos de garantia contra defeitos de fabricação em todos os nossos produtos. A garantia cobre defeitos no mecanismo, tecido e estrutura.'),
    'sobre':      TextEditingController(text: 'A Control Persianas Online é especialista em persianas sob medida com mais de 10 anos de experiência. Trabalhamos diretamente com fabricantes para oferecer os melhores preços e qualidade garantida.'),
    'entrega':    TextEditingController(text: 'Prazo de produção: 7 a 10 dias úteis após confirmação do pagamento. Frete grátis acima de R\$ 500,00.'),
    'pagamento':  TextEditingController(text: 'Aceitamos PIX (5% de desconto), cartão de crédito em até 12x e boleto bancário. Pagamentos processados com segurança pelo Mercado Pago.'),
    'instalacao': TextEditingController(text: 'Nossos produtos são projetados para fácil instalação. Cada pedido vem com manual de instalação ilustrado.'),
    'banner':     TextEditingController(text: 'Persianas sob medida com qualidade garantida e entrega para todo o Brasil.'),
    'frete_gratis': TextEditingController(text: '500.00'),
  };

  @override
  void dispose() {
    for (final c in _ctrl.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Editar Textos do App', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        const Text('Altere os textos exibidos no aplicativo.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        _TextEditCard(title: '💬 WhatsApp de Contato', subtitle: 'Número completo: 556199999999',
            controller: _ctrl['whatsapp']!, maxLines: 1, icon: Icons.phone_outlined),
        _TextEditCard(title: '📢 Texto do Banner Principal', subtitle: 'Frase de impacto exibida no banner da home',
            controller: _ctrl['banner']!, maxLines: 3, icon: Icons.campaign_outlined),
        _TextEditCard(title: '💳 Valor Mínimo Frete Grátis (R\$)', subtitle: 'Valor em reais sem o símbolo, ex: 500.00',
            controller: _ctrl['frete_gratis']!, maxLines: 1, icon: Icons.local_shipping_outlined),
        _TextEditCard(title: '🛡️ Garantia', subtitle: 'Texto da política de garantia',
            controller: _ctrl['garantia']!, maxLines: 5, icon: Icons.verified_outlined),
        _TextEditCard(title: '🏢 Sobre Nós', subtitle: 'Apresentação da empresa',
            controller: _ctrl['sobre']!, maxLines: 5, icon: Icons.info_outline),
        _TextEditCard(title: '🚚 Prazo de Entrega', subtitle: 'Informações sobre entrega',
            controller: _ctrl['entrega']!, maxLines: 4, icon: Icons.local_shipping_outlined),
        _TextEditCard(title: '💳 Formas de Pagamento', subtitle: 'Métodos aceitos',
            controller: _ctrl['pagamento']!, maxLines: 4, icon: Icons.payment_outlined),
        _TextEditCard(title: '🔧 Instalação', subtitle: 'Orientações de instalação',
            controller: _ctrl['instalacao']!, maxLines: 4, icon: Icons.handyman_outlined),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Textos salvos!'), backgroundColor: AppColors.success)),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Salvar Todos os Textos'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ============================================================
// TAB 8 — RELATÓRIOS
// ============================================================
class _ReportsAdminTab extends StatelessWidget {
  const _ReportsAdminTab();

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;
    final totalRevenue = orders.fold<double>(0, (s, o) => s + o.subtotal + o.shippingCost);
    final totalOrders = orders.length;
    final avgTicket = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
    final totalM2 = orders.fold<double>(0, (s, o) =>
        s + o.items.fold<double>(0, (si, i) => si + i.config.billedArea));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Relatórios', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.4,
          children: [
            _StatCard(stat: _Stat('Receita Total', 'R\$ ${totalRevenue.toStringAsFixed(2)}', Icons.attach_money, AppColors.success)),
            _StatCard(stat: _Stat('Total de Pedidos', '$totalOrders', Icons.shopping_bag_outlined, AppColors.primary)),
            _StatCard(stat: _Stat('Ticket Médio', 'R\$ ${avgTicket.toStringAsFixed(2)}', Icons.receipt_long_outlined, const Color(0xFF7B1FA2))),
            _StatCard(stat: _Stat('m² Vendidos', '${totalM2.toStringAsFixed(1)} m²', Icons.straighten_outlined, const Color(0xFFE65100))),
          ],
        ),
        const SizedBox(height: 24),
        Text('Produtos Mais Pedidos', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...ProductCategory.values.asMap().entries.map((e) {
          final count = orders.fold<int>(0, (s, o) =>
              s + o.items.where((i) => i.config.category == e.value).length);
          final pct = totalOrders > 0 ? count / totalOrders : 0.0;
          final colors = [AppColors.primary, const Color(0xFF00897B), const Color(0xFF7B1FA2),
            const Color(0xFFE65100), const Color(0xFF546E7A)];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(e.value.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text('$count pedidos', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ]),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct, backgroundColor: AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation(colors[e.key % colors.length]),
                  minHeight: 8,
                ),
              ),
            ]),
          );
        }),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: const Row(children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            SizedBox(width: 10),
            Expanded(child: Text(
              'Para relatórios completos com gráficos e exportação PDF/Excel, conecte o backend.',
              style: TextStyle(fontSize: 12, color: AppColors.primary),
            )),
          ]),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}

// ============================================================
// WIDGETS AUXILIARES
// ============================================================
class _Stat {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _Stat stat;
  const _StatCard({required this.stat});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(stat.icon, color: stat.color, size: 20),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(stat.value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: stat.color)),
            Text(stat.label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey400),
        ]),
      ),
    );
  }
}

class _OrderMiniCard extends StatelessWidget {
  final Order order;
  const _OrderMiniCard({required this.order});
  @override
  Widget build(BuildContext context) {
    final statusColor = Color(int.parse('FF${order.status.colorHex.replaceAll("#", "")}', radix: 16));
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(children: [
        Container(
          width: 8, height: 40,
          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('#${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(order.status.displayName, style: TextStyle(fontSize: 11, color: statusColor)),
        ])),
        Text('R\$ ${(order.subtotal + order.shippingCost).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
      ]),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final Order order;
  const _AdminOrderCard({required this.order});
  @override
  Widget build(BuildContext context) {
    final orderProv = context.read<OrderProvider>();
    final statusColor = Color(int.parse('FF${order.status.colorHex.replaceAll("#", "")}', radix: 16));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('#${order.orderNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Spacer(),
          Text('R\$ ${(order.subtotal + order.shippingCost).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14)),
        ]),
        const SizedBox(height: 4),
        Text('${order.items.length} item(s) • ${order.paymentMethod}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(order.status.displayName,
                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const Spacer(),
          DropdownButton<OrderStatus>(
            value: order.status,
            underline: const SizedBox(),
            style: const TextStyle(fontSize: 12, color: AppColors.primary),
            hint: const Text('Alterar', style: TextStyle(fontSize: 12)),
            items: OrderStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.displayName))).toList(),
            onChanged: (s) {
              if (s != null) {
                orderProv.updateStatus(order.id, s);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Status: ${s.displayName}'), backgroundColor: AppColors.success));
              }
            },
          ),
        ]),
      ]),
    );
  }
}

class _CategoryPriceSection extends StatelessWidget {
  final ProductCategory category;
  final Map<String, double> prices;
  final void Function(String, double) onPriceChanged;
  const _CategoryPriceSection({required this.category, required this.prices, required this.onPriceChanged});
  @override
  Widget build(BuildContext context) {
    final fabrics = PricingModel.getFabricsForCategory(category);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionHeader(category.displayName),
      const SizedBox(height: 8),
      ...fabrics.map((f) {
        final key = '${category.name}_${f.name}';
        return _PriceEditTile(f.displayName, key, prices, onPriceChanged);
      }),
      const SizedBox(height: 8),
    ]);
  }
}

class _PriceEditTile extends StatelessWidget {
  final String label, priceKey;
  final Map<String, double> prices;
  final void Function(String, double) onChanged;
  const _PriceEditTile(this.label, this.priceKey, this.prices, this.onChanged);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        GestureDetector(
          onTap: () {
            final ctrl = TextEditingController(text: (prices[priceKey] ?? 0).toStringAsFixed(2));
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Editar: $label'),
                content: TextField(
                  controller: ctrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Preço por m² (R\$)', prefixText: 'R\$ '),
                  autofocus: true,
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                  ElevatedButton(
                    onPressed: () {
                      final v = double.tryParse(ctrl.text.replaceAll(',', '.'));
                      if (v != null) onChanged(priceKey, v);
                      Navigator.pop(context);
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('R\$ ${(prices[priceKey] ?? 0.0).toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 13, color: AppColors.primary),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
    );
  }
}

class _TextEditCard extends StatelessWidget {
  final String title, subtitle;
  final TextEditingController controller;
  final int maxLines;
  final IconData icon;
  const _TextEditCard({required this.title, required this.subtitle, required this.controller, required this.maxLines, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        ]),
        Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 10),
        TextField(
          controller: controller, maxLines: maxLines,
          decoration: const InputDecoration(
            border: OutlineInputBorder(), isDense: true,
            contentPadding: EdgeInsets.all(12),
          ),
        ),
      ]),
    );
  }
}

class _MediaItem {
  String title, url, type, category;
  _MediaItem(this.title, this.url, this.type, this.category);
}

class _MediaCard extends StatelessWidget {
  final _MediaItem item;
  final VoidCallback onDelete, onEdit;
  const _MediaCard({required this.item, required this.onDelete, required this.onEdit});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(fit: StackFit.expand, children: [
        item.url.isNotEmpty
            ? Image.network(item.url, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.grey200,
                    child: const Icon(Icons.image, color: AppColors.grey400, size: 40)))
            : Container(color: AppColors.grey200,
                child: const Icon(Icons.image, color: AppColors.grey400, size: 40)),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black.withValues(alpha: 0.6),
            child: Row(children: [
              Expanded(child: Text(item.title,
                  style: const TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis)),
              GestureDetector(onTap: onEdit, child: const Icon(Icons.edit, color: Colors.white70, size: 14)),
              const SizedBox(width: 8),
              GestureDetector(onTap: onDelete, child: const Icon(Icons.delete, color: Colors.redAccent, size: 14)),
            ]),
          ),
        ),
        Positioned(
          top: 6, right: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
            child: Text(item.category, style: const TextStyle(color: Colors.white, fontSize: 9)),
          ),
        ),
      ]),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final _MediaItem item;
  final VoidCallback onDelete, onEdit;
  const _VideoCard({required this.item, required this.onDelete, required this.onEdit});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.play_circle_outline, color: Color(0xFFE53935), size: 32),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title.isEmpty ? 'Sem título' : item.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(item.url.isEmpty ? 'Sem URL' : item.url,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis),
        ])),
        IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit, color: AppColors.primary),
        IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: onDelete, color: AppColors.error),
      ]),
    );
  }
}
