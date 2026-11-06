import 'package:assinei_e_esqueci/app/data/models/assinatura_model.dart';
import 'package:assinei_e_esqueci/app/data/repositories/assinatura_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group('Testes de Integração - Navegação e UI', () {
    testWidgets(
      'TC06 - Verifica a atualização em tempo real do valor total na interface ao adicionar assinatura via ListenableBuilder',
          (WidgetTester tester) async {
        final repository = AssinaturasRepository.instance;

        //Monta um widget reativo simulando o card da Home que consime o repositório
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListenableBuilder(
                listenable: repository,
                builder: (context, child) {
                  return Text(
                    'Total: R\$ ${repository.totalGastoMensal.toStringAsFixed(2)}',
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Total: R\$ 0.00'), findsOneWidget);

        //Instancia uma nova assinatura e simula a atualização do repositório
        final novaAssinatura = AssinaturaModel(
          id: '1',
          nome: 'Netflix',
          valor: 55.90,
          dataVencimento: DateTime.now(),
          metodoPagamento: 'Cartão de Crédito',
        );

        //Simulando a resposta do cadastro bem-sucedido
        repository.assinaturas.add(novaAssinatura);
        repository.notifyListeners();

        await tester.pump();

        //Só para garantir que a interface atualizou o valor total automaticamente para R$ 55.90
        expect(find.text('Total: R\$ 55.90'), findsOneWidget);
        expect(find.text('Total: R\$ 0.00'), findsNothing);
      },
    );
  });
}