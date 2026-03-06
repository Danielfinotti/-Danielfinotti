import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

// ============================================================
// CONSTANTES GLOBAIS
// ============================================================
class AppConfig {
  // WhatsApp — substitua pelo número real quando informado
  static const String whatsappNumber = '5561981276447';
  static String get whatsappUrl => 'https://wa.me/$whatsappNumber';

  // Melhor Envio
  static const String melhorEnvioToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiYTBmOGI4NDM5ODY3OTU2ZDVmNmM0YWY1MGUyYTNhNTEzZjk1YTcxYjNkY2VmNTVkYThjYjFmYzFlYWMwNjBlZDI1ODIwNzI4MzExODY0NWQiLCJpYXQiOjE3NzI3MzUxMTQuMDE2MjQ0LCJuYmYiOjE3NzI3MzUxMTQuMDE2MjQ2LCJleHAiOjE4MDQyNzExMTQuMDA1MjU2LCJzdWIiOiJhMTNhYWZkNS0wODk4LTQwZmMtODU4MC03MGRmYzQ4YTM3OTciLCJzY29wZXMiOlsiY2FydC1yZWFkIiwiY2FydC13cml0ZSIsImNvbXBhbmllcy1yZWFkIiwiY29tcGFuaWVzLXdyaXRlIiwiY291cG9ucy1yZWFkIiwiY291cG9ucy13cml0ZSIsIm5vdGlmaWNhdGlvbnMtcmVhZCIsIm9yZGVycy1yZWFkIiwicHJvZHVjdHMtcmVhZCIsInByb2R1Y3RzLWRlc3Ryb3kiLCJwcm9kdWN0cy13cml0ZSIsInB1cmNoYXNlcy1yZWFkIiwic2hpcHBpbmctY2FsY3VsYXRlIiwic2hpcHBpbmctY2FuY2VsIiwic2hpcHBpbmctY2hlY2tvdXQiLCJzaGlwcGluZy1jb21wYW5pZXMiLCJzaGlwcGluZy1nZW5lcmF0ZSIsInNoaXBwaW5nLXByZXZpZXciLCJzaGlwcGluZy1wcmludCIsInNoaXBwaW5nLXNoYXJlIiwic2hpcHBpbmctdHJhY2tpbmciLCJlY29tbWVyY2Utc2hpcHBpbmciLCJ0cmFuc2FjdGlvbnMtcmVhZCIsInVzZXJzLXJlYWQiLCJ1c2Vycy13cml0ZSIsIndlYmhvb2tzLXJlYWQiLCJ3ZWJob29rcy13cml0ZSIsIndlYmhvb2tzLWRlbGV0ZSIsInRkZWFsZXItd2ViaG9vayJdfQ.dT_izd-Xa7sej28EvQYtRt36QAftjvmiUPq5VXcCR-TRGSgQKjsP1o4E7D0Mwt8zm2ecuh7nL1ExkpGLvgZoTElcwoAnkQ1T4a0VPfvH9lOE6qHmZMkmwb4mXiCRIPG0zgW2GaH5njdXN2Ha4Z9N--wKUBSK2EK-oJl5WlQbhJDtoeYgRLxDsbEkHs-5pgl3gBXeWazsacSqSkAouz45BjBTN-mbHunVrS-3BbFXvfEo7BtRlf1-MmdMOL2zrd0iaBsR5JekkKqOFtHYUzNk5GbsAwBSsazKcpo9ccIDuETBJWpD06eD34vzEmoctaPsS4sZokKaExf9ui19Z_qXF90yvmis8PsjUJ-ODnJCM2YWonQqNhSjgfw1aCE9MoHN_R2hK2qU60HqcpgfRDT2sH7ZtkR3Yn5U_SI5rzIyoqZEBDOJPF5MmNRX_9SFpkDOIoTtfD69pjJZLq6cQ_V8nU8qv-rShGGqij8DP727ioYLaS5mmpoQk6CrUxPF-xkRpfY-_V_QrngKzjjszRIC1dOs_23U1Q1RoBT04BCKFGnC_4T05PwuZJg3x5SCVqfCOXhY_ncxdUr--zhVqz9abEfGYyv_73uKDu7zgv7Pm7cBvguImLpoyptBj0Iq_jOdWEGyT1m1tMqwPXmqsXRZtdTrQQUa8Tx-bcekQcvU3zg';

  // CEP de origem (loja)
  static const String originCep = '01310100'; // Ajuste para o CEP real da loja

  // Mercado Pago
  static const String mpPublicKey = 'APP_USR-e7fa04a2-ae7c-4325-8cb3-b69ffa90acf7';
  static const String mpAccessToken =
      'APP_USR-5951470604212822-030516-4a211a3e4e815ec9c11cd062c2216563-3246982974';
}

