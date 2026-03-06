import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import 'cart_screen.dart';

// ============================================================
// SIMULADOR DE MEDIDAS — 6 passos + Resumo
// Passo 1: Modelo | 2: Tecido | 3: Cor | 4: Instalação
// Passo 5: Medidas | 6: Acessórios | Resumo Final
// ============================================================
class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});
  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  final PageController _pageController = PageController();

  final List<String> _stepTitles = [
    'Modelo de Persiana',
    'Tipo de Tecido',
    'Cor do Tecido',
    'Tipo de Instalação',
    'Medidas',
    'Acessórios',
    'Lado do Comando',
    'Resumo e Preço',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    final sim = context.read<SimulatorProvider>();
    final step = sim.currentStep;
    // Validações por passo
    if (step == 0 && sim.config.fabric == null) {
      // tecido ainda não escolhido — não bloqueia modelo
    }
    if (step < _stepTitles.length - 1) {
      sim.nextStep();
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _goPrev() {
    final sim = context.read<SimulatorProvider>();
    if (sim.currentStep > 0) {
      sim.prevStep();
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    final step = sim.currentStep.clamp(0, _stepTitles.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_stepTitles[step]),
        leading: step > 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goPrev)
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).maybePop()),
        actions: [
          // Botão rápido para o carrinho
          _CartBadgeButton(),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(step),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _StepModelo(),
                _StepTecido(),
                _StepCor(),
                _StepInstalacao(),
                _StepMedidas(),
                _StepAcessorios(),
                _StepLadoComando(),
                _StepResumo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int step) {
    const total = 8;
    final progress = (step + 1) / total;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Passo ${step + 1} de $total',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text('${(progress * 100).round()}% concluído',
                  style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.grey200,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botão carrinho na AppBar ──────────────────────────────────
class _CartBadgeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {
            // Navega para carrinho sem perder o simulador na pilha
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const _CartFromSimulator()),
            );
          },
        ),
        if (cart.totalQuantity > 0)
          Positioned(
            right: 6, top: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text('${cart.totalQuantity}',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }
}

// ── Wrapper para ir ao carrinho e depois conseguir voltar ────
class _CartFromSimulator extends StatelessWidget {
  const _CartFromSimulator();
  @override
  Widget build(BuildContext context) {
    return const CartScreen();
  }
}

// ============================================================
// PASSO 1 — MODELO
// ============================================================
class _StepModelo extends StatelessWidget {
  const _StepModelo();

