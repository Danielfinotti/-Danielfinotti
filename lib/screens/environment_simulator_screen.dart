import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../theme/app_theme.dart';
import '../models/models.dart';

class EnvironmentSimulatorScreen extends StatefulWidget {
  final ProductCategory? preselectedCategory;
  const EnvironmentSimulatorScreen({super.key, this.preselectedCategory});
  @override
  State<EnvironmentSimulatorScreen> createState() => _EnvironmentSimulatorScreenState();
}

class _EnvironmentSimulatorScreenState extends State<EnvironmentSimulatorScreen> {
  Uint8List? _imageBytes;
  String? _demoImageUrl;       // URL direto para ambientes demo (sem CORS)
  ProductCategory _category = ProductCategory.rolo;
  double _blindOpacity = 0.85;
  double _blindPosition = 0.0;
  double _lightControl = 0.5;
  bool _showControls = true;
  final ImagePicker _picker = ImagePicker();

  static const List<String> blindColors = ['#2C2C2C', '#F5F0E8', '#4A4A4A', '#C8B99A', '#8B7355', '#E8E0D5', '#1B2A4A', '#6B7C8F'];
  int _selectedColorIdx = 0;

  Color get _currentBlindColor {
    final hex = blindColors[_selectedColorIdx];
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  }