// ============================================================
// CEP SERVICE
// ============================================================
class CepService {
  static Future<Address?> fetchAddress(String cep) async {
    try {
      final cleanCep = cep.replaceAll(RegExp(r'\D'), '');
      if (cleanCep.length != 8) return null;
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cleanCep/json/'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['erro'] == true) return null;
        return Address.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('CepService error: $e');
    }
    return null;
  }
}

// ============================================================
// SHIPPING SERVICE — Melhor Envio real
// ============================================================
class ShippingService {
  static const String _baseUrl = 'https://www.melhorenvio.com.br/api/v2';

  /// Calcula frete via Melhor Envio (API real).
  /// Dimensões padrão de uma caixa de persiana.
  static Future<List<ShippingOption>> calculateShipping(
      String destCep, double weightKg) async {
    final cleanDest = destCep.replaceAll(RegExp(r'\D'), '');
    if (cleanDest.length != 8) return _fallback();

    try {
      final body = jsonEncode({
        'from': {'postal_code': AppConfig.originCep},
        'to': {'postal_code': cleanDest},
        'package': {
          'height': 15,
          'width': 30,
          'length': 200,
          'weight': weightKg < 1 ? 1 : weightKg,
        },
        'options': {
          'insurance_value': 0,
          'receipt': false,
          'own_hand': false,
        },
        'services': '1,2,3,4,7,8', // PAC, SEDEX, Mini, + transportadoras
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/me/shipment/calculate'),
        headers: {
          'Authorization': 'Bearer ${AppConfig.melhorEnvioToken}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'ControlPersianas/1.0 (finottiborges@hotmail.com)',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<ShippingOption> options = [];

        for (final item in data) {
          if (item['error'] != null) continue;
          final price = double.tryParse(item['price']?.toString() ?? '') ?? 0;
          if (price <= 0) continue;

          options.add(ShippingOption(
            name: '${item['company']?['name'] ?? ''} — ${item['name'] ?? ''}',
            carrier: item['company']?['name'] ?? 'Transportadora',
            price: price,
            minDays: int.tryParse(item['delivery_range']?['min']?.toString() ?? '3') ?? 3,
            maxDays: int.tryParse(item['delivery_range']?['max']?.toString() ?? '7') ?? 7,
            service: item['id']?.toString() ?? '',
          ));
        }

        if (options.isNotEmpty) {
          options.sort((a, b) => a.price.compareTo(b.price));
          return options.take(4).toList();
        }
      }
      if (kDebugMode) debugPrint('MelhorEnvio status: ${response.statusCode} — ${response.body}');
    } catch (e) {
      if (kDebugMode) debugPrint('ShippingService error: $e');
    }

    // Fallback com valores estimados
    return _fallback();
  }

  static List<ShippingOption> _fallback() {
    return [
      ShippingOption(
        name: 'PAC (Correios)',
        carrier: 'Correios',
        price: 39.90,
        minDays: 5,
        maxDays: 10,
        service: 'PAC',
      ),
      ShippingOption(
        name: 'SEDEX (Correios)',
        carrier: 'Correios',
        price: 69.90,
        minDays: 2,
        maxDays: 4,
        service: 'SEDEX',
      ),
    ];
  }
}

// ============================================================
// MERCADO PAGO SERVICE — Integração real
// ============================================================
class MercadoPagoService {
  static const String _baseUrl = 'https://api.mercadopago.com';

  static String generateOrderNumber() {
    final now = DateTime.now();
    return 'CPO${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.millisecond.toString().padLeft(3, '0')}';
  }

  /// Cria pagamento PIX via Mercado Pago
  static Future<Map<String, dynamic>> createPixPayment({
    required double amount,
    required String orderNumber,
    required String buyerName,
    required String buyerEmail,
    required String buyerCpf,
  }) async {
    try {
      final nameParts = buyerName.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.last : firstName;

      final body = jsonEncode({
        'transaction_amount': double.parse(amount.toStringAsFixed(2)),
        'description': 'Control Persianas Online — Pedido $orderNumber',
        'payment_method_id': 'pix',
        'payer': {
          'email': buyerEmail,
          'first_name': firstName,
          'last_name': lastName,
          'identification': {
            'type': 'CPF',
            'number': buyerCpf.replaceAll(RegExp(r'\D'), ''),
          },
        },
        'external_reference': orderNumber,
        'notification_url':
            'https://controlpersianas.com.br/api/mercadopago/webhook',
        'date_of_expiration': DateTime.now()
            .add(const Duration(hours: 24))
            .toUtc()
            .toIso8601String(),
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/payments'),
        headers: {
          'Authorization': 'Bearer ${AppConfig.mpAccessToken}',
          'Content-Type': 'application/json',
          'X-Idempotency-Key': orderNumber,
        },
        body: body,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final txInfo = data['point_of_interaction']?['transaction_data'];
        return {
          'status': 'pending',
          'payment_id': data['id']?.toString() ?? '',
          'qr_code_text': txInfo?['qr_code'] ?? '',
          'qr_code_base64': txInfo?['qr_code_base64'] ?? '',
          'expires_at': data['date_of_expiration'] ?? '',
          'amount': amount,
        };
      }
      if (kDebugMode) debugPrint('MP PIX error: ${response.statusCode} ${response.body}');
    } catch (e) {
      if (kDebugMode) debugPrint('MP PIX exception: $e');
    }

    // Fallback — exibe tela de espera e orienta pagamento manual
    return {
      'status': 'pending',
      'payment_id': 'LOCAL_${DateTime.now().millisecondsSinceEpoch}',
      'qr_code_text': '',
      'qr_code_base64': '',
      'expires_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      'amount': amount,
      'fallback': true,
    };
  }

  /// Cria preferência de pagamento para Checkout Pro (cartão, boleto etc.)
  static Future<Map<String, dynamic>> createCheckoutPreference({
    required double amount,
    required String orderNumber,
    required String productDescription,
    required String buyerEmail,
    required int installments,
  }) async {
    try {
      final installmentValue =
          double.parse((amount / installments).toStringAsFixed(2));

      final body = jsonEncode({
        'items': [
          {
            'id': orderNumber,
            'title': productDescription,
            'quantity': 1,
            'unit_price': double.parse(amount.toStringAsFixed(2)),
            'currency_id': 'BRL',
          }
        ],
        'payer': {'email': buyerEmail},
        'payment_methods': {
          'installments': installments,
          'default_installments': installments,
        },
        'external_reference': orderNumber,
        'notification_url':
            'https://controlpersianas.com.br/api/mercadopago/webhook',
        'back_urls': {
          'success': 'https://controlpersianas.com.br/pedido/sucesso',
          'failure': 'https://controlpersianas.com.br/pedido/erro',
          'pending': 'https://controlpersianas.com.br/pedido/pendente',
        },
        'auto_return': 'approved',
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/checkout/preferences'),
        headers: {
          'Authorization': 'Bearer ${AppConfig.mpAccessToken}',
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'status': 'created',
          'preference_id': data['id'] ?? '',
          'init_point': data['init_point'] ?? '',
          'installments': installments,
          'installment_value': installmentValue,
          'amount': amount,
        };
      }
      if (kDebugMode) debugPrint('MP card error: ${response.statusCode} ${response.body}');
    } catch (e) {
      if (kDebugMode) debugPrint('MP card exception: $e');
    }

    return {
      'status': 'error',
      'installments': installments,
      'installment_value': amount / installments,
      'amount': amount,
    };
  }

  /// Consulta status de um pagamento
  static Future<String> getPaymentStatus(String paymentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v1/payments/$paymentId'),
        headers: {'Authorization': 'Bearer ${AppConfig.mpAccessToken}'},
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] ?? 'unknown';
      }
    } catch (e) {
      if (kDebugMode) debugPrint('MP status check error: $e');
    }
    return 'unknown';
  }
}

// Alias para compatibilidade com código existente
class PaymentService {
  static String generateOrderNumber() => MercadoPagoService.generateOrderNumber();

