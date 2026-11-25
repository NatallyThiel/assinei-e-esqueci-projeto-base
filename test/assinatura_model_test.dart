import 'package:flutter_test/flutter_test.dart';
import 'package:assinei_e_esqueci/app/data/models/assinatura_model.dart';

void main() {
  group('Testes Unitários da Categoria em AssinaturaModel', () {
    test('1. Converte categoria corretamente do JSON', () {
      final json = {
        'id': '10',
        'nome': 'Netflix',
        'valor': 39.90,
        'dataVencimento': '2025-05-10T00:00:00.000',
        'metodoPagamento': 'Cartão',
        'categoria': 'ENTRETENIMENTO',
      };

      final model = AssinaturaModel.fromJson(json);

      expect(model.id, equals('10'));
      expect(model.categoria, equals('ENTRETENIMENTO'));
    });

    test('2. Aplica fallback para OUTROS quando categoria for nula ou em branco', () {
      final jsonSemCategoria = {
        'id': '11',
        'nome': 'Serviço Sem Categoria',
        'valor': 15.00,
        'dataVencimento': '2025-06-15T00:00:00.000',
        'metodoPagamento': 'Pix',
        'categoria': null,
      };

      final model = AssinaturaModel.fromJson(jsonSemCategoria);

      expect(model.categoria, equals('OUTROS'));

      final jsonComEspacos = {
        'id': '12',
        'nome': 'Serviço Espaços',
        'valor': 20.00,
        'dataVencimento': '2025-07-20T00:00:00.000',
        'metodoPagamento': 'Boleto',
        'categoria': '   ',
      };

      final modelEspacos = AssinaturaModel.fromJson(jsonComEspacos);

      expect(modelEspacos.categoria, equals('OUTROS'));
    });

    test('3. Inclui categoria no toJson()', () {
      final model = AssinaturaModel(
        id: '20',
        nome: 'Spotify',
        valor: 21.90,
        dataVencimento: DateTime(2025, 8, 1),
        metodoPagamento: 'Cartão',
        categoria: 'MUSICA',
      );

      final json = model.toJson();

      expect(json['categoria'], equals('MUSICA'));
    });

    test('4. Atualiza categoria via copyWith()', () {
      final model = AssinaturaModel(
        id: '30',
        nome: 'Canva',
        valor: 35.00,
        dataVencimento: DateTime(2025, 9, 1),
        metodoPagamento: 'Cartão',
        categoria: 'OUTROS',
      );

      final atualizada = model.copyWith(categoria: 'SOFTWARE');

      expect(atualizada.categoria, equals('SOFTWARE'));
    });
  });
}