  @override
  void initState() {
    super.initState();
    if (widget.preselectedCategory != null) _category = widget.preselectedCategory!;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Simular no Ambiente', style: TextStyle(color: Colors.white)),
        actions: [
          if (_imageBytes != null)
            IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: _share),
          if (_imageBytes != null || _demoImageUrl != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              tooltip: 'Trocar ambiente',
              onPressed: () => setState(() { _imageBytes = null; _demoImageUrl = null; }),
            ),
          IconButton(
            icon: Icon(_showControls ? Icons.visibility_off : Icons.tune, color: Colors.white),
            onPressed: () => setState(() => _showControls = !_showControls),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: (_imageBytes == null && _demoImageUrl == null)
              ? _buildPickerUI()
              : _buildSimulator()),
          if (_showControls && (_imageBytes != null || _demoImageUrl != null)) _buildControlPanel(),
        ],
      ),
    );
  }

  // Ambientes de demonstração para preview web
  static const List<Map<String, String>> _demoRooms = [
    {'url': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800&q=80', 'label': 'Sala de Estar'},
    {'url': 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=800&q=80', 'label': 'Home Office'},
    {'url': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&q=80', 'label': 'Quarto'},
    {'url': 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=800&q=80', 'label': 'Sala Moderna'},
    {'url': 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=800&q=80', 'label': 'Escritório'},
    {'url': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80', 'label': 'Varanda'},
  ];

  bool _loadingDemo = false;

  Future<void> _loadDemoRoom(String url) async {
    // Usa Image.network direto — sem CORS, funciona no web
    setState(() { _demoImageUrl = url; _loadingDemo = false; });
  }

  Widget _buildPickerUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 48),
          const SizedBox(height: 12),
          const Text('Simule a persiana no seu ambiente',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          const Text('Escolha um ambiente abaixo ou envie sua própria foto',
              style: TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          // Botões de upload
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library, size: 18),
              label: const Text('Minha Foto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white70),
              label: const Text('Câmera', style: TextStyle(color: Colors.white70)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ]),
          const SizedBox(height: 24),
          // Divisor
          Row(children: [
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('ou escolha um ambiente de demonstração',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
            ),
            Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
          ]),
          const SizedBox(height: 16),
          // Grid de ambientes demo
          if (_loadingDemo)
            const CircularProgressIndicator(color: Colors.white)
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10, mainAxisSpacing: 10,
              childAspectRatio: 1.5,
              children: _demoRooms.map((r) => GestureDetector(
                onTap: () => _loadDemoRoom(r['url']!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(fit: StackFit.expand, children: [
                    Image.network(r['url']!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade800,
                            child: const Icon(Icons.image, color: Colors.white38, size: 32))),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.65)],
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(bottom: 8, left: 0, right: 0,
                      child: Text(r['label']!,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center)),
                    Positioned(top: 6, right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.touch_app_outlined, color: Colors.white, size: 13),
                      )),
                  ]),
                ),
              )).toList(),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSimulator() {
    // Imagem de fundo: pode ser foto local (bytes) ou URL de demo
    Widget bgImage = _imageBytes != null
        ? Image.memory(_imageBytes!, fit: BoxFit.contain)
        : Image.network(
            _demoImageUrl!,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const Center(child: CircularProgressIndicator(color: Colors.white)),
            errorBuilder: (_, __, ___) => const Center(
                child: Text('Erro ao carregar imagem', style: TextStyle(color: Colors.white))),
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        bgImage,
        Positioned(
          top: 0,
          left: MediaQuery.of(context).size.width * 0.1,
          right: MediaQuery.of(context).size.width * 0.1,
          height: MediaQuery.of(context).size.height * 0.55 * (0.3 + _blindPosition * 0.7),
          child: Opacity(
            opacity: _blindOpacity,
            child: _buildBlindVisual(),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: Colors.white.withValues(alpha: (1 - _lightControl) * 0.4),
            ),
          ),
        ),
        Positioned(
          bottom: 16, right: 16,
          child: Column(children: [
            FloatingActionButton.small(
              heroTag: 'change_img',
              onPressed: () => setState(() { _imageBytes = null; _demoImageUrl = null; }),
              backgroundColor: Colors.black54,
              tooltip: 'Trocar ambiente',
              child: const Icon(Icons.swap_horiz, color: Colors.white),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'gallery',
              onPressed: () => _pickImage(ImageSource.gallery),
              backgroundColor: Colors.black54,
              tooltip: 'Minha foto',
              child: const Icon(Icons.photo_library, color: Colors.white),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildBlindVisual() {
    return Container(
      decoration: BoxDecoration(
        color: _currentBlindColor.withValues(alpha: 0.9),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
      ),
      child: CustomPaint(
        painter: _BlindPatternPainter(category: _category, color: _currentBlindColor),
      ),
    );
  }

  Widget _buildControlPanel() {
    // ignore: unused_local_variable
    final fabrics = PricingModel.getFabricsForCategory(_category);
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ProductCategory.values.map((cat) {
                final isSelected = _category == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _category = cat;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(cat.shortName, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Color swatches
          Row(
            children: [
              const Text('Cor:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 8),
              ...List.generate(blindColors.length, (i) {
                final color = Color(int.parse('FF${blindColors[i].replaceAll('#', '')}', radix: 16));
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorIdx = i),
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: _selectedColorIdx == i ? Colors.white : Colors.transparent, width: 2),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 10),
          // Controls
          _SliderControl(
            icon: Icons.wb_sunny_outlined,
            label: 'Luminosidade',
            value: _lightControl,
            min: 0,
            max: 1,
            onChanged: (v) => setState(() => _lightControl = v),
          ),
          _SliderControl(
            icon: Icons.unfold_more,
            label: 'Posição',
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
        maxWidth: 1080,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      // No web, image_picker usa <input type="file"> automaticamente
      // Se falhar, mostrar instrução clara
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Clique em "Galeria" e selecione uma foto da janela do seu computador.'),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Entendi',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _share() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulação salva! Compartilhando...')),
    );
  }
}

class _SliderControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value, min, max;
  final ValueChanged<double> onChanged;
  const _SliderControl({required this.icon, required this.label, required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(width: 6),
        SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11))),
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

class _BlindPatternPainter extends CustomPainter {
  final ProductCategory category;
  final Color color;
  _BlindPatternPainter({required this.category, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (category == ProductCategory.horizontal25mm) {
      final paint = Paint()..color = color.withValues(alpha: 0.3)..strokeWidth = 1;
      for (var y = 0.0; y < size.height; y += 8) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    } else if (category == ProductCategory.doubleVision) {
      final paint1 = Paint()..color = color..style = PaintingStyle.fill;
      final paint2 = Paint()..color = color.withValues(alpha: 0.4)..style = PaintingStyle.fill;
      for (var y = 0.0; y < size.height; y += 20) {
        canvas.drawRect(Rect.fromLTWH(0, y, size.width, 10), paint1);
        canvas.drawRect(Rect.fromLTWH(0, y + 10, size.width, 10), paint2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
