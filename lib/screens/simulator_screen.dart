import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/common_widgets.dart';
import 'cart_screen.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});
  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  final PageController _pageController = PageController();

  final List<String> _stepTitles = [
    'Escolha o Ambiente',
    'Modelo de Persiana',
    'Tecido e Cor',
    'Tipo de Instalação',
    'Insira as Medidas',
    'Acessórios',
    'Resumo e Preço',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    final step = sim.currentStep;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_stepTitles[step.clamp(0, _stepTitles.length - 1)]),
        leading: step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  sim.prevStep();
                  _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
              )
            : null,
        actions: [
          TextButton(
            onPressed: () {
              sim.reset();
              _pageController.jumpToPage(0);
            },
            child: const Text('Reiniciar', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(step),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StepAmbiente(onNext: () => _nextPage(sim)),
                _StepModelo(onNext: () => _nextPage(sim)),
                _StepTecido(onNext: () => _nextPage(sim)),
                _StepInstalacao(onNext: () => _nextPage(sim)),
                _StepMedidas(onNext: () => _nextPage(sim)),
                _StepAcessorios(onNext: () => _nextPage(sim)),
                _StepResumo(onAddToCart: _addToCart),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int step) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: List.generate(_stepTitles.length, (i) {
              final done = i < step;
              final current = i == step;
              return Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? AppColors.success
                            : current
                                ? AppColors.primary
                                : AppColors.grey200,
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: current ? Colors.white : AppColors.grey500,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    if (i < _stepTitles.length - 1)
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
          ),
          const SizedBox(height: 6),
          Text(
            'Passo ${step + 1} de ${_stepTitles.length}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _nextPage(SimulatorProvider sim) {
    sim.nextStep();
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _addToCart(BuildContext context) {
    final sim = context.read<SimulatorProvider>();
    final cart = context.read<CartProvider>();
    cart.addItem(sim.config);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Persiana adicionada ao carrinho!'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'Ver Carrinho',
          textColor: Colors.white,
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const CartScreen())),
        ),
      ),
    );
    sim.reset();
    _pageController.jumpToPage(0);
  }
}

// ============================================================
// STEP 1 — AMBIENTE
// ============================================================
class _StepAmbiente extends StatelessWidget {
  final VoidCallback onNext;
  const _StepAmbiente({required this.onNext});

