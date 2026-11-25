import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:assinei_e_esqueci/app/data/models/resumo_financeiro_model.dart';
import 'package:assinei_e_esqueci/app/data/repositories/assinatura_repository.dart';
import 'package:assinei_e_esqueci/app/data/repositories/usuario_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  final usuarioRepository = UsuarioRepository.instance;
  final assinaturaRepository = AssinaturasRepository.instance;

  setUp(() async {
    await usuarioRepository.logout();
  });

  group('Testes Unitários do ResumoFinanceiroModel', () {
    test('1. Converte JSON do Resumo Financeiro corretamente', () {
      final json = {
        'totalValoresAtivos': 120.50,
        'quantidadeAssinaturasAtivas': 3,
        'gastosPorCategoria': {
          'ENTRETENIMENTO': 50.50,
          'MUSICA': 20.00,
          'SOFTWARE': 50.00,
        },
      };

      final model = ResumoFinanceiroModel.fromJson(json);

      expect(model.totalValoresAtivos, equals(120.50));
      expect(model.quantidadeAssinaturasAtivas, equals(3));
      expect(model.gastosPorCategoria['ENTRETENIMENTO'], equals(50.50));
      expect(model.gastosPorCategoria['MUSICA'], equals(20.00));
      expect(model.gastosPorCategoria['SOFTWARE'], equals(50.00));
    });

    test('2. Trata inteiros como num na conversão para double e quantidade', () {
      final jsonComInteiros = {
        'totalValoresAtivos': 100,
        'quantidadeAssinaturasAtivas': 2,
        'gastosPorCategoria': {
          'JOGOS': 100,
        },
      };

      final model = ResumoFinanceiroModel.fromJson(jsonComInteiros);

      expect(model.totalValoresAtivos, equals(100.0));
      expect(model.quantidadeAssinaturasAtivas, equals(2));
      expect(model.gastosPorCategoria['JOGOS'], equals(100.0));
    });

    test('3. Trata JSON vazio ou nulo sem lançar exceções', () {
      final model = ResumoFinanceiroModel.fromJson({});

      expect(model.totalValoresAtivos, equals(0.0));
      expect(model.quantidadeAssinaturasAtivas, equals(0));
      expect(model.gastosPorCategoria, isEmpty);
    });
  });

  group('Testes Unitários de Integração com a API Resumo Financeiro', () {
    final headersUtf8 = {'content-type': 'application/json; charset=utf-8'};

    test('4. Consulta GET /assinaturas/resumo-financeiro com JWT e atualiza o estado', () async {
      await usuarioRepository.salvarToken('jwt_token_resumo_teste');

      final client = MockClient((request) async {
        expect(request.url.path, endsWith('/assinaturas/resumo-financeiro'));
        expect(request.headers['Authorization'], equals('Bearer jwt_token_resumo_teste'));

        return http.Response(
          jsonEncode({
            'totalValoresAtivos': 79.90,
            'quantidadeAssinaturasAtivas': 2,
            'gastosPorCategoria': {
              'ENTRETENIMENTO': 49.90,
              'MUSICA': 30.00,
            },
          }),
          200,
          headers: headersUtf8,
        );
      });

      final resumo = await assinaturaRepository.carregarResumoFinanceiro(client: client);

      expect(resumo, isNotNull);
      expect(resumo!.totalValoresAtivos, equals(79.90));
      expect(resumo.quantidadeAssinaturasAtivas, equals(2));
      expect(resumo.gastosPorCategoria['ENTRETENIMENTO'], equals(49.90));
      expect(assinaturaRepository.resumoFinanceiro, equals(resumo));
      expect(assinaturaRepository.erroResumo, isNull);
    });

    test('5. Retorna erro ao receber HTTP 500 no resumo financeiro', () async {
      await usuarioRepository.salvarToken('jwt_token_resumo_erro');

      final client = MockClient((request) async {
        return http.Response('Erro interno', 500, headers: headersUtf8);
      });

      final resumo = await assinaturaRepository.carregarResumoFinanceiro(client: client);

      expect(resumo, isNull);
      expect(assinaturaRepository.erroResumo, contains('Erro (500)'));
    });
  });
}