  static Future<Map<String, dynamic>> createPixPayment({
    required double amount,
    required String orderNumber,
    required String buyerName,
    required String buyerEmail,
    String buyerCpf = '',
  }) => MercadoPagoService.createPixPayment(
        amount: amount,
        orderNumber: orderNumber,
        buyerName: buyerName,
        buyerEmail: buyerEmail,
        buyerCpf: buyerCpf,
      );

  static Future<Map<String, dynamic>> createCardPayment({
    required double amount,
    required String orderNumber,
    required int installments,
    String buyerEmail = '',
  }) => MercadoPagoService.createCheckoutPreference(
        amount: amount,
        orderNumber: orderNumber,
        productDescription: 'Control Persianas Online — Pedido $orderNumber',
        buyerEmail: buyerEmail,
        installments: installments,
      );
}

// ============================================================
// WHATSAPP SERVICE
// ============================================================
class WhatsAppService {
  static String buildUrl({String message = ''}) {
    final encoded = Uri.encodeComponent(message);
    return 'https://wa.me/${AppConfig.whatsappNumber}?text=$encoded';
  }

  static String orderMessage(String orderNumber, double total) =>
      'Olá! Tenho uma dúvida sobre o pedido *$orderNumber* — Total: R\$ ${total.toStringAsFixed(2)}';

  static String supportMessage() =>
      'Olá! Gostaria de tirar uma dúvida sobre persianas.';

  static String budgetMessage(String model, String fabric, double width,
          double height, double price) =>
      'Olá! Gostaria de um orçamento:\n'
      '*Modelo:* $model\n'
      '*Tecido:* $fabric\n'
      '*Medidas:* ${width.toStringAsFixed(2)}m × ${height.toStringAsFixed(2)}m\n'
      '*Valor estimado:* R\$ ${price.toStringAsFixed(2)}';
}
