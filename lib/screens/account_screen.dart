import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../widgets/common_widgets.dart';
import 'orders_screen.dart';

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
  bool _showRegister = false;

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
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
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
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      context.read<UserProvider>().login(
        UserModel(
          id: '1',
          name: 'Cliente Control',
          email: _emailCtrl.text.isNotEmpty ? _emailCtrl.text : 'cliente@email.com',
          phone: '(11) 9 9999-9999',
        ),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      context.read<UserProvider>().login(
        UserModel(
          id: '1',
          name: 'Novo Cliente',
          email: _emailCtrl.text.isNotEmpty ? _emailCtrl.text : 'novo@email.com',
          phone: '(11) 9 9999-9999',
        ),
      );
      setState(() => _loading = false);
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
          _MenuItem(Icons.favorite_outline, 'Lista de Desejos', 'Itens salvos', () {}),
          _MenuItem(Icons.location_on_outlined, 'Meus Endereços', 'Gerenciar endereços', () {}),
        ],
      },
      {
        'title': 'Configurações',
        'items': [
          _MenuItem(Icons.notifications_outlined, 'Notificações', 'Preferências de aviso', () {}),
          _MenuItem(Icons.lock_outline, 'Segurança', 'Senha e autenticação', () {}),
          _MenuItem(Icons.help_outline, 'Suporte', 'Central de ajuda', () => _openSupport(context)),
        ],
      },
      {
        'title': 'Sobre',
        'items': [
          _MenuItem(Icons.info_outline, 'Sobre o App', 'Versão 1.0.0', () {}),
          _MenuItem(Icons.policy_outlined, 'Política de Privacidade', 'Seus dados', () {}),
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
            subtitle: '(11) 9 9999-9999 — Seg a Sex 8h–18h',
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
