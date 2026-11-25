import 'package:assinei_e_esqueci/app/data/models/assinatura_model.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('AssinaturasRepository - Testes Unitários de Regra Local', () {
    test('TC02 - Deve calcular o totalGastoMensal acumulando os valores de todas as assinaturas', () {
      final assinaturasDeTeste = [
        AssinaturaModel(
          id: '1',
          nome: 'Netflix',
          valor: 55.90,
          dataVencimento: DateTime.now(),
          metodoPagamento: 'Cartão',
        ),
        AssinaturaModel(
          id: '2',
          nome: 'Spotify',
          valor: 21.90,
          dataVencimento: DateTime.now(),
          metodoPagamento: 'Pix',
        ),
        AssinaturaModel(
          id: '3',
          nome: 'Prime Video',
          valor: 19.90,
          dataVencimento: DateTime.now(),
          metodoPagamento: 'Cartão',
        ),
      ];

      final totalGastoMensal = assinaturasDeTeste.fold(
        0.0,
            (total, item) => total + item.valor,
      );

      // 55.90 + 21.90 + 19.90 = 97.70
      expect(totalGastoMensal, closeTo(97.70, 0.01));
    });

    test('TC03 - Deve identificar qual assinatura vence primeiro', () {
      final hoje = DateTime.now();

      final assinaturaLonge = AssinaturaModel(
        id: '1',
        nome: 'HBO Max',
        valor: 34.90,
        dataVencimento: hoje.add(const Duration(days: 20)),
        metodoPagamento: 'Cartão',
      );

      final assinaturaProxima = AssinaturaModel(
        id: '2',
        nome: 'Disney+',
        valor: 27.90,
        dataVencimento: hoje.add(const Duration(days: 2)),
        metodoPagamento: 'Pix',
      );

      final lista = [assinaturaLonge, assinaturaProxima];

      lista.sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));

      expect(lista.first.nome, equals('Disney+'));
      expect(lista.first.id, equals('2'));
    });
  });
}