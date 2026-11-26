import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assinei_e_esqueci/app/data/models/cartao_model.dart';

void main() {
  group('Testes Unitários da Desserialização do CartaoModel', () {
    test('1. Converte corHex quando enviada como String numérica (causa do erro no Logcat)', () {
      final json = {
        'id': '100',
        'usuarioId': '123',
        'nome': 'Cartão Inter',
        'bandeira': 'Mastercard',
        'ultimosDigitos': '4321',
        'corHex': '4279986762',
      };

      final model = CartaoModel.fromJson(json);

      expect(model.id, equals('100'));
      expect(model.nome, equals('Cartão Inter'));
      expect(model.cor, isA<Color>());
    });

    test('2. Converte corHex quando enviada como formato Hexadecimal (#1B2A4A)', () {
      final jsonHex = {
        'id': '101',
        'usuarioId': '123',
        'nome': 'Cartão Nubank',
        'bandeira': 'Visa',
        'ultimosDigitos': '8888',
        'corHex': '#1B2A4A',
      };

      final model = CartaoModel.fromJson(jsonHex);

      expect(model.cor.toARGB32(), equals(const Color(0xFF1B2A4A).toARGB32()));
    });

    test('3. Converte corHex quando enviada como int numérico', () {
      final jsonInt = {
        'id': '102',
        'usuarioId': '123',
        'nome': 'Cartão Itaú',
        'bandeira': 'Visa',
        'ultimosDigitos': '5555',
        'corHex': 4279986762,
      };

      final model = CartaoModel.fromJson(jsonInt);

      expect(model.cor, isA<Color>());
    });

    test('4. Aplica cor padrão quando corHex for nulo ou ausente', () {
      final jsonNulo = {
        'id': '103',
        'usuarioId': '123',
        'nome': 'Cartão Sem Cor',
        'bandeira': 'Visa',
        'ultimosDigitos': '1111',
        'corHex': null,
      };

      final model = CartaoModel.fromJson(jsonNulo);

      expect(model.cor, equals(const Color(0xFF1B2A4A)));
    });
  });
}
