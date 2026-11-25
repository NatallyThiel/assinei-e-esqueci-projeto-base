import 'package:assinei_e_esqueci/app/data/models/assinatura_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssinaturaModel - Testes Unitários', () {
    test('TC01 - Verifica se o cálculo de dias restantes até o próximo vencimento de uma assinatura está correto', () {
        final hoje = DateTime.now();
        final dataFutura = DateTime(hoje.year, hoje.month, hoje.day + 5);

        final assinatura = AssinaturaModel(
          id: '1',
          nome: 'Netflix',
          valor: 55.90,
          dataVencimento: dataFutura,
          metodoPagamento: 'Cartão de Crédito',
        );

        //Calcula a diferença em dias até a data de vencimento
        final diferencaDias = assinatura.dataVencimento.difference(
            DateTime(hoje.year, hoje.month, hoje.day)
        ).inDays;

        //O resultado deve ser exatamente 5 dias
        expect(diferencaDias, equals(5));
    });

    test('TC04 - Verifica se a desserialização de JSON para AssinaturaModel converte corretamente os dados e datas', () {
      final jsonApi = {
        'id': 10,
        'nome': 'Spotify',
        'valor': 21.90,
        'dataVencimento': '2026-12-15T00:00:00.000',
        'metodoPagamento': 'Pix',
        'plano': 'Premium Individual',
        'iconeCodePoint': 58270,
        'corIconeHex': 4280019530,
        'plataforma': 'Android',
        'testeGratis': false,
      };

      final model = AssinaturaModel.fromJson(jsonApi);

      //Aqui valida se os campos foram tipados e atribuídos corretamente
      expect(model.id, equals('10'));
      expect(model.nome, equals('Spotify'));
      expect(model.valor, equals(21.90));
      expect(model.metodoPagamento, equals('Pix'));
      expect(model.plano, equals('Premium Individual'));
      expect(model.dataVencimento, equals(DateTime.parse('2026-12-15T00:00:00.000')));
      expect(model.testeGratis, isFalse);
    });
  });
}