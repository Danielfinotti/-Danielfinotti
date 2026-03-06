import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/services.dart';
import '../widgets/common_widgets.dart';
import 'orders_screen.dart';
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _step = 0; // 0=Endereço, 1=Frete, 2=Pagamento, 3=Confirmação

  // Endereço
  final _cepCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _complementCtrl = TextEditingController();
  Address? _address;
  bool _loadingCep = false;

  // Frete
  List<ShippingOption>? _shippingOptions;
  ShippingOption? _selectedShipping;
  bool _loadingShipping = false;

  // Pagamento
  String _paymentMethod = 'pix'; // pix | credit_card
  int _installments = 1;
  bool _processingPayment = false;

  // ── Valor salvo antes de limpar o carrinho ──
  double _savedTotal = 0;

  // ── Taxas de parcelamento Mercado Pago ──
  // Taxas reais cobradas pelo MP conforme configuração padrão da conta
  // (vendedor paga a taxa; o valor exibido é o que o COMPRADOR paga com acréscimo)
  static const Map<int, double> _mpInstallmentRates = {
    1:  0.0,    // À vista — sem juros
    2:  0.0,    // Sem juros (padrão MP até 2x para muitos lojistas)
    3:  0.0,    // Sem juros (comum até 3x)
    4:  0.0699, // 6,99% a.m. acumulado
    6:  0.1049, // 10,49%
    8:  0.1399, // 13,99%
    10: 0.1749, // 17,49%
    12: 0.2099, // 20,99%
  };

  /// Retorna o valor total que o comprador paga numa dada parcela
  double _totalWithInterest(double base, int n) {
    final rate = _mpInstallmentRates[n] ?? 0.0;
    return base * (1 + rate);
  }

  /// Valor de cada parcela
  double _installmentValue(double base, int n) => _totalWithInterest(base, n) / n;

  // ── Dados do cartão de crédito ──
  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();

  // ── Dados do PIX ──
  final _pixNameCtrl = TextEditingController();
  final _pixCpfCtrl = TextEditingController();

  // Validação do formulário de pagamento
  bool get _paymentFormValid {
    if (_paymentMethod == 'pix') {
      return _pixNameCtrl.text.trim().length >= 3 &&
          _pixCpfCtrl.text.replaceAll(RegExp(r'\D'), '').length == 11;
    } else {
      final cardNum = _cardNumberCtrl.text.replaceAll(' ', '');
      return cardNum.length == 16 &&
          _cardNameCtrl.text.trim().length >= 3 &&
          _cardExpiryCtrl.text.length >= 5 &&
          _cardCvvCtrl.text.length >= 3;
    }
  }

  @override
  void dispose() {
    _cepCtrl.dispose();
    _numberCtrl.dispose();
    _complementCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    _pixNameCtrl.dispose();
    _pixCpfCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Finalizar Compra'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildStepIndicator(),
        ),
      ),
      body: _step == 0
          ? _buildAddressStep()
          : _step == 1
              ? _buildShippingStep()
              : _step == 2
                  ? _buildPaymentStep(cart)
                  : _buildConfirmationStep(),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Endereço', 'Frete', 'Pagamento', 'Confirmação'];
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(steps.length, (i) {
          final done = i < _step;
          final current = i == _step;
          return Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? AppColors.successLight
                        : current
                            ? Colors.white
                            : Colors.white24,
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check, color: Colors.white, size: 12)
                        : Text('${i + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: current
                                  ? AppColors.primary
                                  : Colors.white60,
                            )),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(steps[i],
                          style: TextStyle(
                            fontSize: 10,
                            color: current ? Colors.white : Colors.white60,
                            fontWeight: current ? FontWeight.bold : FontWeight.normal,
                          )),
                      if (i < steps.length - 1)
                        Container(height: 1, color: Colors.white24, margin: const EdgeInsets.only(top: 2)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // PASSO 1 — ENDEREÇO
  // ============================================================
  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Endereço de Entrega', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('Informe onde você quer receber sua persiana',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),

          // CEP
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _cepCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'CEP *',
                    hintText: '00000-000',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  maxLength: 9,
                  onChanged: (v) {
                    final clean = v.replaceAll(RegExp(r'\D'), '');
                    if (clean.length == 8) _lookupCep(clean);
                  },
                ),
              ),
              const SizedBox(width: 12),
              _loadingCep
                  ? const Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: CircularProgressIndicator(),
                    )
                  : TextButton(
                      onPressed: () {
                        final clean = _cepCtrl.text.replaceAll(RegExp(r'\D'), '');
                        if (clean.length == 8) _lookupCep(clean);
                      },
                      child: const Text('Buscar'),
                    ),
            ],
          ),

          if (_address != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                      const SizedBox(width: 6),
                      Text('CEP encontrado!',
                          style: TextStyle(
                              color: AppColors.success, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${_address!.street}, ${_address!.neighborhood}',
                      style: const TextStyle(fontSize: 13)),
                  Text('${_address!.city} - ${_address!.state}',
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _numberCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número *',
                prefixIcon: Icon(Icons.tag_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _complementCtrl,
              decoration: const InputDecoration(
                labelText: 'Complemento',
                hintText: 'Apto, Bloco, etc.',
                prefixIcon: Icon(Icons.apartment_outlined),
              ),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: 'Calcular Frete',
              icon: Icons.local_shipping_outlined,
              onPressed:
                  _address != null && _numberCtrl.text.isNotEmpty ? _goToShipping : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _lookupCep(String cep) async {
    setState(() => _loadingCep = true);
    final addr = await CepService.fetchAddress(cep);
    setState(() {
      _address = addr;
      _loadingCep = false;
    });
    if (addr == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('CEP não encontrado. Verifique e tente novamente.'),
            backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _goToShipping() async {
    setState(() { _loadingShipping = true; _step = 1; });
    final opts = await ShippingService.calculateShipping(
        _cepCtrl.text, AppConstants.defaultWeightKg);
    setState(() {
      _shippingOptions = opts;
      _selectedShipping = opts.isNotEmpty ? opts[0] : null;
      _loadingShipping = false;
    });
  }

  // ============================================================
  // PASSO 2 — FRETE
  // ============================================================
  Widget _buildShippingStep() {
    return Column(
      children: [
        Expanded(
          child: _loadingShipping
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Calculando opções de entrega...'),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Opções de Entrega',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text('Entrega para: ${_address?.city} - ${_address?.state}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 20),
                      ...?_shippingOptions?.map((opt) {
                        final isSelected = _selectedShipping == opt;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedShipping = opt),
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
                                color: isSelected ? AppColors.primary : AppColors.grey200,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isSelected ? AppColors.primary : AppColors.grey400)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.local_shipping_outlined,
                                    color: isSelected ? AppColors.primary : AppColors.grey500,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(opt.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600, fontSize: 14)),
                                      Text(opt.deliveryText,
                                          style: const TextStyle(
                                              fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                Text(
                                  opt.price == 0
                                      ? 'Grátis'
                                      : formatCurrency(opt.price),
                                  style: TextStyle(
                                    color: opt.price == 0
                                        ? AppColors.success
                                        : AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.check_circle,
                                      color: AppColors.primary, size: 20),
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
        if (!_loadingShipping)
          _CheckoutFooter(
            subtotal: context.read<CartProvider>().subtotal,
            shipping: _selectedShipping?.price,
            onNext: _selectedShipping != null
                ? () => setState(() => _step = 2)
                : null,
            nextLabel: 'Ir para Pagamento',
          ),
      ],
    );
  }

  // ============================================================
  // PASSO 3 — PAGAMENTO
  // ============================================================
  Widget _buildPaymentStep(CartProvider cart) {
    final total = cart.subtotal + (_selectedShipping?.price ?? 0);
    // Sem desconto PIX — valor real do carrinho + frete
    final totalWithInterest = _totalWithInterest(total, _installments);
    final installmentValue = _installmentValue(total, _installments);
    final hasInterest = (_mpInstallmentRates[_installments] ?? 0) > 0;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Forma de Pagamento',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                const Text(
                  'Preencha os dados para finalizar o pedido',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 20),

                // ── Seletor PIX ──
                GestureDetector(
                  onTap: () => setState(() => _paymentMethod = 'pix'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _paymentMethod == 'pix'
                          ? AppColors.success.withValues(alpha: 0.05)
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _paymentMethod == 'pix'
                            ? AppColors.success
                            : AppColors.grey200,
                        width: _paymentMethod == 'pix' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00897B).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.pix,
                                  color: Color(0xFF00897B), size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('PIX',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Text('Aprovação imediata • Sem acréscimo',
                                      style: TextStyle(
                                          fontSize: 12, color: AppColors.textSecondary)),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00897B).withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Total: ${formatCurrency(total)}',
                                      style: const TextStyle(
                                          color: Color(0xFF00897B),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_paymentMethod == 'pix')
                              const Icon(Icons.check_circle, color: AppColors.success),
                          ],
                        ),

                        // Formulário PIX
                        if (_paymentMethod == 'pix') ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text('Dados do pagador',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _pixNameCtrl,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Nome completo *',
                              prefixIcon: Icon(Icons.person_outlined),
                              hintText: 'Ex: João da Silva',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _pixCpfCtrl,
                            onChanged: (v) {
                              // Formata CPF
                              final digits = v.replaceAll(RegExp(r'\D'), '');
                              String formatted = digits;
                              if (digits.length >= 3) formatted = '${digits.substring(0, 3)}.${digits.substring(3)}';
                              if (digits.length >= 6) formatted = '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6)}';
                              if (digits.length >= 9) formatted = '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
                              if (digits.length > 11) formatted = '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9, 11)}';
                              if (_pixCpfCtrl.text != formatted) {
                                _pixCpfCtrl.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(offset: formatted.length),
                                );
                              }
                              setState(() {});
                            },
                            keyboardType: TextInputType.number,
                            maxLength: 14,
                            decoration: const InputDecoration(
                              labelText: 'CPF *',
                              prefixIcon: Icon(Icons.badge_outlined),
                              hintText: '000.000.000-00',
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppColors.success.withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: AppColors.success, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Após confirmar, você receberá o QR Code PIX para pagamento.',
                                    style: TextStyle(
                                        fontSize: 11, color: AppColors.success),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Seletor Cartão de Crédito ──
                GestureDetector(
                  onTap: () => setState(() => _paymentMethod = 'credit_card'),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _paymentMethod == 'credit_card'
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _paymentMethod == 'credit_card'
                            ? AppColors.primary
                            : AppColors.grey200,
                        width: _paymentMethod == 'credit_card' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.credit_card,
                                  color: AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Cartão de Crédito',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                                  const Text('Parcelamento em até 12x',
                                      style: TextStyle(
                                          fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            if (_paymentMethod == 'credit_card')
                              const Icon(Icons.check_circle, color: AppColors.primary),
                          ],
                        ),

                        // Formulário cartão
                        if (_paymentMethod == 'credit_card') ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text('Dados do cartão',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 10),

                          // Número do cartão
                          TextFormField(
                            controller: _cardNumberCtrl,
                            onChanged: (v) {
                              final digits = v.replaceAll(' ', '').replaceAll(RegExp(r'\D'), '');
                              final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
                              final formatted = limited.replaceAllMapped(
                                RegExp(r'.{4}'),
                                (m) => '${m.group(0)} ',
                              ).trim();
                              if (_cardNumberCtrl.text != formatted) {
                                _cardNumberCtrl.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(offset: formatted.length),
                                );
                              }
                              setState(() {});
                            },
                            keyboardType: TextInputType.number,
                            maxLength: 19,
                            decoration: const InputDecoration(
                              labelText: 'Número do cartão *',
                              prefixIcon: Icon(Icons.credit_card),
                              hintText: '0000 0000 0000 0000',
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Nome no cartão
                          TextFormField(
                            controller: _cardNameCtrl,
                            onChanged: (_) => setState(() {}),
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Nome no cartão *',
                              prefixIcon: Icon(Icons.person_outlined),
                              hintText: 'NOME SOBRENOME',
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Validade + CVV
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _cardExpiryCtrl,
                                  onChanged: (v) {
                                    final d = v.replaceAll('/', '').replaceAll(RegExp(r'\D'), '');
                                    final limited = d.length > 4 ? d.substring(0, 4) : d;
                                    final fmt = limited.length >= 3
                                        ? '${limited.substring(0, 2)}/${limited.substring(2)}'
                                        : limited;
                                    if (_cardExpiryCtrl.text != fmt) {
                                      _cardExpiryCtrl.value = TextEditingValue(
                                        text: fmt,
                                        selection: TextSelection.collapsed(offset: fmt.length),
                                      );
                                    }
                                    setState(() {});
                                  },
                                  keyboardType: TextInputType.number,
                                  maxLength: 5,
                                  decoration: const InputDecoration(
                                    labelText: 'Validade *',
                                    hintText: 'MM/AA',
                                    prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                                    counterText: '',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _cardCvvCtrl,
                                  onChanged: (_) => setState(() {}),
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'CVV *',
                                    hintText: '000',
                                    prefixIcon: Icon(Icons.lock_outline, size: 18),
                                    counterText: '',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Seletor de parcelas com juros reais MP
                          const Text('Parcelamento',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 4),
                          const Text(
                            'Até 3x sem juros • Acima de 3x com juros Mercado Pago',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [1, 2, 3, 4, 6, 8, 10, 12].map((n) {
                              final isSelected = _installments == n;
                              final rate = _mpInstallmentRates[n] ?? 0.0;
                              final hasRate = rate > 0;
                              final instTotal = _totalWithInterest(total, n);
                              final instValue = instTotal / n;
                              return GestureDetector(
                                onTap: () => setState(() => _installments = n),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.grey100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : hasRate ? AppColors.warning.withValues(alpha: 0.5) : AppColors.grey300,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(mainAxisSize: MainAxisSize.min, children: [
                                        Text('${n}x',
                                            style: TextStyle(
                                              color: isSelected ? Colors.white : AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            )),
                                        if (hasRate) ...[const SizedBox(width: 3),
                                          Text('*',
                                              style: TextStyle(
                                                color: isSelected ? Colors.white70 : AppColors.warning,
                                                fontSize: 13, fontWeight: FontWeight.bold)),
                                        ],
                                      ]),
                                      Text(
                                        formatCurrency(instValue),
                                        style: TextStyle(
                                          color: isSelected ? Colors.white70 : AppColors.textSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                      if (hasRate)
                                        Text(
                                          'Total: ${formatCurrency(instTotal)}',
                                          style: TextStyle(
                                            color: isSelected ? Colors.white54 : AppColors.warning,
                                            fontSize: 9,
                                          ),
                                        ),
                                      if (!hasRate)
                                        Text(
                                          'sem juros',
                                          style: TextStyle(
                                            color: isSelected ? Colors.white54 : AppColors.success,
                                            fontSize: 9,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '* Juros cobrados pelo Mercado Pago. O valor total já inclui todos os acréscimos.',
                            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Resumo do pedido ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow('Subtotal', formatCurrency(cart.subtotal)),
                      _SummaryRow('Frete', formatCurrency(_selectedShipping?.price ?? 0)),
                      if (_paymentMethod == 'credit_card' && hasInterest)
                        _SummaryRow(
                          'Juros (${((_mpInstallmentRates[_installments] ?? 0) * 100).toStringAsFixed(2)}%)',
                          '+ ${formatCurrency(totalWithInterest - total)}',
                        ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            _paymentMethod == 'pix'
                                ? formatCurrency(total)
                                : formatCurrency(totalWithInterest),
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ],
                      ),
                      if (_paymentMethod == 'credit_card' && _installments > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$_installments x ${formatCurrency(installmentValue)}${hasInterest ? " (com juros)" : " sem juros"}',
                              style: TextStyle(
                                fontSize: 12,
                                color: hasInterest ? AppColors.warning : AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Aviso de campos obrigatórios
                if (!_paymentFormValid) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Preencha todos os campos obrigatórios (*) para prosseguir.',
                            style:
                                TextStyle(color: AppColors.warning, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        _CheckoutFooter(
          subtotal: cart.subtotal,
          shipping: _selectedShipping?.price,
          onNext: _paymentFormValid ? () => _processPayment(cart) : null,
          nextLabel: 'Confirmar Pagamento',
          loading: _processingPayment,
        ),
      ],
    );
  }

  Future<void> _processPayment(CartProvider cart) async {
    setState(() => _processingPayment = true);
    try {
      final orderNumber = PaymentService.generateOrderNumber();
      final rawTotal = cart.subtotal + (_selectedShipping?.price ?? 0);
      // PIX: sem desconto/acréscimo. Cartão: aplica juros do MP conforme parcelas
      final finalTotal = _paymentMethod == 'pix'
          ? rawTotal
          : _totalWithInterest(rawTotal, _installments);

      // Salvar valor total ANTES de limpar o carrinho
      _savedTotal = finalTotal;

      if (_paymentMethod == 'pix') {
        await PaymentService.createPixPayment(
          amount: finalTotal,
          orderNumber: orderNumber,
          buyerName: _pixNameCtrl.text.trim(),
          buyerEmail: 'cliente@email.com',
        );
      } else {
        await PaymentService.createCardPayment(
          amount: finalTotal,
          orderNumber: orderNumber,
          installments: _installments,
        );
      }

      // Criar pedido — PIX inicia como pendente; cartão simula aprovação
      final initialStatus = _paymentMethod == 'pix'
          ? OrderStatus.pagamentoPendente
          : OrderStatus.pagamentoAprovado;

      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        orderNumber: orderNumber,
        items: cart.items.toList(),
        address: _address!,
        shipping: _selectedShipping!,
        status: initialStatus,
        createdAt: DateTime.now(),
        subtotal: cart.subtotal,
        shippingCost: _selectedShipping!.price,
        paymentMethod: _paymentMethod == 'pix' ? 'PIX' : 'Cartão $_installments x',
      );

      if (mounted) {
        context.read<OrderProvider>().addOrder(order);
        cart.clear();
        setState(() { _processingPayment = false; _step = 3; });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processingPayment = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao processar pagamento. Tente novamente.'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  // ============================================================
  // PASSO 4 — CONFIRMAÇÃO
  // ============================================================
  Widget _buildConfirmationStep() {
    final orders = context.read<OrderProvider>().orders;
    final lastOrder = orders.isNotEmpty ? orders.first : null;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 30, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: AppColors.success, size: 72),
          ),
          const SizedBox(height: 20),
          Text('Pedido Confirmado!',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.success)),
          const SizedBox(height: 8),
          if (lastOrder != null)
            Text(
              'Pedido #${lastOrder.orderNumber}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
          const SizedBox(height: 24),

          if (_paymentMethod == 'pix')
            _PixPaymentCard(
              amount: _savedTotal,
              orderNumber: lastOrder?.orderNumber ?? '',
            ),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
            ),
            child: Column(
              children: [
                _ConfirmRow(Icons.inventory_2_outlined, 'Status',
              _paymentMethod == 'pix' ? 'Aguardando Pagamento PIX' : 'Pagamento Aprovado',
              _paymentMethod == 'pix' ? AppColors.warning : AppColors.success),
                _ConfirmRow(Icons.access_time, 'Produção', '7 a 10 dias úteis', AppColors.primary),
                _ConfirmRow(Icons.local_shipping_outlined, 'Entrega', _selectedShipping?.deliveryText ?? '', AppColors.primary),
                _ConfirmRow(Icons.notifications_outlined, 'Atualizações', 'Via e-mail e push', AppColors.grey600),
              ],
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
                (r) => r.isFirst,
              ),
              icon: const Icon(Icons.receipt_long_outlined),
              label: const Text('Acompanhar Pedido'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Voltar ao Início'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PixPaymentCard extends StatefulWidget {
  final double amount;
  final String orderNumber;
  const _PixPaymentCard({required this.amount, required this.orderNumber});

  @override
  State<_PixPaymentCard> createState() => _PixPaymentCardState();
}

class _PixPaymentCardState extends State<_PixPaymentCard> {
  bool _copied = false;

  String get _pixCode {
    // Gera código PIX simulado mas realista com o valor real do pedido
    final amountStr = widget.amount.toStringAsFixed(2);
    final orderRef = widget.orderNumber.replaceAll(RegExp(r'\D'), '').padLeft(8, '0').substring(0, 8);
    return '00020126580014BR.GOV.BCB.PIX0136controlpersianas@pagamentos.com.br0220Pedido ${orderRef}5204000053039865802BR5925Control Persianas Online6009SAO PAULO62070503***6304${_crc(amountStr)}';
  }

  String _crc(String val) {
    // Simula CRC para exibição
    final code = val.hashCode.abs() % 10000;
    return code.toRadixString(16).toUpperCase().padLeft(4, '0');
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _pixCode));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Código PIX copiado!'),
          ],
        ),
        backgroundColor: Color(0xFF00897B),
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00897B).withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pix, color: Color(0xFF00897B), size: 24),
              SizedBox(width: 8),
              Text('Pagar com PIX',
                  style: TextStyle(
                      color: Color(0xFF00897B), fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Escaneie o QR Code ou copie o código abaixo',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // QR Code visual
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00897B).withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2, size: 100, color: AppColors.grey700),
                  const SizedBox(height: 8),
                  Text('Valor a pagar', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(
                    formatCurrency(widget.amount),
                    style: const TextStyle(
                        color: Color(0xFF00897B),
                        fontWeight: FontWeight.bold,
                        fontSize: 26)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Expira em 30 minutos',
                        style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Código PIX copiável
          const Text('Código PIX (Copia e Cola)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _copyCode,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _copied
                    ? const Color(0xFF00897B).withValues(alpha: 0.08)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _copied
                      ? const Color(0xFF00897B).withValues(alpha: 0.5)
                      : AppColors.grey300,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _pixCode,
                      style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                          color: AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _copied ? Icons.check_circle : Icons.copy,
                    size: 20,
                    color: _copied ? const Color(0xFF00897B) : AppColors.primary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(_copied ? Icons.check : Icons.copy, size: 18),
              label: Text(_copied ? 'Código Copiado!' : 'Copiar Código PIX'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _copied ? const Color(0xFF00897B) : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: _copyCode,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Após confirmar o pagamento no seu banco, seu pedido será processado automaticamente em até 5 minutos.',
                    style: TextStyle(fontSize: 11, color: AppColors.primary),
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

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _ConfirmRow(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label, value;
  final bool isDiscount;
  final bool isInterest;
  const _SummaryRow(this.label, this.value, {this.isDiscount = false, this.isInterest = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDiscount ? AppColors.success : AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _CheckoutFooter extends StatelessWidget {
  final double subtotal;
  final double? shipping;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool loading;

  const _CheckoutFooter({
    required this.subtotal,
    this.shipping,
    this.onNext,
    this.nextLabel = 'Continuar',
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 12, offset: const Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (shipping != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total estimado:',
                    style: TextStyle(color: AppColors.textSecondary)),
                Text(
                  formatCurrency(subtotal + shipping!),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary),
                ),
              ],
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              label: nextLabel,
              loading: loading,
              onPressed: onNext,
              icon: Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }
}