  static const _modelImages = {
    ProductCategory.rolo:
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
    ProductCategory.romana:
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80',
    ProductCategory.doubleVision:
        'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=600&q=80',
    ProductCategory.painel:
        'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=600&q=80',
    ProductCategory.horizontal25mm:
        'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&q=80',
  };

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    return Column(children: [
      Container(
        color: AppColors.primary.withValues(alpha: 0.06),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: const Row(children: [
          Icon(Icons.blinds, color: AppColors.primary, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text('Selecione o modelo de persiana ideal para você',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ProductCategory.values.length,
          itemBuilder: (_, i) {
            final cat = ProductCategory.values[i];
            final sel = sim.config.category == cat;
            final fabrics = PricingModel.getFabricsForCategory(cat);
            final minPrice = fabrics
                .map((f) => PricingModel.getPricePerM2(cat, f) ?? 0)
                .reduce((a, b) => a < b ? a : b);

            return GestureDetector(
              onTap: () {
                sim.setCategory(cat);
                Future.delayed(const Duration(milliseconds: 200), () {
                  final simState = context.findAncestorStateOfType<_SimulatorScreenState>();
                  simState?._goNext();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: sel ? AppColors.primary : AppColors.grey200,
                    width: sel ? 2 : 1,
                  ),
                  boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
                ),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    // Imagem ilustrativa do modelo
                    SizedBox(
                      width: 110, height: 110,
                      child: Image.network(
                        _modelImages[cat] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.grey100,
                          child: const Icon(Icons.blinds, size: 40, color: AppColors.grey400),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text(cat.displayName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 15,
                                      color: sel ? AppColors.primary : AppColors.textPrimary,
                                    )),
                              ),
                              if (sel)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                                ),
                            ]),
                            const SizedBox(height: 4),
                            Text(cat.categoryDescription,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 6),
                            Text('A partir de R\$ ${minPrice.toStringAsFixed(2)}/m²',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child: Icon(Icons.chevron_right, color: AppColors.grey400),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

// ============================================================
// PASSO 2 — TECIDO
// ============================================================
class _StepTecido extends StatelessWidget {
  const _StepTecido();
  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    final fabrics = PricingModel.getFabricsForCategory(sim.config.category);

    return Column(children: [
      Container(
        color: AppColors.primary.withValues(alpha: 0.06),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          const Icon(Icons.texture, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Tecidos disponíveis para ${sim.config.category.shortName}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fabrics.length,
          itemBuilder: (_, i) {
            final fabric = fabrics[i];
            final sel = sim.config.fabric == fabric;
            final price = PricingModel.getPricePerM2(sim.config.category, fabric);
            final hexStr = fabric.colorHex.replaceAll('#', '');
            final swatch = Color(int.parse('FF$hexStr', radix: 16));

            return GestureDetector(
              onTap: () {
                sim.setFabric(fabric);
                Future.delayed(const Duration(milliseconds: 200), () {
                  final simState = context.findAncestorStateOfType<_SimulatorScreenState>();
                  simState?._goNext();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? AppColors.primary : AppColors.grey200,
                    width: sel ? 2 : 1,
                  ),
                  boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
                ),
                child: Row(children: [
                  // Swatch de cor do tecido
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: swatch,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.grey200),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(fabric.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14,
                            color: sel ? AppColors.primary : AppColors.textPrimary,
                          )),
                      const SizedBox(height: 2),
                      Text(fabric.lightBlock,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      // Mini paleta das cores disponíveis DESTE tecido
                      Row(children: [
                        ...fabric.availableColors.take(6).map((c) {
                          final h = c.hex.replaceAll('#', '').padLeft(6, '0');
                          final col = Color(int.parse('FF$h', radix: 16));
                          return Container(
                            width: 14, height: 14,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: col, shape: BoxShape.circle,
                              border: Border.all(color: Colors.black12),
                            ),
                          );
                        }),
                        if (fabric.availableColors.length > 6)
                          Text('+${fabric.availableColors.length - 6}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ]),
                    ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    if (price != null) ...[
                      const Text('a partir de', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                      Text('R\$ ${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                      const Text('/m²', style: TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                    ],
                    const SizedBox(height: 4),
                    if (sel)
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  ]),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

// ============================================================
// PASSO 3 — COR (vinculada ao tecido e modelo selecionado)
// ============================================================
class _StepCor extends StatelessWidget {
  const _StepCor();
  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    final fabric = sim.config.fabric;

    if (fabric == null) {
      return const Center(child: Text('Selecione um tecido antes.'));
    }

    // Cores SOMENTE do tecido selecionado para este modelo
    final colors = fabric.availableColors;

    return Column(children: [
      Container(
        color: AppColors.primary.withValues(alpha: 0.06),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          const Icon(Icons.palette_outlined, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Cores disponíveis para ${fabric.displayName} — ${sim.config.category.shortName}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ]),
      ),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: colors.length,
          itemBuilder: (_, i) {
            final c = colors[i];
            final hex = c.hex.replaceAll('#', '').padLeft(6, '0');
            final col = Color(int.parse('FF$hex', radix: 16));
            final sel = sim.config.fabricColor == c.name;

            return GestureDetector(
              onTap: () {
                sim.setFabricColor(c.name);
                Future.delayed(const Duration(milliseconds: 200), () {
                  final simState = context.findAncestorStateOfType<_SimulatorScreenState>();
                  simState?._goNext();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: sel ? AppColors.primary : AppColors.grey200,
                    width: sel ? 2.5 : 1,
                  ),
                  boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: col,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black12),
                          ),
                        ),
                        if (sel)
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black.withValues(alpha: 0.25),
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 28),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(c.name,
                          style: TextStyle(
                            fontSize: 10.5, fontWeight: FontWeight.w600,
                            color: sel ? AppColors.primary : AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center, maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

// ============================================================
// PASSO 4 — INSTALAÇÃO
// ============================================================
class _StepInstalacao extends StatelessWidget {
  const _StepInstalacao();
  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(children: [
            Icon(Icons.handyman_outlined, color: AppColors.primary),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'O tipo de instalação afeta as medidas. Escolha com cuidado.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        ...InstallationType.values.map((inst) {
          final sel = sim.config.installation == inst;
          return GestureDetector(
            onTap: () {
              sim.setInstallation(inst);
              Future.delayed(const Duration(milliseconds: 200), () {
                final simState = context.findAncestorStateOfType<_SimulatorScreenState>();
                simState?._goNext();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary.withValues(alpha: 0.06) : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: sel ? AppColors.primary : AppColors.grey200,
                  width: sel ? 2 : 1,
                ),
                boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: (sel ? AppColors.primary : AppColors.grey400).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.straighten_outlined,
                      color: sel ? AppColors.primary : AppColors.grey500),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(inst.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14,
                          color: sel ? AppColors.primary : AppColors.textPrimary,
                        )),
                    const SizedBox(height: 3),
                    Text(inst.description,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 3),
                    Text('💡 ${inst.measureTip}',
                        style: const TextStyle(fontSize: 11, color: AppColors.primary)),
                  ]),
                ),
                if (sel)
                  const Icon(Icons.check_circle, color: AppColors.primary),
              ]),
            ),
          );
        }),
      ]),
    );
  }
}

// ============================================================
// PASSO 5 — MEDIDAS
// ============================================================
class _StepMedidas extends StatefulWidget {
  const _StepMedidas();
  @override
  State<_StepMedidas> createState() => _StepMedidasState();
}

class _StepMedidasState extends State<_StepMedidas> {
  final _wCtrl = TextEditingController();
  final _hCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sim = context.read<SimulatorProvider>();
      if (sim.config.width != null) _wCtrl.text = sim.config.width!.toStringAsFixed(2);
      if (sim.config.height != null) _hCtrl.text = sim.config.height!.toStringAsFixed(2);
    });
  }

  @override
  void dispose() {
    _wCtrl.dispose();
    _hCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    final cfg = sim.config;
    final w = double.tryParse(_wCtrl.text.replaceAll(',', '.')) ?? 0;
    final h = double.tryParse(_hCtrl.text.replaceAll(',', '.')) ?? 0;
    final area = w * h;
    final billedArea = area < 1.5 && area > 0 ? 1.5 : area;
    final price = cfg.pricePerM2 != null ? billedArea * cfg.pricePerM2! : 0.0;
    final exceedsWidth = w > cfg.category.maxWidth && w > 0;
    final exceedsHeight = h > 3.0 && h > 0;
    final exceedsArea = area > 5.0;
    final hasError = exceedsWidth || exceedsHeight || exceedsArea;
    final readyToAdvance = w > 0 && h > 0 && !hasError;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Dica de instalação
        if (cfg.installation != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text('💡 ${cfg.installation!.measureTip}',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary)),
              ),
            ]),
          ),

        // Diagrama visual da janela
        _WindowDiagram(width: w, height: h),
        const SizedBox(height: 20),

        // Campos de medida
        Text('Largura (metros)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        _MeasureField(
          controller: _wCtrl,
          hint: 'ex: 1.20',
          suffix: 'm',
          error: exceedsWidth ? 'Máximo ${cfg.category.maxWidth.toStringAsFixed(2)} m para ${cfg.category.shortName}' : null,
          onChanged: (v) {
            final val = double.tryParse(v.replaceAll(',', '.'));
            if (val != null) sim.setWidth(val);
            setState(() {});
          },
        ),
        const SizedBox(height: 14),
        Text('Altura (metros)', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        _MeasureField(
          controller: _hCtrl,
          hint: 'ex: 1.60',
          suffix: 'm',
          error: exceedsHeight ? 'Máximo 3,00 m de altura' : null,
          onChanged: (v) {
            final val = double.tryParse(v.replaceAll(',', '.'));
            if (val != null) sim.setHeight(val);
            setState(() {});
          },
        ),
        const SizedBox(height: 20),

        // Card de cálculo em tempo real
        if (area > 0)
          _PriceCard(
            area: area, billedArea: billedArea,
            priceM2: cfg.pricePerM2 ?? 0,
            totalPrice: price,
            exceedsArea: exceedsArea,
            shouldSplitSuggest: w > 2.40,
          ),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: readyToAdvance
                ? () {
                    final simState = context.findAncestorStateOfType<_SimulatorScreenState>();
                    simState?._goNext();
                  }
                : null,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Continuar para Acessórios', style: TextStyle(fontSize: 15)),
          ),
        ),
      ]),
    );
  }
}

// ============================================================
// PASSO 6 — ACESSÓRIOS
// ============================================================
class _StepAcessorios extends StatelessWidget {
  const _StepAcessorios();
  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    final cfg = sim.config;
    final w = cfg.width ?? 1.0;
    final h = cfg.height ?? 1.0;

    return Column(children: [
      Container(
        color: AppColors.primary.withValues(alpha: 0.06),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: const Row(children: [
          Icon(Icons.add_box_outlined, color: AppColors.primary, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text('Selecione os acessórios opcionais para sua persiana',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
        ]),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...AccessoryType.values.map((acc) {
              final sel = cfg.accessories.contains(acc);
              final realPrice = acc.calculatePrice(w, h);
              return GestureDetector(
                onTap: () => sim.toggleAccessory(acc),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary.withValues(alpha: 0.06) : AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: sel ? AppColors.primary : AppColors.grey200,
                      width: sel ? 2 : 1,
                    ),
                    boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
                  ),
                  child: Row(children: [
                    Text(acc.icon, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(acc.displayName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14,
                              color: sel ? AppColors.primary : AppColors.textPrimary,
                            )),
                        const SizedBox(height: 2),
                        Text(acc.description,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        // Preço calculado com as medidas reais
                        if (acc.isPerMeter)
                          Text(
                            'R\$ ${realPrice.toStringAsFixed(2)} (calculado pelas medidas)',
                            style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                          )
                        else
                          Text('R\$ ${realPrice.toStringAsFixed(2)} (valor fixo)',
                              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                    Checkbox(
                      value: sel,
                      activeColor: AppColors.primary,
                      onChanged: (_) => sim.toggleAccessory(acc),
                    ),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final simState = context.findAncestorStateOfType<_SimulatorScreenState>();
                  simState?._goNext();
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Ver Resumo e Preço Final', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

// ============================================================
// PASSO 7 — LADO DO COMANDO / MOTOR
// ============================================================
class _StepLadoComando extends StatelessWidget {
  const _StepLadoComando();

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    final selected = sim.config.commandSide;
    final hasMotor = sim.config.accessories.contains(AccessoryType.motorWifi);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info sobre o que é o lado do comando
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasMotor
                      ? 'Informe de qual lado ficará o motor WiFi ao olhar para a persiana instalada.'
                      : 'Informe de qual lado ficará a corrente de acionamento ao olhar para a persiana instalada.',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // Ilustração visual do lado
          _CommandSideIllustration(
            selected: selected,
            hasMotor: hasMotor,
            onSelect: (side) => sim.setCommandSide(side),
          ),

          const SizedBox(height: 24),

          // Cards de seleção
          ...CommandSide.values.map((side) {
            final isSel = selected == side;
            return GestureDetector(
              onTap: () {
                sim.setCommandSide(side);
                Future.delayed(const Duration(milliseconds: 250), () {
                  final simState = context.findAncestorStateOfType<_SimulatorScreenState>();
                  simState?._goNext();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.primary.withValues(alpha: 0.06) : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel ? AppColors.primary : AppColors.grey200,
                    width: isSel ? 2 : 1,
                  ),
                  boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
                ),
                child: Row(children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: (isSel ? AppColors.primary : AppColors.grey400).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      side.icon,
                      color: isSel ? AppColors.primary : AppColors.grey500,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(
                            'Comando ${side.displayName}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isSel ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                          if (side == CommandSide.right) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Mais comum',
                                  style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ]),
                        const SizedBox(height: 4),
                        Text(side.description,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        if (hasMotor) ...[
                          const SizedBox(height: 4),
                          Text('Motor WiFi no lado ${side.displayName.toLowerCase()}',
                              style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ],
                    ),
                  ),
                  if (isSel)
                    const Icon(Icons.check_circle, color: AppColors.primary),
                ]),
              ),
            );
          }),

          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dica: observe a posição da janela em relação à parede e passagem. '
                    'Geralmente o lado oposto à parede mais próxima é o mais conveniente.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF795548)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ilustração visual interativa do lado do comando ──────────
class _CommandSideIllustration extends StatelessWidget {
  final CommandSide selected;
  final bool hasMotor;
  final ValueChanged<CommandSide> onSelect;

  const _CommandSideIllustration({
    required this.selected,
    required this.hasMotor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          const Text('Toque para selecionar o lado',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Row(
            children: [
              // Lado esquerdo
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(CommandSide.left),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected == CommandSide.left
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected == CommandSide.left
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(children: [
                      Icon(hasMotor ? Icons.electrical_services : Icons.link,
                          color: selected == CommandSide.left
                              ? AppColors.primary
                              : AppColors.grey400,
                          size: 22),
                      const SizedBox(height: 4),
                      Text(hasMotor ? 'Motor' : 'Corrente',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: selected == CommandSide.left
                                ? AppColors.primary
                                : AppColors.grey400,
                          )),
                    ]),
                  ),
                ),
              ),

              // Persiana (centro)
              Expanded(
                flex: 3,
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Stack(
                    children: [
                      // Ripas horizontais simuladas
                      ...List.generate(5, (i) => Positioned(
                        top: 8.0 + i * 14,
                        left: 4,
                        right: 4,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      )),
                      Center(
                        child: Text('Persiana',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary.withValues(alpha: 0.6),
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  ),
                ),
              ),

              // Lado direito
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(CommandSide.right),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected == CommandSide.right
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected == CommandSide.right
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(children: [
                      Icon(hasMotor ? Icons.electrical_services : Icons.link,
                          color: selected == CommandSide.right
                              ? AppColors.primary
                              : AppColors.grey400,
                          size: 22),
                      const SizedBox(height: 4),
                      Text(hasMotor ? 'Motor' : 'Corrente',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: selected == CommandSide.right
                                ? AppColors.primary
                                : AppColors.grey400,
                          )),
                    ]),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('← Esquerdo',
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: selected == CommandSide.left ? AppColors.primary : AppColors.grey400,
                  )),
              Text('Direito →',
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: selected == CommandSide.right ? AppColors.primary : AppColors.grey400,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PASSO 8 — RESUMO E PREÇO FINAL
// ============================================================
class _StepResumo extends StatelessWidget {
  const _StepResumo();

  String _formatVal(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    final cart = context.read<CartProvider>();
    final cfg = sim.config;

    // Verifica se a configuração é válida
    final isComplete = cfg.fabric != null
        && cfg.installation != null
        && (cfg.width ?? 0) > 0
        && (cfg.height ?? 0) > 0;

    final w = cfg.width ?? 0;
    final h = cfg.height ?? 0;
    final area = w * h;
    final billedArea = area < 1.5 && area > 0 ? 1.5 : area;
    final priceM2 = cfg.pricePerM2 ?? 0;
    final basePrice = billedArea * priceM2;
    final accPrice = cfg.accessoriesPrice;
    final totalPrice = basePrice + accPrice;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Cabeçalho ────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF0D47A1)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            const Icon(Icons.receipt_long_outlined, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Resumo da Configuração',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(isComplete ? 'Configuração completa ✓' : '⚠️ Configure todos os passos antes de continuar',
                    style: TextStyle(
                        color: isComplete ? Colors.white70 : Colors.yellowAccent,
                        fontSize: 12)),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Detalhes da configuração ─────────────────────────
        _ResumoSection('Produto', [
          _ResumoRow('Modelo', cfg.category.displayName),
          _ResumoRow('Tecido', cfg.fabric?.displayName ?? '—'),
          _ResumoRow('Cor', cfg.fabricColor ?? '—'),
          _ResumoRow('Instalação', cfg.installation?.displayName ?? '—'),
          _ResumoRow('Lado do Comando', 'Lado ${cfg.commandSide.displayName}'),
        ]),
        const SizedBox(height: 12),

        // ── Medidas ──────────────────────────────────────────
        _ResumoSection('Medidas', [
          _ResumoRow('Largura', w > 0 ? '${w.toStringAsFixed(2)} m' : '—'),
          _ResumoRow('Altura', h > 0 ? '${h.toStringAsFixed(2)} m' : '—'),
          _ResumoRow('Área real', area > 0 ? '${area.toStringAsFixed(3)} m²' : '—'),
          if (area > 0 && area < 1.5)
            _ResumoRow('Área cobrada (mínimo)', '${billedArea.toStringAsFixed(2)} m²',
                highlight: true),
        ]),
        const SizedBox(height: 12),

        // ── Preços ────────────────────────────────────────────
        _ResumoSection('Composição do Preço', [
          _ResumoRow('Preço/m²', priceM2 > 0 ? _formatVal(priceM2) : '—'),
          _ResumoRow('Persiana (${billedArea.toStringAsFixed(2)} m²)', basePrice > 0 ? _formatVal(basePrice) : '—'),
          if (cfg.accessories.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...cfg.accessories.map((acc) {
              final p = acc.calculatePrice(w > 0 ? w : 1, h > 0 ? h : 1);
              return _ResumoRow('+ ${acc.displayName}', _formatVal(p));
            }),
          ],
        ]),
        const SizedBox(height: 8),

        // ── Total ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL ESTIMADO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                totalPrice > 0 ? _formatVal(totalPrice) : 'Preencha as medidas',
                style: TextStyle(
                  color: totalPrice > 0 ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.bold, fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text('* Frete não incluído. Parcelamento em até 12x no cartão.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 24),

        // ── Ações ─────────────────────────────────────────────
        if (isComplete && totalPrice > 0) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Adicionar ao Carrinho', style: TextStyle(fontSize: 15)),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              onPressed: () {
                cart.addItem(cfg);
                _showAddedDialog(context, totalPrice);
              },
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: const Text('Nova Configuração'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () {
                sim.reset();
                final ctrl = context.findAncestorStateOfType<_SimulatorScreenState>()?._pageController;
                ctrl?.jumpToPage(0);
              },
            ),
          ),
        ] else
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
            ),
            child: const Row(children: [
              Icon(Icons.warning_amber_outlined, color: Colors.orange),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Complete todos os passos anteriores para adicionar ao carrinho.',
                  style: TextStyle(fontSize: 13, color: Colors.orange),
                ),
              ),
            ]),
          ),
        const SizedBox(height: 24),
      ]),
    );
  }

  void _showAddedDialog(BuildContext context, double total) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.check_circle, color: AppColors.success, size: 28),
          SizedBox(width: 10),
          Text('Produto adicionado!'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')} adicionado ao carrinho.',
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          const Text('Deseja continuar comprando ou ir ao carrinho?',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ]),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              // Resetar e voltar ao passo 1 para nova configuração
              final sim = context.read<SimulatorProvider>();
              sim.reset();
              final ctrl = context.findAncestorStateOfType<_SimulatorScreenState>()?._pageController;
              ctrl?.jumpToPage(0);
            },
            child: const Text('Nova Persiana'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.shopping_cart, size: 16),
            label: const Text('Ir ao Carrinho'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              // Navega direto para a CartScreen como nova rota (funciona corretamente)
              Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: false,
                  builder: (_) => const CartScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares do resumo ─────────────────────────────

class _ResumoSection extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _ResumoSection(this.title, this.rows);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
        const SizedBox(height: 8),
        const Divider(height: 1),
        const SizedBox(height: 8),
        ...rows,
      ]),
    );
  }
}

class _ResumoRow extends StatelessWidget {
  final String label, value;
  final bool highlight;
  const _ResumoRow(this.label, this.value, {this.highlight = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
                color: highlight ? AppColors.primary : AppColors.textPrimary,
              )),
        ],
      ),
    );
  }
}

