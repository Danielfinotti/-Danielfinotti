import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _cepCtrl.dispose();
    _numberCtrl.dispose();
    _complementCtrl.dispose();
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
    final installmentAmount = total / _installments;

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
                const SizedBox(height: 20),

                // PIX
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00897B).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.pix, color: Color(0xFF00897B), size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('PIX',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16)),
                              const Text('Aprovação imediata • Desconto 5%',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.textSecondary)),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Total: ${formatCurrency(total * 0.95)}',
                                  style: const TextStyle(
                                      color: AppColors.success,
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
                  ),
                ),

                const SizedBox(height: 12),

                // Cartão de Crédito
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
                        if (_paymentMethod == 'credit_card') ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Parcelas',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [1, 2, 3, 4, 6, 8, 10, 12].map((n) {
                              final isSelected = _installments == n;
                              return GestureDetector(
                                onTap: () => setState(() => _installments = n),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.grey100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.grey300,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${n}x',
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        formatCurrency(total / n),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white70
                                              : AppColors.textSecondary,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Resumo do pedido
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                          'Subtotal',
                          formatCurrency(cart.subtotal)),
                      _SummaryRow(
                          'Frete',
                          formatCurrency(_selectedShipping?.price ?? 0)),
                      if (_paymentMethod == 'pix')
                        _SummaryRow(
                            'Desconto PIX (5%)',
                            '- ${formatCurrency(total * 0.05)}',
                            isDiscount: true),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(
                            _paymentMethod == 'pix'
                                ? formatCurrency(total * 0.95)
                                : formatCurrency(total),
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
                              '$_installments x ${formatCurrency(installmentAmount)}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _CheckoutFooter(
          subtotal: cart.subtotal,
          shipping: _selectedShipping?.price,
          onNext: () => _processPayment(cart),
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
      if (_paymentMethod == 'pix') {
        await PaymentService.createPixPayment(
          amount: cart.subtotal + (_selectedShipping?.price ?? 0),
          orderNumber: orderNumber,
          buyerName: 'Cliente',
          buyerEmail: 'cliente@email.com',
        );
      } else {
        await PaymentService.createCardPayment(
          amount: cart.subtotal + (_selectedShipping?.price ?? 0),
          orderNumber: orderNumber,
          installments: _installments,
        );
      }

      // Criar pedido
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        orderNumber: orderNumber,
        items: cart.items.toList(),
        address: _address!,
        shipping: _selectedShipping!,
        status: OrderStatus.pagamentoAprovado,
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
              amount: (context.read<CartProvider>().subtotal + (_selectedShipping?.price ?? 0)) * 0.95,
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
                _ConfirmRow(Icons.inventory_2_outlined, 'Status', 'Pagamento Aprovado', AppColors.success),
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

class _PixPaymentCard extends StatelessWidget {
  final double amount;
  final String orderNumber;
  const _PixPaymentCard({required this.amount, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00897B).withValues(alpha: 0.4)),
      ),
      child: Column(
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
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.qr_code_2, size: 80, color: AppColors.grey700),
                const SizedBox(height: 8),
                Text('QR Code PIX', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(formatCurrency(amount),
                    style: const TextStyle(
                        color: Color(0xFF00897B),
                        fontWeight: FontWeight.bold,
                        fontSize: 22)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text(
                    '00020126330014BR.GOV.BCB.PIX...',
                    style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.copy, size: 16, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('Expira em 30 minutos',
              style: TextStyle(color: AppColors.warning, fontSize: 12)),
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
  const _SummaryRow(this.label, this.value, {this.isDiscount = false});

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
