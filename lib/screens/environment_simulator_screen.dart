import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../theme/app_theme.dart';
import '../models/models.dart';

class EnvironmentSimulatorScreen extends StatefulWidget {
  final ProductCategory? preselectedCategory;
  const EnvironmentSimulatorScreen({super.key, this.preselectedCategory});
  @override
  State<EnvironmentSimulatorScreen> createState() =>
      _EnvironmentSimulatorScreenState();
}

class _EnvironmentSimulatorScreenState
    extends State<EnvironmentSimulatorScreen> {
  Uint8List? _imageBytes;
  String? _demoImageUrl;
  ProductCategory _category = ProductCategory.rolo;

  // Controles de posicionamento
  double _blindOpacity = 0.88;
  double _blindPosition = 0.85; // 0=totalmente fechada, 1=totalmente aberta
  double _lightControl = 0.5;

  // Dimensões da janela em metros (para escala proporcional)
  double _windowWidth = 1.20;
  double _windowHeight = 1.50;

  // Posição da janela na imagem (offset relativo 0..1)
  double _winOffsetX = 0.20; // posição horizontal da janela (0=esquerda, 1=direita)
  double _winOffsetY = 0.15; // posição vertical da janela (0=topo, 1=fundo)

  bool _showControls = true;
  bool _showSizePanel = false;
  int _selectedColorIdx = 0;
  final ImagePicker _picker = ImagePicker();

  static const List<String> blindColors = [
    '#2C2C2C', '#F5F0E8', '#4A4A4A', '#C8B99A',
    '#8B7355', '#E8E0D5', '#1B2A4A', '#6B7C8F',
  ];

  Color get _currentBlindColor {
    final hex = blindColors[_selectedColorIdx];
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  }

  @override
  void initState() {
    super.initState();
    if (widget.preselectedCategory != null) {
      _category = widget.preselectedCategory!;
    }
  }

  // ── Lista de ambientes demo ─────────────────────────────────
  static const List<Map<String, String>> _demoRooms = [
    {
      'url': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=1000&q=80',
      'label': 'Sala de Estar',
    },
    {
      'url': 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1000&q=80',
      'label': 'Home Office',
    },
    {
      'url': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=1000&q=80',
      'label': 'Quarto',
    },
    {
      'url': 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=1000&q=80',
      'label': 'Sala Moderna',
    },
    {
      'url': 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=1000&q=80',
      'label': 'Escritório',
    },
    {
      'url': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=1000&q=80',
      'label': 'Varanda',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Simular no Ambiente',
            style: TextStyle(color: Colors.white)),
        actions: [
          if (_imageBytes != null || _demoImageUrl != null)
            IconButton(
              icon: const Icon(Icons.swap_horiz, color: Colors.white70),
              tooltip: 'Trocar ambiente',
              onPressed: () => setState(
                  () {_imageBytes = null; _demoImageUrl = null;}),
            ),
          IconButton(
            icon: Icon(
                _showControls ? Icons.visibility_off : Icons.tune,
                color: Colors.white),
            tooltip: _showControls ? 'Ocultar controles' : 'Mostrar controles',
            onPressed: () =>
                setState(() => _showControls = !_showControls),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: (_imageBytes == null && _demoImageUrl == null)
                ? _buildPickerUI()
                : _buildSimulator(),
          ),
          if (_showControls &&
              (_imageBytes != null || _demoImageUrl != null))
            _buildControlPanel(),
        ],
      ),
    );
  }

  // ── Tela de seleção de ambiente ──────────────────────────────
  Widget _buildPickerUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Icon(Icons.camera_alt_outlined,
              color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text('Simule a persiana no seu ambiente',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          const Text(
              'Escolha um ambiente abaixo ou envie sua própria foto',
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          // Botões de upload
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library, size: 18),
              label: const Text('Minha Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt,
                  size: 18, color: Colors.white70),
              label: const Text('Câmera',
                  style: TextStyle(color: Colors.white70)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
                child: Divider(
                    color: Colors.white.withValues(alpha: 0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('ou ambiente de demonstração',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12)),
            ),
            Expanded(
                child: Divider(
                    color: Colors.white.withValues(alpha: 0.3))),
          ]),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: _demoRooms
                .map((r) => GestureDetector(
                      onTap: () => setState(
                          () => _demoImageUrl = r['url']),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                r['url']!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(
                                        color: Colors.grey.shade800,
                                        child: const Icon(Icons.image,
                                            color: Colors.white38,
                                            size: 32)),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.65)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              Positioned(
                                  bottom: 8,
                                  left: 0,
                                  right: 0,
                                  child: Text(r['label']!,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center)),
                            ]),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Simulador com persiana sobreposta ────────────────────────
  Widget _buildSimulator() {
    return LayoutBuilder(builder: (ctx, constraints) {
      final W = constraints.maxWidth;
      final H = constraints.maxHeight;

      // Relação largura/altura da janela definida pelo usuário
      final aspectRatio = _windowWidth / _windowHeight;

      // Calcula as dimensões da persiana em pixels proporcionais à tela
      // A persiana ocupa no máx 60% da largura ou 70% da altura da área
      double blindW = W * 0.55;
      double blindH = blindW / aspectRatio;
      if (blindH > H * 0.65) {
        blindH = H * 0.65;
        blindW = blindH * aspectRatio;
      }

      // Centraliza horizontalmente + posição vertical ajustável
      final blindLeft = (W - blindW) / 2 + (_winOffsetX - 0.5) * W * 0.5;
      final blindTop = H * 0.05 + _winOffsetY * H * 0.4;

      // Altura visível da persiana conforme posição (aberta/fechada)
      final visibleHeight = blindH * (1 - _blindPosition * 0.85);

      Widget bgImage = _imageBytes != null
          ? Image.memory(_imageBytes!,
              fit: BoxFit.cover, width: W, height: H)
          : Image.network(
              _demoImageUrl!,
              fit: BoxFit.cover,
              width: W,
              height: H,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white)),
              errorBuilder: (_, __, ___) => const Center(
                  child: Text('Erro ao carregar imagem',
                      style: TextStyle(color: Colors.white))),
            );

      return Stack(
        children: [
          // Fundo: foto do ambiente
          Positioned.fill(child: bgImage),

          // Overlay de luminosidade
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withValues(alpha: (1 - _lightControl) * 0.45),
              ),
            ),
          ),

          // Persiana centralizada e proporcional
          Positioned(
            left: blindLeft,
            top: blindTop,
            width: blindW,
            height: visibleHeight,
            child: Opacity(
              opacity: _blindOpacity,
              child: _BlindWidget(
                category: _category,
                color: _currentBlindColor,
                width: blindW,
                height: visibleHeight,
              ),
            ),
          ),

          // Informações de medida sobrepostas
          Positioned(
            left: blindLeft,
            top: blindTop + visibleHeight + 4,
            width: blindW,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_windowWidth.toStringAsFixed(2)}m × ${_windowHeight.toStringAsFixed(2)}m',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          // Tag do modelo
          Positioned(
            left: blindLeft,
            top: blindTop,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomRight: Radius.circular(8)),
              ),
              child: Text(
                _category.shortName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // FABs
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(children: [
              FloatingActionButton.small(
                heroTag: 'size_fab',
                onPressed: () => setState(
                    () => _showSizePanel = !_showSizePanel),
                backgroundColor: AppColors.primary.withValues(alpha: 0.9),
                tooltip: 'Ajustar medidas da janela',
                child: const Icon(Icons.straighten, color: Colors.white),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'gallery_fab',
                onPressed: () => _pickImage(ImageSource.gallery),
                backgroundColor: Colors.black54,
                tooltip: 'Minha foto',
                child: const Icon(Icons.photo_library, color: Colors.white),
              ),
            ]),
          ),

          // Painel de ajuste das medidas da janela
          if (_showSizePanel)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildSizePanel(),
            ),
        ],
      );
    });
  }

  // ── Painel de medidas da janela ──────────────────────────────
  Widget _buildSizePanel() {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.straighten, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              const Text('Medidas da Janela',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                onPressed: () =>
                    setState(() => _showSizePanel = false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Largura: ${_windowWidth.toStringAsFixed(2)} m',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11),
                  ),
                  Slider(
                    value: _windowWidth,
                    min: 0.40,
                    max: 2.89,
                    divisions: 50,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white24,
                    onChanged: (v) =>
                        setState(() => _windowWidth = v),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Altura: ${_windowHeight.toStringAsFixed(2)} m',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11),
                  ),
                  Slider(
                    value: _windowHeight,
                    min: 0.40,
                    max: 3.00,
                    divisions: 52,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.white24,
                    onChanged: (v) =>
                        setState(() => _windowHeight = v),
                  ),
                ],
              ),
            ),
          ]),
          // Posição horizontal na imagem
          Text(
            'Posição horizontal: ${((_winOffsetX - 0.5) * 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Slider(
            value: _winOffsetX,
            min: 0.0,
            max: 1.0,
            activeColor: Colors.orange,
            inactiveColor: Colors.white24,
            onChanged: (v) => setState(() => _winOffsetX = v),
          ),
          Text(
            'Posição vertical: ${(_winOffsetY * 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Slider(
            value: _winOffsetY,
            min: 0.0,
            max: 0.8,
            activeColor: Colors.orange,
            inactiveColor: Colors.white24,
            onChanged: (v) => setState(() => _winOffsetY = v),
          ),
        ],
      ),
    );
  }

  // ── Painel de controles ──────────────────────────────────────
  Widget _buildControlPanel() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seletor de modelo
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ProductCategory.values.map((cat) {
                final isSelected = _category == cat;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(cat.shortName,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          // Cores
          Row(children: [
            const Text('Cor:',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(width: 8),
            ...List.generate(blindColors.length, (i) {
              final c = Color(int.parse(
                  'FF${blindColors[i].replaceAll('#', '')}',
                  radix: 16));
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedColorIdx = i),
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _selectedColorIdx == i
                            ? Colors.white
                            : Colors.transparent,
                        width: 2),
                  ),
                ),
              );
            }),
          ]),
          const SizedBox(height: 6),
          // Sliders
          _SliderControl(
            icon: Icons.wb_sunny_outlined,
            label: 'Luz',
            value: _lightControl,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => _lightControl = v),
          ),
          _SliderControl(
            icon: Icons.unfold_more,
            label: 'Abertura',
            value: _blindPosition,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => _blindPosition = v),
          ),
          _SliderControl(
            icon: Icons.opacity,
            label: 'Opacidade',
            value: _blindOpacity,
            min: 0.3,
            max: 1.0,
            onChanged: (v) => setState(() => _blindOpacity = v),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _demoImageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Selecione uma foto da janela do seu ambiente.'),
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

// ── Widget visual da persiana ────────────────────────────────
class _BlindWidget extends StatelessWidget {
  final ProductCategory category;
  final Color color;
  final double width;
  final double height;
  const _BlindWidget(
      {required this.category,
      required this.color,
      required this.width,
      required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.92),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(2, 4)),
          ],
        ),
        child: CustomPaint(
          painter: _BlindPatternPainter(category: category, color: color),
        ),
      ),
    );
  }
}

