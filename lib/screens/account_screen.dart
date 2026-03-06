import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../widgets/common_widgets.dart';
import 'orders_screen.dart';
import 'admin_panel_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return user.isLoggedIn
        ? _LoggedInView(user: user)
        : const _LoginView();
  }
}

// ============================================================
// LOGIN
// ============================================================
class _LoginView extends StatefulWidget {
  const _LoginView();
  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _showRegister = false;
  String? _errorMsg;
  final _nameCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.blinds, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                _showRegister ? 'Criar Conta' : 'Bem-vindo!',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 6),
              Text(
                _showRegister
                    ? 'Crie sua conta para continuar'
                    : 'Acesse sua conta Control Persianas',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // Mensagem de erro
              if (_errorMsg != null) ...[  
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMsg!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                    ],
                  ),
                ),
              ],

              // Nome (só no cadastro)
              if (_showRegister) ...[  
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() => _errorMsg = null),
                  decoration: const InputDecoration(
                    labelText: 'Nome completo *',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() => _errorMsg = null),
                decoration: const InputDecoration(
                  labelText: 'E-mail *',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                onChanged: (_) => setState(() => _errorMsg = null),
                decoration: InputDecoration(
                  labelText: 'Senha *',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              // Confirmar senha (só no cadastro)
              if (_showRegister) ...[  
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPassCtrl,
                  obscureText: _obscureConfirm,
                  onChanged: (_) => setState(() => _errorMsg = null),
                  decoration: InputDecoration(
                    labelText: 'Confirmar senha *',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ),
              ],

              if (!_showRegister) ...[  
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Esqueci a senha'),
                  ),
                ),
              ] else
                const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  label: _showRegister ? 'Criar Conta' : 'Entrar',
                  loading: _loading,
                  onPressed: () => _showRegister ? _register() : _login(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_showRegister ? 'Já tem conta?' : 'Não tem conta?',
                      style: const TextStyle(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () => setState(() => _showRegister = !_showRegister),
                    child: Text(_showRegister ? 'Entrar' : 'Criar agora'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('ou', style: TextStyle(color: AppColors.textHint)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _guestLogin(),
                icon: const Icon(Icons.person_outline),
                label: const Text('Continuar como Convidado'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() { _loading = true; _errorMsg = null; });
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    try {
      final user = AuthService.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      context.read<UserProvider>().login(user);
    } catch (e) {
      setState(() => _errorMsg = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    setState(() { _loading = true; _errorMsg = null; });
    // Validar confirmação de senha
    if (_passCtrl.text != _confirmPassCtrl.text) {
      setState(() { _errorMsg = 'As senhas não coincidem.'; _loading = false; });
      return;
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final err = AuthService.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (err != null) {
      setState(() { _errorMsg = err; _loading = false; });
      return;
    }
    try {
      final user = AuthService.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) context.read<UserProvider>().login(user);
    } catch (e) {
      setState(() => _errorMsg = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _guestLogin() async {
    context.read<UserProvider>().login(
      UserModel(id: 'guest', name: 'Convidado', email: '', phone: ''),
    );
  }
}

// ============================================================
// LOGGED IN VIEW
// ============================================================
class _LoggedInView extends StatelessWidget {
  final UserProvider user;
  const _LoggedInView({required this.user});

  @override
  Widget build(BuildContext context) {
    final u = user.user!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Minha Conta')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, u),
            const SizedBox(height: 20),
            _buildMenuSection(context, u),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel u) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white24,
            child: Text(
              u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                if (u.email.isNotEmpty)
                  Text(u.email,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, UserModel u) {
    final sections = [
      {
        'title': 'Compras',
        'items': [
          _MenuItem(Icons.receipt_long_outlined, 'Meus Pedidos', 'Acompanhe seus pedidos', () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
          }),
          _MenuItem(Icons.favorite_outline, 'Lista de Desejos', 'Itens salvos', () {
            _showSimpleSheet(context, 'Lista de Desejos', Icons.favorite_outline,
                'Sua lista de desejos está vazia.\nNavegue pelos produtos e adicione seus favoritos!');
          }),
          _MenuItem(Icons.location_on_outlined, 'Meus Endereços', 'Gerenciar endereços', () {
            _showAddressSheet(context);
          }),
        ],
      },
      {
        'title': 'Configurações',
        'items': [
          _MenuItem(Icons.notifications_outlined, 'Notificações', 'Preferências de aviso', () {
            _showNotificationsSheet(context);
          }),
          _MenuItem(Icons.lock_outline, 'Segurança', 'Senha e autenticação', () {
            _showSecuritySheet(context);
          }),
          _MenuItem(Icons.help_outline, 'Suporte', 'Central de ajuda', () => _openSupport(context)),
        ],
      },
      {
        'title': 'Sobre',
        'items': [
          // Painel Admin — visível APENAS para o administrador
          if (context.read<UserProvider>().isAdmin)
            _MenuItem(Icons.admin_panel_settings_outlined, 'Painel Admin', 'Gerenciar loja', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
            }),
          _MenuItem(Icons.info_outline, 'Sobre o App', 'Versão 1.0.0', () {
            _showAboutSheet(context);
          }),
          _MenuItem(Icons.policy_outlined, 'Política de Privacidade', 'Seus dados', () {
            _showSimpleSheet(context, 'Política de Privacidade', Icons.policy_outlined,
                'Seus dados são protegidos e nunca compartilhados com terceiros.\n\n'
                'Utilizamos criptografia SSL em todas as transações.\n\n'
                'Seus dados de pagamento não são armazenados em nossos servidores.');
          }),
          _MenuItem(Icons.logout, 'Sair', 'Fazer logout', () => _logout(context), isDestructive: true),
        ],
      },
    ];

    return Column(
      children: sections.map((section) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Text(
                section['title'] as String,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6)],
              ),
              child: Column(
                children: (section['items'] as List<_MenuItem>).asMap().entries.map((e) {
                  final item = e.value;
                  final isLast = e.key == (section['items'] as List).length - 1;
                  return Column(
                    children: [
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (item.isDestructive ? AppColors.error : AppColors.primary)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.isDestructive ? AppColors.error : AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(item.title,
                            style: TextStyle(
                                fontSize: 14,
                                color: item.isDestructive ? AppColors.error : AppColors.textPrimary)),
                        subtitle: Text(item.subtitle,
                            style: const TextStyle(fontSize: 11, color: AppColors.textHint)),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.grey400, size: 18),
                        onTap: item.onTap,
                      ),
                      if (!isLast)
                        const Divider(height: 0, indent: 56, endIndent: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  void _openSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _SupportSheet(),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você será desconectado da sua conta.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              user.logout();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  // ── Modais funcionais ──────────────────────────────────────
  void _showSimpleSheet(BuildContext context, String title, IconData icon, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Icon(icon, color: AppColors.primary, size: 36),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fechar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              const Text('Meus Endereços', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.home_outlined, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text('Endereço Principal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ]),
                    SizedBox(height: 6),
                    Text('Adicione seu endereço de entrega no próximo pedido.\nEle ficará salvo aqui para compras futuras.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar Endereço'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _NotificationsSheet(),
    );
  }

  void _showSecuritySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _SecuritySheet(),
    );
  }

  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.blinds, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 12),
            const Text('Control Persianas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Versão 1.0.0', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            const Text('Persianas sob medida para todo o Brasil.\nQualidade garantida desde 2010.',
                textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            const Text('WhatsApp: (61) 98127-6447', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  _MenuItem(this.icon, this.title, this.subtitle, this.onTap, {this.isDestructive = false});
}

class _SupportSheet extends StatelessWidget {
  const _SupportSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text('Central de Suporte', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          InfoCard(
            icon: Icons.chat_outlined,
            title: 'WhatsApp',
            subtitle: '(61) 98127-6447 — Seg a Sex 8h–18h',
            iconColor: const Color(0xFF25D366),
            onTap: () {},
          ),
          const SizedBox(height: 8),
          InfoCard(
            icon: Icons.email_outlined,
            title: 'E-mail',
            subtitle: 'atendimento@controlpersianas.com.br',
            iconColor: AppColors.primary,
            onTap: () {},
          ),
          const SizedBox(height: 8),
          InfoCard(
            icon: Icons.help_center_outlined,
            title: 'FAQ',
            subtitle: 'Perguntas frequentes sobre instalação',
            onTap: () {},
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Notificações ─────────────────────────────────────────────
class _NotificationsSheet extends StatefulWidget {
  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}
class _NotificationsSheetState extends State<_NotificationsSheet> {
  bool _pedidos = true;
  bool _promocoes = true;
  bool _entrega = true;
  bool _novidades = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Notificações', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _pedidos,
            onChanged: (v) => setState(() => _pedidos = v),
            title: const Text('Atualizações de pedido'),
            subtitle: const Text('Status de produção e entrega', style: TextStyle(fontSize: 12)),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            value: _entrega,
            onChanged: (v) => setState(() => _entrega = v),
            title: const Text('Rastreamento de entrega'),
            subtitle: const Text('Código de rastreio e previsão', style: TextStyle(fontSize: 12)),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            value: _promocoes,
            onChanged: (v) => setState(() => _promocoes = v),
            title: const Text('Promoções e descontos'),
            subtitle: const Text('Ofertas especiais e cupons', style: TextStyle(fontSize: 12)),
            activeColor: AppColors.primary,
          ),
          SwitchListTile(
            value: _novidades,
            onChanged: (v) => setState(() => _novidades = v),
            title: const Text('Novidades e lançamentos'),
            subtitle: const Text('Novos modelos e coleções', style: TextStyle(fontSize: 12)),
            activeColor: AppColors.primary,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferências salvas!'), backgroundColor: AppColors.success),
                );
              },
              child: const Text('Salvar Preferências'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Segurança ────────────────────────────────────────────────
class _SecuritySheet extends StatefulWidget {
  const _SecuritySheet();
  @override
  State<_SecuritySheet> createState() => _SecuritySheetState();
}
class _SecuritySheetState extends State<_SecuritySheet> {
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscure1 = true, _obscure2 = true, _obscure3 = true;
  bool _loading = false;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Segurança', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Altere sua senha de acesso', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            TextFormField(
              controller: _currentPassCtrl,
              obscureText: _obscure1,
              decoration: InputDecoration(
                labelText: 'Senha atual',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPassCtrl,
              obscureText: _obscure2,
              decoration: InputDecoration(
                labelText: 'Nova senha',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPassCtrl,
              obscureText: _obscure3,
              decoration: InputDecoration(
                labelText: 'Confirmar nova senha',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscure3 ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscure3 = !_obscure3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : () async {
                  if (_newPassCtrl.text != _confirmPassCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('As senhas não coincidem.'), backgroundColor: AppColors.error),
                    );
                    return;
                  }
                  setState(() => _loading = true);
                  await Future.delayed(const Duration(seconds: 1));
                  if (mounted) {
                    setState(() => _loading = false);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Senha alterada com sucesso!'), backgroundColor: AppColors.success),
                    );
                  }
                },
                child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Alterar Senha'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
