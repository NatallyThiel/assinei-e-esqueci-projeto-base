import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:assinei_e_esqueci/app/data/repositories/usuario_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Desativa storage real nos testes unitários usando FlutterSecureStorage.setMockInitialValues
  FlutterSecureStorage.setMockInitialValues({});

  final repository = UsuarioRepository.instance;

  setUp(() async {
    await repository.logout();
    repository.sessaoExpiradaNotifier.value = false;
  });

  group('Testes Unitários de Autenticação do UsuarioRepository', () {
    final headersUtf8 = {'content-type': 'application/json; charset=utf-8'};

    // 1. Login com HTTP 200 e armazenamento do JWT
    test('1. Login com HTTP 200 e ID válido salva o JWT', () async {
      final client = MockClient((request) async {
        expect(request.url.path, endsWith('/usuarios/login'));
        return http.Response(
          jsonEncode({
            'id': 123,
            'nome': 'Usuário Teste',
            'token': 'jwt_token_valido_123',
          }),
          200,
          headers: headersUtf8,
        );
      });

      final sucesso = await repository.login(
        email: 'usuario@email.com',
        senha: 'senha123',
        client: client,
      );

      expect(sucesso, isTrue);
      expect(repository.value.id, equals('123'));
      expect(repository.value.nome, equals('Usuário Teste'));
      expect(repository.value.email, equals('usuario@email.com'));

      final tokenSalvo = await repository.obterToken();
      expect(tokenSalvo, equals('jwt_token_valido_123'));
    });

    // 2. Login com HTTP 200 e ID inválido (não salva novo token e preserva sessão anterior)
    test('2. Login com HTTP 200 e ID inválido não salva token e preserva sessão anterior', () async {
      // Simula uma sessão anterior ativa
      await repository.salvarToken('token_sessao_anterior');
      repository.atualizarPerfil(
        nome: 'Usuário Existente',
        email: 'existente@email.com',
        cpf: '11122233344',
        telefone: '11999999999',
      );

      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'id': 'invalido_abc',
            'nome': 'Tentativa Inválida',
            'token': 'jwt_token_novo_invalido',
          }),
          200,
          headers: headersUtf8,
        );
      });

      final sucesso = await repository.login(
        email: 'tentativa@email.com',
        senha: 'senha123',
        client: client,
      );

      expect(sucesso, isFalse);
      // Garante que o token da sessão anterior foi preservado e não foi substituído nem apagado
      final tokenSalvo = await repository.obterToken();
      expect(tokenSalvo, equals('token_sessao_anterior'));
      expect(repository.value.nome, equals('Usuário Existente'));
      expect(repository.sessaoExpiradaNotifier.value, isFalse);
    });

    // 3. Login com HTTP 401 sem disparar logout global
    test('3. Login com HTTP 401 sem disparar logout global', () async {
      final client = MockClient((request) async {
        return http.Response('{"erro": "Credenciais inválidas"}', 401, headers: headersUtf8);
      });

      final sucesso = await repository.login(
        email: 'errado@email.com',
        senha: 'senhaIncorreta',
        client: client,
      );

      expect(sucesso, isFalse);
      expect(repository.sessaoExpiradaNotifier.value, isFalse);
    });

    // 4. Restauração com HTTP 200 e usuário válido
    test('4. Restauração com HTTP 200 e usuário válido', () async {
      await repository.salvarToken('token_valido_xyz');

      final client = MockClient((request) async {
        expect(request.headers['Authorization'], equals('Bearer token_valido_xyz'));
        return http.Response(
          jsonEncode([
            {'id': 456, 'nome': 'Usuário Validado'}
          ]),
          200,
          headers: headersUtf8,
        );
      });

      final resultado = await repository.verificarERestaurarSessao(client: client);

      expect(resultado, equals(ResultadoRestauraSessao.sucesso));
      expect(repository.value.id, equals('456'));
      expect(repository.value.nome, equals('Usuário Validado'));
      final token = await repository.obterToken();
      expect(token, equals('token_valido_xyz'));
    });

    // 5. Restauração sem token armazenado
    test('5. Restauração sem token armazenado', () async {
      final resultado = await repository.verificarERestaurarSessao();
      expect(resultado, equals(ResultadoRestauraSessao.naoAutorizado));
      expect(repository.value.id, equals(''));
    });

    // 6. Restauração com lista vazia e limpeza do token
    test('6. Restauração com lista vazia e limpeza do token', () async {
      await repository.salvarToken('token_invalido_lista_vazia');

      final client = MockClient((request) async {
        return http.Response(jsonEncode([]), 200, headers: headersUtf8);
      });

      final resultado = await repository.verificarERestaurarSessao(client: client);

      expect(resultado, equals(ResultadoRestauraSessao.naoAutorizado));
      expect(repository.value.id, equals(''));
      final token = await repository.obterToken();
      expect(token, isNull);
    });

    // 7. Restauração com HTTP 401 e limpeza da sessão
    test('7. Restauração com HTTP 401 e limpeza da sessão', () async {
      await repository.salvarToken('token_expirado_401');

      final client = MockClient((request) async {
        return http.Response('{"erro": "Token expirado"}', 401, headers: headersUtf8);
      });

      final resultado = await repository.verificarERestaurarSessao(client: client);

      expect(resultado, equals(ResultadoRestauraSessao.naoAutorizado));
      expect(repository.value.id, equals(''));
      final token = await repository.obterToken();
      expect(token, isNull);
    });

    // 8. Restauração com HTTP 403 sem apagar o token (não libera sessão)
    test('8. Restauração com HTTP 403 sem apagar o token (não libera sessão)', () async {
      await repository.salvarToken('token_acesso_proibido_403');

      final client = MockClient((request) async {
        return http.Response('{"erro": "Acesso proibido"}', 403, headers: headersUtf8);
      });

      final resultado = await repository.verificarERestaurarSessao(client: client);

      expect(resultado, equals(ResultadoRestauraSessao.acessoProibido));
      expect(resultado, isNot(equals(ResultadoRestauraSessao.sucesso)));
      final token = await repository.obterToken();
      expect(token, equals('token_acesso_proibido_403'));
    });

    // 9. Restauração com HTTP 500 preservando o token, sem validar a sessão
    test('9. Restauração com HTTP 500 preservando o token, sem validar a sessão', () async {
      await repository.salvarToken('token_preservado_500');

      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500, headers: headersUtf8);
      });

      final resultado = await repository.verificarERestaurarSessao(client: client);

      expect(resultado, equals(ResultadoRestauraSessao.servidorIndisponivel));
      expect(resultado, isNot(equals(ResultadoRestauraSessao.sucesso)));
      final token = await repository.obterToken();
      expect(token, equals('token_preservado_500'));
    });

    // 10. Falha de conexão preservando o token, sem validar a sessão
    test('10. Falha de conexão preservando o token, sem validar a sessão', () async {
      await repository.salvarToken('token_preservado_conexao');

      final client = MockClient((request) async {
        throw Exception('Sem conexão com a internet');
      });

      final resultado = await repository.verificarERestaurarSessao(client: client);

      expect(resultado, equals(ResultadoRestauraSessao.servidorIndisponivel));
      expect(resultado, isNot(equals(ResultadoRestauraSessao.sucesso)));
      final token = await repository.obterToken();
      expect(token, equals('token_preservado_conexao'));
    });

    // 11. Resposta com ID decimal sendo rejeitado
    test('11. Resposta com ID decimal (123.45) sendo rejeitado', () async {
      await repository.salvarToken('token_id_decimal');

      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {'id': 123.45, 'nome': 'Usuário Teste'}
          ]),
          200,
          headers: headersUtf8,
        );
      });

      final resultado = await repository.verificarERestaurarSessao(client: client);

      expect(resultado, equals(ResultadoRestauraSessao.naoAutorizado));
      final token = await repository.obterToken();
      expect(token, isNull);
    });

    // 12. Resposta com ID zero sendo rejeitado
    test('12. Resposta com ID zero (0) sendo rejeitado', () async {
      await repository.salvarToken('token_id_zero');

      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {'id': 0, 'nome': 'Usuário Teste'}
          ]),
          200,
          headers: headersUtf8,
        );
      });

      final resultado = await repository.verificarERestaurarSessao(client: client);

      expect(resultado, equals(ResultadoRestauraSessao.naoAutorizado));
      final token = await repository.obterToken();
      expect(token, isNull);
    });

    // 13. Resposta com ID negativo sendo rejeitado
    test('13. Resposta com ID negativo (-10) sendo rejeitado', () async {
      await repository.salvarToken('token_id_negativo');

      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {'id': -10, 'nome': 'Usuário Teste'}
          ]),
          200,
          headers: headersUtf8,
        );
      });

      final resultado = await repository.verificarERestaurarSessao(client: client);

      expect(resultado, equals(ResultadoRestauraSessao.naoAutorizado));
      final token = await repository.obterToken();
      expect(token, isNull);
    });
  });
}