// ── Slider de controle ───────────────────────────────────────
class _SliderControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value, min, max;
  final ValueChanged<double> onChanged;
  const _SliderControl(
      {required this.icon,
      required this.label,
      required this.value,
      required this.min,
      required this.max,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(width: 6),
        SizedBox(
            width: 60,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white60, fontSize: 11))),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveColor: Colors.white24,
          ),
        ),
      ],
    );
  }
}

// ── Padrão de textura por categoria ─────────────────────────
class _BlindPatternPainter extends CustomPainter {
  final ProductCategory category;
  final Color color;
  _BlindPatternPainter({required this.category, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 0.8;

    switch (category) {
      case ProductCategory.horizontal25mm:
        // Lâminas horizontais de alumínio
        for (var y = 0.0; y < size.height; y += 10) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
        }
        final shadePaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.08)
          ..style = PaintingStyle.fill;
        for (var y = 0.0; y < size.height; y += 10) {
          canvas.drawRect(
              Rect.fromLTWH(0, y + 5, size.width, 5), shadePaint);
        }
        break;

      case ProductCategory.doubleVision:
        // Faixas alternadas translúcidas/opacas
        final opacaPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        final transPaint = Paint()
          ..color = color.withValues(alpha: 0.35)
          ..style = PaintingStyle.fill;
        for (var y = 0.0; y < size.height; y += 22) {
          canvas.drawRect(
              Rect.fromLTWH(0, y, size.width, 11), opacaPaint);
          canvas.drawRect(
              Rect.fromLTWH(0, y + 11, size.width, 11), transPaint);
        }
        break;

      case ProductCategory.romana:
        // Dobras horizontais da persiana romana
        final foldPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.1)
          ..style = PaintingStyle.fill;
        final shadowPaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.15)
          ..style = PaintingStyle.fill;
        final foldSize = size.height / 4;
        for (var i = 0; i < 4; i++) {
          final y = i * foldSize;
          canvas.drawRect(
              Rect.fromLTWH(0, y, size.width, foldSize * 0.6), foldPaint);
          canvas.drawRect(
              Rect.fromLTWH(0, y + foldSize * 0.6, size.width, foldSize * 0.4),
              shadowPaint);
        }
        break;

      case ProductCategory.painel:
        // Painéis verticais
        final panelCount = (size.width / 80).floor().clamp(2, 6);
        final panelW = size.width / panelCount;
        final panelPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.08)
          ..style = PaintingStyle.fill;
        for (var i = 0; i < panelCount; i++) {
          if (i.isEven) {
            canvas.drawRect(
                Rect.fromLTWH(i * panelW, 0, panelW, size.height),
                panelPaint);
          }
          canvas.drawLine(Offset(i * panelW, 0),
              Offset(i * panelW, size.height), linePaint);
        }
        break;

      case ProductCategory.rolo:
      default:
        // Rolo: superfície lisa com gradiente sutil
        final gradientPaint = Paint()
          ..shader = LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.08),
              Colors.black.withValues(alpha: 0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
        canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height), gradientPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BlindPatternPainter old) =>
      old.category != category || old.color != color;
}