// ── Diagrama de janela ────────────────────────────────────────
class _WindowDiagram extends StatelessWidget {
  final double width, height;
  const _WindowDiagram({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final hasSize = width > 0 && height > 0;
    final ratio = hasSize ? (width / height).clamp(0.3, 3.0) : 1.0;
    final boxH = 120.0;
    final boxW = (boxH * ratio).clamp(60.0, 240.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(children: [
        const Text('Visualização proporcional', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: boxW, height: boxH,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (hasSize)
                  Text('${width.toStringAsFixed(2)}m × ${height.toStringAsFixed(2)}m',
                      style: const TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
              ]),
            ),
          ),
        ),
        if (hasSize) ...[
          const SizedBox(height: 6),
          Text(
            'Área: ${(width * height).toStringAsFixed(3)} m²  |  '
            'Mínimo cobrado: ${(width * height < 1.5 ? 1.5 : width * height).toStringAsFixed(2)} m²',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ]),
    );
  }
}

// ── Campo de medida ───────────────────────────────────────────
class _MeasureField extends StatelessWidget {
  final TextEditingController controller;
  final String hint, suffix;
  final String? error;
  final ValueChanged<String> onChanged;
  const _MeasureField({
    required this.controller, required this.hint,
    required this.suffix, required this.onChanged, this.error,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d,.]'))],
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        errorText: error,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      onChanged: onChanged,
    );
  }
}

