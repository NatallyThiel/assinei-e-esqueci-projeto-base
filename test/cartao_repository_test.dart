import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:assinei_e_esqueci/app/data/models/cartao_model.dart';
import 'package:assinei_e_esqueci/app/data/repositories/cartao_repository.dart';
import 'package:assinei_e_esqueci/app/data/repositories/usuario_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage.setMockInitialValues({});

  final usuarioRepository = UsuarioRepository.instance;
  final cartaoRepository = CartaoRepository.instance;

  setUp(() async {
    await usuarioRepository.logout();
    cartaoRepository.limparCartoesLocais();
  });

  group('Testes Unitários do CartaoRepository (BUG 2)', () {
    final headersUtf8 = {'content-type': 'application/json; charset=utf-8'};

    test('1. Adicionar cartão com sucesso (HTTP 201) retorna true e atualiza lista', () async {
      await usuarioRepository.salvarToken('jwt_token_cartao_teste');

      final cartaoNovo = CartaoModel(
        id: '',
        usuarioId: '',
        nome: 'Cartão Principal',
        bandeira: 'Visa',
        ultimosDigitos: '1234',
      );

      final client = MockClient((request) async {
        if (request.method == 'POST') {
          return http.Response(
            jsonEncode({
              'id': 99,
              'usuarioId': 123,
              'nome': 'Cartão Principal',
              'bandeira': 'Visa',
              'ultimosDigitos': '1234',
            }),
            201,
            headers: headersUtf8,
          );
        } else if (request.method == 'GET') {
          return http.Response(
            jsonEncode([
              {
                'id': 99,
                'usuarioId': 123,
                'nome': 'Cartão Principal',
                'bandeira': 'Visa',
                'ultimosDigitos': '1234',
              }
            ]),
            200,
            headers: headersUtf8,
          );
        }
        return http.Response('Not Found', 404);
      });

      final resultado = await cartaoRepository.adicionarCartao(cartaoNovo, client: client);

      expect(resultado, isTrue);
      expect(cartaoRepository.cartoes.length, equals(1));
      expect(cartaoRepository.cartoes.first.id, equals('99'));
    });

    test('2. Adicionar cartão com falha (HTTP 400) remove item temporário e retorna false', () async {
      await usuarioRepository.salvarToken('jwt_token_cartao_erro');

      final cartaoNovo = CartaoModel(
        id: '',
        usuarioId: '',
        nome: 'Cartão Inválido',
        bandeira: 'Mastercard',
        ultimosDigitos: '5678',
      );

      final client = MockClient((request) async {
        return http.Response('{"erro": "Dados inválidos"}', 400, headers: headersUtf8);
      });

      final resultado = await cartaoRepository.adicionarCartao(cartaoNovo, client: client);

      expect(resultado, isFalse);
      expect(cartaoRepository.cartoes, isEmpty);
    });

    test('3. Adicionar cartão com falha de conexão remove item temporário e retorna false', () async {
      await usuarioRepository.salvarToken('jwt_token_cartao_conexao');

      final cartaoNovo = CartaoModel(
        id: '',
        usuarioId: '',
        nome: 'Cartão Sem Conexão',
        bandeira: 'Elo',
        ultimosDigitos: '9999',
      );

      final client = MockClient((request) async {
        throw Exception('Erro de conexão com o servidor');
      });

      final resultado = await cartaoRepository.adicionarCartao(cartaoNovo, client: client);

      expect(resultado, isFalse);
      expect(cartaoRepository.cartoes, isEmpty);
    });
  });
}
