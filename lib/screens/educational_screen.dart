import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import 'simulator_screen.dart';

// ============================================================
// TELA DE CONTEÚDO EDUCATIVO
// ============================================================
class EducationalScreen extends StatelessWidget {
  final int initialTab;
  const EducationalScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Aprenda Mais'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Como Medir'),
              Tab(text: 'Tipos de Persiana'),
              Tab(text: 'Instalação'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _HowToMeasureTab(),
            _TypesOfBlindsTab(),
            _InstallationTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 1 – COMO MEDIR
// ─────────────────────────────────────────────
class _HowToMeasureTab extends StatelessWidget {
  const _HowToMeasureTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(height: 200, color: AppColors.grey200),
            ),
          ),
          const SizedBox(height: 20),
          Text('Como Medir Corretamente',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text(
            'Medidas precisas garantem que sua persiana fique perfeita. Siga o passo a passo abaixo:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),

          // Passo 1
          _MeasureStep(
            step: '01',
            title: 'Ferramentas Necessárias',
            description: 'Utilize uma trena metálica (não de costura). Tenha papel e caneta para anotar as medidas.',
            imageUrl: 'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=600&q=80',
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),

          // Passo 2
          _MeasureStep(
            step: '02',
            title: 'Meça a Largura',
            description: 'Meça de uma borda à outra do vão da janela. Para instalação dentro do vão, subtraia 1cm de cada lado. Para fora, some pelo menos 10cm de cada lado.',
            imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
            color: const Color(0xFF00897B),
          ),
          const SizedBox(height: 16),

          // Passo 3
          _MeasureStep(
            step: '03',
            title: 'Meça a Altura',
            description: 'Meça da parte superior do vão até o ponto onde deseja que a persiana termine. Para cobertura total, vá até o piso ou peitoril. Máximo de 3,00m.',
            imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80',
            color: const Color(0xFF6D4C41),
          ),
          const SizedBox(height: 16),

          // Passo 4
          _MeasureStep(
            step: '04',
            title: 'Calcule a Área',
            description: 'Área = Largura × Altura. Mínimo cobrado: 1,50 m². Máximo: 5,00 m².\n\nExemplo: 1,40m × 1,60m = 2,24 m² → preço calculado para 2,24 m².',
            imageUrl: 'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=600&q=80',
            color: const Color(0xFF6A1B9A),
          ),

          const SizedBox(height: 24),

          // Dica especial
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFCC80)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Color(0xFFE65100)),
                    SizedBox(width: 8),
                    Text('Dica Importante',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Quando a largura for maior que 2,40m, recomendamos dividir em dois módulos para melhor acabamento e funcionamento.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF795548), height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Botão simular
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SimulatorScreen()),
              ),
              icon: const Icon(Icons.straighten),
              label: const Text('Abrir Simulador de Medidas'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 2 – TIPOS DE PERSIANA
// ─────────────────────────────────────────────
class _TypesOfBlindsTab extends StatelessWidget {
  const _TypesOfBlindsTab();

  @override
  Widget build(BuildContext context) {
    final types = [
      _BlindType(
        name: 'Persiana Rolô',
        subtitle: 'Prática e versátil',
        description:
            'A persiana rolô é a mais popular do mercado. Enrola para cima de forma limpa e discreta. Disponível em tecidos blackout, screen solar e translúcido. Ideal para quartos, salas e escritórios.',
        price: 'A partir de R\$ 219,90/m²',
        pros: ['Fácil de usar', 'Design minimalista', 'Muitas opções de tecido', 'Motorização disponível'],
        imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
        color: AppColors.primary,
        tags: ['Mais Vendida', 'Para Todos os Ambientes'],
      ),
      _BlindType(
        name: 'Persiana Romana',
        subtitle: 'Elegância clássica',
        description:
            'A persiana romana sobe em dobras horizontais, criando um visual elegante e sofisticado. Muito usada em salas de estar, escritórios e quartos de alto padrão. Acabamento premium.',
        price: 'A partir de R\$ 299,00/m²',
        pros: ['Visual elegante', 'Dobras uniformes', 'Isolamento térmico', 'Acabamento sofisticado'],
        imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80',
        color: const Color(0xFF6D4C41),
        tags: ['Premium', 'Sala e Escritório'],
      ),
      _BlindType(
        name: 'Double Vision',
        subtitle: 'Controle total de luz',
        description:
            'Com dupla camada de tecido, a Double Vision permite regular com precisão a entrada de luz. Ao girar os painéis, você vai de total transparência ao semi-blackout. Design moderno e funcional.',
        price: 'A partir de R\$ 319,90/m²',
        pros: ['Controle preciso de luz', 'Efeito visual único', 'Privacidade sem escurecer', 'Design exclusivo'],
        imageUrl: 'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=600&q=80',
        color: const Color(0xFF1A237E),
        tags: ['Design Exclusivo', 'Alta Tecnologia'],
      ),
      _BlindType(
        name: 'Cortina Painel',
        subtitle: 'Para grandes vãos',
        description:
            'A cortina painel é ideal para grandes janelas, portas de vidro e divisórias. Os painéis deslizam lateralmente sobre trilhos. Perfeita para ambientes modernos e integrados.',
        price: 'A partir de R\$ 219,90/m²',
        pros: ['Ideal para grandes vãos', 'Sobreposição de painéis', 'Movimento suave', 'Fácil de limpar'],
        imageUrl: 'https://images.unsplash.com/photo-1600566752355-35792bedcfea?w=600&q=80',
        color: const Color(0xFF00695C),
        tags: ['Grandes Espaços', 'Portas de Vidro'],
      ),
      _BlindType(
        name: 'Horizontal 25mm',
        subtitle: 'Clássica e resistente',
        description:
            'As lâminas horizontais de alumínio 25mm são práticas, duráveis e fáceis de limpar. Resistentes à umidade, são ideais para banheiros, cozinhas e escritórios. Regulagem precisa de luz.',
        price: 'A partir de R\$ 199,90/m²',
        pros: ['Resistente à umidade', 'Fácil de limpar', 'Regulagem precisa', 'Durabilidade'],
        imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&q=80',
        color: const Color(0xFF546E7A),
        tags: ['Banheiro e Cozinha', 'Alta Durabilidade'],
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: types.length,
      itemBuilder: (context, i) => _BlindTypeCard(type: types[i]),
    );
  }
}

// ─────────────────────────────────────────────
// TAB 3 – INSTALAÇÃO
// ─────────────────────────────────────────────
class _InstallationTab extends StatelessWidget {
  const _InstallationTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=800&q=80',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(height: 180, color: AppColors.grey200),
            ),
          ),
          const SizedBox(height: 20),
          Text('Tipos de Instalação',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text(
            'Escolha o tipo de instalação mais adequado para sua janela e ambiente.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),

          // Tipo 1 – Dentro do vão
          _InstallTypeCard(
            title: 'Dentro do Vão',
            subtitle: 'Encaixe perfeito na janela',
            description:
                'A persiana fica embutida dentro do vão da janela. Ideal para janelas com moldura. Subtraia 0,5cm de cada lado da largura para garantir o movimento livre.',
            pros: ['Visual limpo e integrado', 'Não precisa de suporte externo', 'Ideal para janelas com profundidade'],
            cons: ['Requer janela com profundidade mínima', 'Medida mais rigorosa'],
            imageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',
            tipMeasure: 'Meça o vão interno e subtraia 1cm (0,5cm de cada lado)',
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),

          // Tipo 2 – Fora do vão na parede
          _InstallTypeCard(
            title: 'Fora do Vão na Parede',
            subtitle: 'Fixação na parede acima',
            description:
                'A persiana é instalada na parede acima da janela. Cubra o vão completamente, somando pelo menos 10cm de cada lado para garantir privacidade e bloqueio total de luz.',
            pros: ['Maior cobertura de luz', 'Janela parece maior', 'Mais privacidade'],
            cons: ['Ocupa espaço na parede', 'Requer furação na alvenaria'],
            imageUrl: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80',
            tipMeasure: 'Largura do vão + 20cm (10cm cada lado) | Altura do suporte até onde deseja cobrir',
            color: const Color(0xFF00897B),
          ),
          const SizedBox(height: 16),

          // Tipo 3 – Do vão ao teto
          _InstallTypeCard(
            title: 'Do Vão ao Teto',
            subtitle: 'Da janela até o teto',
            description:
                'A persiana vai desde o suporte instalado próximo ao teto até o peitoril ou piso. Faz o ambiente parecer maior e mais sofisticado. Muito usado em arquitetura moderna.',
            pros: ['Pé-direito visualmente maior', 'Toque de luxo', 'Cobertura total'],
            cons: ['Maior custo de tecido', 'Instalação mais complexa'],
            imageUrl: 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=600&q=80',
            tipMeasure: 'Meça do teto ao piso (ou peitoril). Largura: vão + 10cm cada lado',
            color: const Color(0xFF6A1B9A),
          ),

          const SizedBox(height: 24),

          // Acessórios
          Text('Acessórios Disponíveis',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),

          _AccessoryInfoCard(
            icon: Icons.settings_remote,
            name: 'Motor WiFi',
            price: 'R\$ 1.297,00',
            description: 'Motorize sua persiana e controle pelo aplicativo ou assistente de voz. Compatível com Alexa e Google Home.',
            color: AppColors.primary,
          ),
          _AccessoryInfoCard(
            icon: Icons.curtains_closed,
            name: 'Bandô',
            price: 'R\$ 99,90',
            description: 'Peça de acabamento que oculta o mecanismo da persiana. Deixa a instalação mais elegante.',
            color: const Color(0xFF00897B),
          ),
          _AccessoryInfoCard(
            icon: Icons.horizontal_rule,
            name: 'Barra Estabilizadora',
            price: 'R\$ 50,00',
            description: 'Garante que o tecido permaneça tenso e sem ondulações, especialmente em locais com vento.',
            color: const Color(0xFF6D4C41),
          ),
          _AccessoryInfoCard(
            icon: Icons.align_vertical_center,
            name: 'Guia Lateral',
            price: 'R\$ 140,00',
            description: 'Mantém o tecido na posição correta, impedindo que o vento levante a persiana. Ideal para áreas externas.',
            color: const Color(0xFF6A1B9A),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGETS AUXILIARES
// ============================================================

class _MeasureStep extends StatelessWidget {
  final String step, title, description, imageUrl;
  final Color color;
  const _MeasureStep({required this.step, required this.title, required this.description, required this.imageUrl, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: AppColors.grey200, child: const Icon(Icons.image, size: 50, color: AppColors.grey400)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text(step, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                    ],
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

class _BlindType {
  final String name, subtitle, description, price;
  final List<String> pros;
  final String imageUrl;
  final Color color;
  final List<String> tags;

  const _BlindType({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.pros,
    required this.imageUrl,
    required this.color,
    required this.tags,
  });
}

class _BlindTypeCard extends StatefulWidget {
  final _BlindType type;
  const _BlindTypeCard({required this.type});

  @override
  State<_BlindTypeCard> createState() => _BlindTypeCardState();
}

class _BlindTypeCardState extends State<_BlindTypeCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.type;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem
          Stack(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: t.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(height: 180, color: AppColors.grey200),
                ),
              ),
              // Tags
              Positioned(
                top: 12,
                left: 12,
                child: Wrap(
                  spacing: 6,
                  children: t.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: t.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                  )).toList(),
                ),
              ),
              // Price overlay
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(t.price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(color: t.color, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(t.subtitle, style: TextStyle(fontSize: 12, color: t.color, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(t.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                if (_expanded) ...[
                  const SizedBox(height: 12),
                  Text('Vantagens', style: TextStyle(fontWeight: FontWeight.bold, color: t.color)),
                  const SizedBox(height: 6),
                  ...t.pros.map((p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: t.color, size: 16),
                        const SizedBox(width: 6),
                        Text(p, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  )),
                ],
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    children: [
                      Text(
                        _expanded ? 'Ver menos' : 'Ver vantagens',
                        style: TextStyle(color: t.color, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: t.color, size: 18),
                    ],
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

class _InstallTypeCard extends StatelessWidget {
  final String title, subtitle, description, tipMeasure, imageUrl;
  final List<String> pros, cons;
  final Color color;

  const _InstallTypeCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.tipMeasure,
    required this.imageUrl,
    required this.pros,
    required this.cons,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(height: 160, color: AppColors.grey200),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.home_work_outlined, color: color, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(subtitle, style: TextStyle(fontSize: 12, color: color)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                const SizedBox(height: 12),
                // Prós
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vantagens', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
                          const SizedBox(height: 4),
                          ...pros.map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(children: [
                              Icon(Icons.add_circle_outline, color: color, size: 14),
                              const SizedBox(width: 4),
                              Expanded(child: Text(p, style: const TextStyle(fontSize: 12))),
                            ]),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Atenção', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning, fontSize: 12)),
                          const SizedBox(height: 4),
                          ...cons.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Row(children: [
                              const Icon(Icons.info_outline, color: AppColors.warning, size: 14),
                              const SizedBox(width: 4),
                              Expanded(child: Text(c, style: const TextStyle(fontSize: 12))),
                            ]),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Dica de medida
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.straighten, color: color, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(tipMeasure, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500))),
                    ],
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

class _AccessoryInfoCard extends StatelessWidget {
  final IconData icon;
  final String name, price, description;
  final Color color;

  const _AccessoryInfoCard({
    required this.icon,
    required this.name,
    required this.price,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(price, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
        ],
      ),
    );
  }
}
