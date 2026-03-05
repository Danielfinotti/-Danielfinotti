import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

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

class ShippingService {
  static Future<List<ShippingOption>> calculateShipping(String cep, double weightKg) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final cleanCep = cep.replaceAll(RegExp(r'\D'), '');
    final state = _getStateFromCep(cleanCep);
    return _getMockShipping(state, weightKg);
  }

  static String _getStateFromCep(String cep) {
    if (cep.isEmpty) return 'SP';
    final prefix = int.tryParse(cep.substring(0, 2)) ?? 0;
    if (prefix >= 1 && prefix <= 19) return 'SP';
    if (prefix >= 20 && prefix <= 28) return 'RJ';
    if (prefix >= 29 && prefix <= 29) return 'ES';
    if (prefix >= 30 && prefix <= 39) return 'MG';
    if (prefix >= 40 && prefix <= 48) return 'BA';
    if (prefix >= 49 && prefix <= 49) return 'SE';
    if (prefix >= 50 && prefix <= 56) return 'PE';
    if (prefix >= 57 && prefix <= 57) return 'AL';
    if (prefix >= 58 && prefix <= 58) return 'PB';
    if (prefix >= 59 && prefix <= 59) return 'RN';
    if (prefix >= 60 && prefix <= 63) return 'CE';
    if (prefix >= 64 && prefix <= 64) return 'PI';
    if (prefix >= 65 && prefix <= 65) return 'MA';
    if (prefix >= 66 && prefix <= 68) return 'PA';
    if (prefix >= 69 && prefix <= 69) return 'AM';
    if (prefix >= 70 && prefix <= 73) return 'DF';
    if (prefix >= 74 && prefix <= 76) return 'GO';
    if (prefix >= 77 && prefix <= 77) return 'TO';
    if (prefix >= 78 && prefix <= 78) return 'MT';
    if (prefix >= 79 && prefix <= 79) return 'MS';
    if (prefix >= 80 && prefix <= 87) return 'PR';
    if (prefix >= 88 && prefix <= 89) return 'SC';
    if (prefix >= 90 && prefix <= 99) return 'RS';
    return 'SP';
  }

  static List<ShippingOption> _getMockShipping(String state, double weightKg) {
    double pacPrice, sedexPrice;
    int pacMin, pacMax, sedexMin, sedexMax;
    switch (state) {
      case 'SP':
        pacPrice = 28.90; pacMin = 3; pacMax = 5;
        sedexPrice = 48.90; sedexMin = 1; sedexMax = 2;
        break;
      case 'RJ': case 'MG': case 'ES':
        pacPrice = 38.90; pacMin = 4; pacMax = 7;
        sedexPrice = 64.90; sedexMin = 2; sedexMax = 3;
        break;
      case 'PR': case 'SC': case 'RS':
        pacPrice = 42.90; pacMin = 5; pacMax = 8;
        sedexPrice = 72.90; sedexMin = 2; sedexMax = 4;
        break;
      default:
        pacPrice = 58.90; pacMin = 8; pacMax = 12;
        sedexPrice = 98.90; sedexMin = 3; sedexMax = 5;
    }
    final weightFactor = weightKg > 5 ? (weightKg / 5) : 1.0;
    return [
      ShippingOption(
        name: 'PAC (Correios)',
        carrier: 'Correios',
        price: pacPrice * weightFactor,
        minDays: pacMin,
        maxDays: pacMax,
        service: 'PAC',
      ),
      ShippingOption(
        name: 'SEDEX (Correios)',
        carrier: 'Correios',
        price: sedexPrice * weightFactor,
        minDays: sedexMin,
        maxDays: sedexMax,
        service: 'SEDEX',
      ),
      ShippingOption(
        name: 'Transportadora',
        carrier: 'Jadlog',
        price: (pacPrice * 0.85) * weightFactor,
        minDays: pacMin + 1,
        maxDays: pacMax + 2,
        service: 'PACKAGE',
      ),
    ];
  }
}

class PaymentService {
  static String generateOrderNumber() {
    final now = DateTime.now();
    return 'CPO${now.year}${now.month.toString().padLeft(2, '0')}${now.millisecond.toString().padLeft(3, '0')}';
  }

  static Future<Map<String, dynamic>> createPixPayment({
    required double amount,
    required String orderNumber,
    required String buyerName,
    required String buyerEmail,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'status': 'pending',
      'payment_id': 'PIX_${DateTime.now().millisecondsSinceEpoch}',
      'qr_code': 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
      'qr_code_text': '00020126330014BR.GOV.BCB.PIX0111${orderNumber}5204000053039865406${amount.toStringAsFixed(2).replaceAll('.', '')}5802BR5913${buyerName.substring(0, buyerName.length > 13 ? 13 : buyerName.length)}6008BRASILIA62070503***6304',
      'expires_at': DateTime.now().add(const Duration(minutes: 30)).toIso8601String(),
    };
  }

  static Future<Map<String, dynamic>> createCardPayment({
    required double amount,
    required String orderNumber,
    required int installments,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'status': 'approved',
      'payment_id': 'CARD_${DateTime.now().millisecondsSinceEpoch}',
      'installments': installments,
      'installment_amount': amount / installments,
    };
  }
}