  static const List<Map<String, dynamic>> _ambientes = [
    {'label': 'Sala de Estar', 'icon': Icons.weekend_outlined, 'color': Color(0xFF1565C0)},
    {'label': 'Quarto', 'icon': Icons.bed_outlined, 'color': Color(0xFF6A1B9A)},
    {'label': 'Escritório', 'icon': Icons.business_center_outlined, 'color': Color(0xFF00695C)},
    {'label': 'Cozinha', 'icon': Icons.kitchen_outlined, 'color': Color(0xFFE65100)},
    {'label': 'Banheiro', 'icon': Icons.bathtub_outlined, 'color': Color(0xFF0277BD)},
    {'label': 'Varanda', 'icon': Icons.deck_outlined, 'color': Color(0xFF2E7D32)},
    {'label': 'Área Comercial', 'icon': Icons.store_outlined, 'color': Color(0xFF37474F)},
    {'label': 'Outro', 'icon': Icons.home_outlined, 'color': Color(0xFF757575)},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Para qual ambiente?',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          const Text('Isso nos ajuda a recomendar o melhor modelo',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _ambientes.length,
            itemBuilder: (context, i) {
              final a = _ambientes[i];
              return GestureDetector(
                onTap: onNext,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.grey200),
                    boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (a['color'] as Color).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(a['icon'] as IconData,
                            color: a['color'] as Color, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(a['label'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STEP 2 — MODELO
// ============================================================
class _StepModelo extends StatelessWidget {
  final VoidCallback onNext;
  const _StepModelo({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Qual modelo?', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          const Text('Selecione o tipo de persiana ideal',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 20),
          ...ProductCategory.values.map((cat) {
            return GestureDetector(
              onTap: () {
                context.read<SimulatorProvider>().setCategory(cat);
                onNext();
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.grey200),
                  boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        cat.imageNetwork,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: AppColors.grey100,
                            child: const Icon(Icons.blinds,
                                color: AppColors.grey400)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat.displayName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            'Largura máx: ${cat.maxWidth.toStringAsFixed(2)} m',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.grey400),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// STEP 3 — TECIDO E COR
// ============================================================
class _StepTecido extends StatefulWidget {
  final VoidCallback onNext;
  const _StepTecido({required this.onNext});
  @override
  State<_StepTecido> createState() => _StepTecidoState();
}

class _StepTecidoState extends State<_StepTecido> {
  FabricType? _selectedFabric;
  FabricColor? _selectedColor;

  bool get _canProceed => _selectedFabric != null && _selectedColor != null;

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    final fabrics = PricingModel.getFabricsForCategory(sim.config.category);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Título ──
                Text('Tecido e Cor',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                const Text('Selecione o tecido e depois escolha a cor',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 20),

                // ── Lista de tecidos ──
                Text('1. Escolha o Tecido',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                ...fabrics.map((fabric) {
                  final price = PricingModel.getPricePerM2(sim.config.category, fabric) ?? 0;
                  final isSelected = _selectedFabric == fabric;

                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedFabric = fabric;
                      _selectedColor = null; // reset cor ao trocar tecido
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.grey200,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Swatches das primeiras 4 cores disponíveis
                              SizedBox(
                                width: 72,
                                height: 44,
                                child: Stack(
                                  children: fabric.availableColors.take(4).toList().asMap().entries.map((e) {
                                    return Positioned(
                                      left: e.key * 16.0,
                                      child: Container(
                                        width: 36,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: e.value.color,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.white, width: 1.5),
                                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(fabric.displayName,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(fabric.lightBlock,
                                              style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w500)),
                                        ),
                                        const SizedBox(width: 6),
                                        Text('${fabric.availableColors.length} cores',
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
                                      style: const TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const Text('por m²',
                                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                ],
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                              ],
                            ],
                          ),

                          // ── Seletor de cores (aparece ao selecionar o tecido) ──
                          if (isSelected) ...[
                            const SizedBox(height: 14),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            Text('2. Escolha a Cor',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: fabric.availableColors.map((fc) {
                                final isCor = _selectedColor?.name == fc.name;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedColor = fc),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isCor ? AppColors.primary.withValues(alpha: 0.08) : AppColors.grey100,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isCor ? AppColors.primary : AppColors.grey200,
                                        width: isCor ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: fc.color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isCor ? AppColors.primary : AppColors.grey300,
                                              width: isCor ? 2 : 1,
                                            ),
                                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3)],
                                          ),
                                          child: isCor
                                              ? Icon(Icons.check,
                                                  size: 14,
                                                  color: fc.color.computeLuminance() > 0.5
                                                      ? Colors.black87
                                                      : Colors.white)
                                              : null,
                                        ),
                                        const SizedBox(width: 7),
                                        Text(fc.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isCor ? FontWeight.w600 : FontWeight.normal,
                                              color: isCor ? AppColors.primary : AppColors.textPrimary,
                                            )),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                            // Preview da cor selecionada
                            if (_selectedColor != null) ...[
                              const SizedBox(height: 14),
                              Container(
                                width: double.infinity,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: _selectedColor!.color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.grey300),
                                  boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${fabric.displayName} — ${_selectedColor!.name}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // ── Barra inferior com status ──
        Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicadores de seleção
              Row(
                children: [
                  _SelectionBadge(
                    label: _selectedFabric?.displayName ?? 'Tecido não selecionado',
                    done: _selectedFabric != null,
                    icon: Icons.texture,
                  ),
                  const SizedBox(width: 8),
                  _SelectionBadge(
                    label: _selectedColor?.name ?? 'Cor não selecionada',
                    done: _selectedColor != null,
                    icon: Icons.palette_outlined,
                    color: _selectedColor?.color,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: _canProceed ? 'Continuar' : 'Selecione tecido e cor',
                  onPressed: _canProceed
                      ? () {
                          context.read<SimulatorProvider>().setFabric(_selectedFabric!);
                          context.read<SimulatorProvider>().setFabricColor(_selectedColor!.name);
                          widget.onNext();
                        }
                      : null,
                  icon: Icons.arrow_forward,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectionBadge extends StatelessWidget {
  final String label;
  final bool done;
  final IconData icon;
  final Color? color;
  const _SelectionBadge({required this.label, required this.done, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: done
              ? AppColors.success.withValues(alpha: 0.08)
              : AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: done ? AppColors.success.withValues(alpha: 0.4) : AppColors.grey200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null)
              Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.grey300),
                ),
              )
            else
              Icon(icon, size: 14, color: done ? AppColors.success : AppColors.grey400),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: done ? FontWeight.w600 : FontWeight.normal,
                  color: done ? AppColors.success : AppColors.grey500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (done) ...[
              const SizedBox(width: 4),
              const Icon(Icons.check_circle, size: 12, color: AppColors.success),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// STEP 4 — INSTALAÇÃO
// ============================================================
class _StepInstalacao extends StatefulWidget {
  final VoidCallback onNext;
  const _StepInstalacao({required this.onNext});
  @override
  State<_StepInstalacao> createState() => _StepInstalacaoState();
}

class _StepInstalacaoState extends State<_StepInstalacao> {
  InstallationType? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tipo de Instalação',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                const Text(
                    'Como a persiana será instalada na sua janela?',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 20),
                ...InstallationType.values.map((type) {
                  final isSelected = _selected == type;
                  return GestureDetector(
                    onTap: () => setState(() => _selected = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.grey200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (isSelected
                                      ? AppColors.primary
                                      : AppColors.grey400)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.window_outlined,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.grey500,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(type.displayName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                Text(type.description,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.lightbulb_outline,
                                          size: 12, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(type.measureTip,
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.primary)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: AppColors.primary),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        _BottomActionBar(
          enabled: _selected != null,
          onNext: () {
            if (_selected != null) {
              context
                  .read<SimulatorProvider>()
                  .setInstallation(_selected!);
              widget.onNext();
            }
          },
        ),
      ],
    );
  }
}

// ============================================================
// STEP 5 — MEDIDAS
// ============================================================
class _StepMedidas extends StatefulWidget {
  final VoidCallback onNext;
  const _StepMedidas({required this.onNext});
  @override
  State<_StepMedidas> createState() => _StepMedidasState();
}

class _StepMedidasState extends State<_StepMedidas> {
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  double _width = 0;
  double _height = 0;
  String? _widthError;
  String? _heightError;

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _validate() {
    final sim = context.read<SimulatorProvider>();
    final cat = sim.config.category;
    setState(() {
      _widthError = null;
      _heightError = null;
      if (_width <= 0) {
        _widthError = 'Informe a largura';
      } else if (_width > cat.maxWidth) {
        _widthError =
            'Para medidas maiores consulte nosso atendimento.\nMáx: ${cat.maxWidth.toStringAsFixed(2)} m';
      }
      if (_height <= 0) {
        _heightError = 'Informe a altura';
      } else if (_height > SimulatorConfig.maxHeight) {
        _heightError =
            'Para medidas maiores consulte nosso atendimento.\nMáx: 3,00 m';
      }
      if (_width > 0 && _height > 0) {
        final area = _width * _height;
        if (area > SimulatorConfig.maxArea) {
          _widthError =
              'Para medidas maiores consulte nosso atendimento.\nÁrea máx: 5,00 m²';
        }
      }
    });
  }

  bool get _isValid =>
      _width > 0 &&
      _height > 0 &&
      _widthError == null &&
      _heightError == null;

  SimulatorConfig get _previewConfig {
    final sim = context.read<SimulatorProvider>();
    return sim.config.copyWith(width: _width > 0 ? _width : null, height: _height > 0 ? _height : null);
  }

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    final cat = sim.config.category;
    final area = _width * _height;
    final billedArea = area < SimulatorConfig.minArea ? SimulatorConfig.minArea : area;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Medidas da Janela',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                const Text(
                    'Insira as medidas em metros (ex: 1.20)',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 20),

                // Diagrama visual da janela
                _WindowDiagram(
                  width: _width,
                  height: _height,
                  maxWidth: cat.maxWidth,
                ),
                const SizedBox(height: 20),

                // Campos de medida
                Row(
                  children: [
                    Expanded(
                      child: _MeasureField(
                        controller: _widthController,
                        label: 'Largura (m)',
                        hint: '0.00',
                        icon: Icons.swap_horiz,
                        error: _widthError,
                        onChanged: (v) {
                          _width = double.tryParse(v.replaceAll(',', '.')) ?? 0;
                          context.read<SimulatorProvider>().setWidth(_width);
                          _validate();
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _MeasureField(
                        controller: _heightController,
                        label: 'Altura (m)',
                        hint: '0.00',
                        icon: Icons.swap_vert,
                        error: _heightError,
                        onChanged: (v) {
                          _height = double.tryParse(v.replaceAll(',', '.')) ?? 0;
                          context.read<SimulatorProvider>().setHeight(_height);
                          _validate();
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),

                // Sugestão de divisão
                if (_width > 2.40 && _widthError == null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: Color(0xFFFF8F00), size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Para melhor funcionamento, recomendamos dividir em duas peças.',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF795548)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Card de cálculo em tempo real
                if (_width > 0 && _height > 0) ...[
                  _PriceCalculationCard(
                    area: area,
                    billedArea: billedArea,
                    config: _previewConfig,
                  ),
                ],
              ],
            ),
          ),
        ),
        _BottomActionBar(
          enabled: _isValid,
          onNext: widget.onNext,
        ),
      ],
    );
  }
}

class _WindowDiagram extends StatelessWidget {
  final double width;
  final double height;
  final double maxWidth;
  const _WindowDiagram(
      {required this.width, required this.height, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.window_outlined, size: 60, color: AppColors.grey400),
              const SizedBox(height: 8),
              Text(
                width > 0 && height > 0
                    ? '${width.toStringAsFixed(2)}m × ${height.toStringAsFixed(2)}m'
                    : 'Insira as medidas abaixo',
                style: TextStyle(
                  color:
                      width > 0 && height > 0 ? AppColors.primary : AppColors.grey400,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (width > 0 && height > 0)
                Text(
                  'Área: ${(width * height).toStringAsFixed(2)} m²',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MeasureField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final String? error;
  final ValueChanged<String> onChanged;

  const _MeasureField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.error,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, size: 18),
            errorText: error != null ? '' : null,
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(error!,
                style:
                    const TextStyle(color: AppColors.error, fontSize: 11)),
          ),
      ],
    );
  }
}

class _PriceCalculationCard extends StatelessWidget {
  final double area;
  final double billedArea;
  final SimulatorConfig config;

  const _PriceCalculationCard(
      {required this.area, required this.billedArea, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Cálculo em Tempo Real',
              style: TextStyle(
                  color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Área calculada:',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text('${area.toStringAsFixed(2)} m²',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          if (area < SimulatorConfig.minArea) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Área mínima cobrada:',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text('${billedArea.toStringAsFixed(2)} m²',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
          if (config.pricePerM2 != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Preço por m²:',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text(formatCurrency(config.pricePerM2!),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
            const Divider(color: Colors.white24, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Preço estimado:',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                Text(
                  formatCurrency(config.basePrice),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// STEP 6 — ACESSÓRIOS
// ============================================================
class _StepAcessorios extends StatelessWidget {
  final VoidCallback onNext;
  const _StepAcessorios({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Acessórios Opcionais',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                const Text('Adicione itens extras para sua persiana',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 20),
                ...AccessoryType.values.map((acc) {
                  final isSelected =
                      sim.config.accessories.contains(acc);
                  return GestureDetector(
                    onTap: () => context
                        .read<SimulatorProvider>()
                        .toggleAccessory(acc),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.grey200,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(acc.icon,
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(acc.displayName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                Text(acc.description,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatCurrency(acc.price),
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: AppColors.primary, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                if (sim.config.accessories.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total de acessórios:',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          formatCurrency(sim.config.accessoriesPrice),
                          style: const TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        _BottomActionBar(onNext: onNext, label: 'Ver Resumo'),
      ],
    );
  }
}

// ============================================================
// STEP 7 — RESUMO E PREÇO FINAL
// ============================================================
class _StepResumo extends StatelessWidget {
  final Function(BuildContext) onAddToCart;
  const _StepResumo({required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final sim = context.watch<SimulatorProvider>();
    final config = sim.config;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumo do Pedido',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                const Text('Confira os detalhes antes de adicionar ao carrinho',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 20),

                // Card resumo
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: AppColors.shadow, blurRadius: 10)
                    ],
                  ),
                  child: Column(
                    children: [
                      _ResumoRow(
                          icon: Icons.blinds,
                          label: 'Modelo',
                          value: config.category.displayName),
                      if (config.fabric != null)
                        _ResumoRow(
                            icon: Icons.texture,
                            label: 'Tecido',
                            value: config.fabric!.displayName),
                      if (config.fabricColor != null)
                        _ResumoRow(
                            icon: Icons.palette_outlined,
                            label: 'Cor',
                            value: config.fabricColor!),
                      if (config.installation != null)
                        _ResumoRow(
                            icon: Icons.construction_outlined,
                            label: 'Instalação',
                            value: config.installation!.displayName),
                      if (config.width != null && config.height != null) ...[
                        _ResumoRow(
                            icon: Icons.swap_horiz,
                            label: 'Largura',
                            value: '${config.width!.toStringAsFixed(2)} m'),
                        _ResumoRow(
                            icon: Icons.swap_vert,
                            label: 'Altura',
                            value: '${config.height!.toStringAsFixed(2)} m'),
                        _ResumoRow(
                            icon: Icons.crop_square,
                            label: 'Área calculada',
                            value: '${config.area.toStringAsFixed(2)} m²'),
                        _ResumoRow(
                            icon: Icons.receipt_outlined,
                            label: 'Área cobrada',
                            value: '${config.billedArea.toStringAsFixed(2)} m²',
                            valueColor: config.billedArea > config.area
                                ? AppColors.warning
                                : null),
                      ],
                      if (config.pricePerM2 != null)
                        _ResumoRow(
                            icon: Icons.price_change_outlined,
                            label: 'Preço por m²',
                            value: formatCurrency(config.pricePerM2!)),
                    ],
                  ),
                ),

                if (config.accessories.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Acessórios',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: AppColors.shadow, blurRadius: 6)
                      ],
                    ),
                    child: Column(
                      children: config.accessories.map((acc) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Text(acc.icon),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(acc.displayName,
                                      style: const TextStyle(fontSize: 13))),
                              Text(formatCurrency(acc.price),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Preço final
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Persiana:',
                              style: TextStyle(color: Colors.white70)),
                          Text(formatCurrency(config.basePrice),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (config.accessories.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Acessórios:',
                                style: TextStyle(color: Colors.white70)),
                            Text(formatCurrency(config.accessoriesPrice),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                      const Divider(color: Colors.white24, height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL:',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text(
                            formatCurrency(config.totalPrice),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 26),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                          '* Frete calculado no checkout',
                          style: TextStyle(
                              color: Colors.white60, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
              16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          color: AppColors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to environment simulator
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Simulador de ambiente em breve!')),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text('Simular Ambiente'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: config.totalPrice > 0
                      ? () => onAddToCart(context)
                      : null,
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text('Adicionar ao Carrinho'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResumoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;

  const _ResumoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13))),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: valueColor ?? AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final VoidCallback onNext;
  final bool enabled;
  final String label;

  const _BottomActionBar(
      {required this.onNext, this.enabled = true, this.label = 'Continuar'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, -2))
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: GradientButton(
          label: label,
          onPressed: enabled ? onNext : null,
          icon: Icons.arrow_forward,
        ),
      ),
    );
  }
}