// ── Price card ────────────────────────────────────────────────
class _PriceCard extends StatelessWidget {
  final double area, billedArea, priceM2, totalPrice;
  final bool exceedsArea, shouldSplitSuggest;
  const _PriceCard({
    required this.area, required this.billedArea,
    required this.priceM2, required this.totalPrice,
    required this.exceedsArea, required this.shouldSplitSuggest,
  });

  @override
  Widget build(BuildContext context) {
    if (exceedsArea) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        ),
        child: const Row(children: [
          Icon(Icons.error_outline, color: AppColors.error),
          SizedBox(width: 10),
          Expanded(
            child: Text('Área máxima é 5,00 m². Divida em 2 ou mais persianas.',
                style: TextStyle(color: AppColors.error, fontSize: 13)),
          ),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.calculate_outlined, color: AppColors.success, size: 18),
          SizedBox(width: 8),
          Text('Cálculo em tempo real',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.success)),
        ]),
        const SizedBox(height: 10),
        _Row('Área real:', '${area.toStringAsFixed(3)} m²'),
        if (area < 1.5) _Row('Área mínima cobrada:', '1,50 m²', highlight: true),
        _Row('Preço/m²:', 'R\$ ${priceM2.toStringAsFixed(2)}'),
        const Divider(height: 16),
        _Row('Estimativa:', 'R\$ ${totalPrice.toStringAsFixed(2)}', bigger: true),
        if (shouldSplitSuggest) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '💡 Largura > 2,40m: considere dividir em 2 persianas para melhor resultado.',
              style: TextStyle(fontSize: 11, color: Color(0xFF795548)),
            ),
          ),
        ],
      ]),
    );
  }

  Widget _Row(String label, String value, {bool highlight = false, bool bigger = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value,
            style: TextStyle(
              fontSize: bigger ? 15 : 12,
              fontWeight: highlight || bigger ? FontWeight.bold : FontWeight.w600,
              color: bigger ? AppColors.primary : AppColors.textPrimary,
            )),
      ]),
    );
  }
}


