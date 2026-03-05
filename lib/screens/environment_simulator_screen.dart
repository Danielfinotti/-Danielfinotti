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
  ProductCategory _category = ProductCategory.rolo;
  double _blindOpacity = 0.85;
  double _blindPosition = 0.0; // 0 = open, 1 = closed
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
          IconButton(
            icon: Icon(_showControls ? Icons.visibility_off : Icons.tune, color: Colors.white),
            onPressed: () => setState(() => _showControls = !_showControls),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _imageBytes == null ? _buildPickerUI() : _buildSimulator()),
          if (_showControls && _imageBytes != null) _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildPickerUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 56),
          ),
          const SizedBox(height: 24),
          const Text('Simule a persiana na sua janela', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tire uma foto ou escolha da galeria', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PickerButton(icon: Icons.camera_alt, label: 'Câmera', onTap: () => _pickImage(ImageSource.camera)),
              const SizedBox(width: 16),
              _PickerButton(icon: Icons.photo_library, label: 'Galeria', onTap: () => _pickImage(ImageSource.gallery)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.tips_and_updates_outlined, color: Colors.amber, size: 18),
                SizedBox(width: 8),
                Expanded(child: Text('Dica: posicione a câmera de frente para a janela para melhor resultado', style: TextStyle(color: Colors.white70, fontSize: 12))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulator() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(_imageBytes!, fit: BoxFit.contain),
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
        // Light overlay
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: Colors.white.withValues(alpha: (1 - _lightControl) * 0.4),
            ),
          ),
        ),
        // Action buttons overlay
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            children: [
              FloatingActionButton.small(
                heroTag: 'cam',
                onPressed: () => _pickImage(ImageSource.camera),
                backgroundColor: Colors.black54,
                child: const Icon(Icons.camera_alt, color: Colors.white),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'gallery',
                onPressed: () => _pickImage(ImageSource.gallery),
                backgroundColor: Colors.black54,
                child: const Icon(Icons.photo_library, color: Colors.white),
              ),
            ],
          ),
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
      final picked = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1080);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _imageBytes = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível acessar a câmera/galeria no preview web. Use o app no celular!')),
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

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
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
