import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

enum ResultadoRestauraSessao {
  sucesso,
  naoAutorizado,
  acessoProibido,
  servidorIndisponivel,
}

class UsuarioModel {
  String id;
  String nome;
  String email;
  String cpf;
  String telefone;

  UsuarioModel({
    this.id = '',
    this.nome = '',
    this.email = '',
    this.cpf = '',
    this.telefone = '',
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      cpf: json['cpf']?.toString() ?? '',
      telefone: json['telefone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'telefone': telefone,
      };

  UsuarioModel copyWith({
    String? id,
    String? nome,
    String? email,
    String? cpf,
    String? telefone,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      telefone: telefone ?? this.telefone,
    );
  }
}

class UsuarioRepository extends ValueNotifier<UsuarioModel> {
  UsuarioRepository._() : super(UsuarioModel());

  static final UsuarioRepository instance = UsuarioRepository._();

  final String _baseUrl =
      'https://assinei-e-esqueci-backend-production.up.railway.app';

  static const Duration _timeout = Duration(seconds: 15);
  FlutterSecureStorage storage = const FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  final ValueNotifier<bool> sessaoExpiradaNotifier =
      ValueNotifier<bool>(false);

  /// Valida se o ID retornado pelo backend representa
  /// exclusivamente um inteiro positivo (> 0).
  static bool eIdInteiroPositivoValido(dynamic rawId) {
    if (rawId == null) return false;
    final str = rawId.toString().trim();
    final parsedInt = int.tryParse(str);
    if (parsedInt == null) return false;
    return parsedInt > 0;
  }

  Future<String?> obterToken() async {
    try {
      return await storage.read(key: _tokenKey);
    } catch (e) {
      debugPrint('ERRO AO RECUPERAR TOKEN: $e');
      return null;
    }
  }

  Future<void> salvarToken(String token) async {
    await storage.write(key: _tokenKey, value: token);
  }

  Future<Map<String, String>> obterHeaders() async {
    final token = await obterToken();
    if (token == null || token.trim().isEmpty) {
      throw Exception('Token JWT não encontrado. Faça login novamente.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
  }

  /// Trata erros HTTP exclusivamente para requisições autenticadas (400, 401, 403, 409, 500).
  void tratarErroHttp(int statusCode) {
    if (statusCode == 401) {
      debugPrint('HTTP 401 em rota autenticada: Sessão expirada. Executando logout.');
      logout();
      sessaoExpiradaNotifier.value = true;
    } else if (statusCode == 400) {
      debugPrint('HTTP 400: Requisição inválida / Dados incorretos.');
    } else if (statusCode == 403) {
      debugPrint('HTTP 403: Acesso não autorizado.');
    } else if (statusCode == 409) {
      debugPrint('HTTP 409: Conflito de dados / Recurso duplicado.');
    } else if (statusCode >= 500) {
      debugPrint('HTTP $statusCode: Erro interno do servidor.');
    }
  }

  Future<void> logout() async {
    try {
      await storage.delete(key: _tokenKey);
      value = UsuarioModel();
      debugPrint('SESSÃO ENCERRADA COM SUCESSO');
    } catch (e) {
      debugPrint('ERRO AO ENCERRAR SESSÃO: $e');
    }
  }

  /// Restaura e valida a sessão usando GET /usuarios.
  /// Suporta cliente HTTP opcional para testes unitários com fechamento adequado.
  Future<ResultadoRestauraSessao> verificarERestaurarSessao({
    http.Client? client,
  }) async {
    final createdClient = client == null;
    final httpClient = client ?? http.Client();

    try {
      final token = await obterToken();
      if (token == null || token.trim().isEmpty) {
        debugPrint('RESTAURAÇÃO DE SESSÃO: Nenhum token JWT encontrado.');
        return ResultadoRestauraSessao.naoAutorizado;
      }

      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };

      final response = await httpClient
          .get(Uri.parse('$_baseUrl/usuarios'), headers: headers)
          .timeout(_timeout);

      debugPrint('RESPOSTA DE RESTAURAÇÃO DE SESSÃO (/usuarios): ${response.statusCode}');

      if (response.statusCode == 200) {
        dynamic bodyDecodificado;
        try {
          bodyDecodificado = jsonDecode(response.body);
        } catch (_) {
          bodyDecodificado = jsonDecode(utf8.decode(response.bodyBytes));
        }

        List<dynamic> listaUsuarios = [];
        if (bodyDecodificado is List) {
          listaUsuarios = bodyDecodificado;
        } else if (bodyDecodificado is Map<String, dynamic>) {
          listaUsuarios = [bodyDecodificado];
        }

        if (listaUsuarios.isNotEmpty) {
          final dadosUsuario = listaUsuarios.first as Map<String, dynamic>;
          final idRaw = dadosUsuario['id'];
          final nomeStr = dadosUsuario['nome']?.toString() ?? '';

          if (!eIdInteiroPositivoValido(idRaw)) {
            debugPrint('RESTAURAÇÃO DE SESSÃO: ID inválido ($idRaw). Limpando token.');
            await logout();
            return ResultadoRestauraSessao.naoAutorizado;
          }

          final idStr = int.parse(idRaw.toString().trim()).toString();

          // Preenche todos os 5 campos retornados pela API (id, nome, email, cpf, telefone)
          value = UsuarioModel(
            id: idStr,
            nome: nomeStr,
            email: dadosUsuario['email']?.toString() ?? value.email,
            cpf: dadosUsuario['cpf']?.toString() ?? value.cpf,
            telefone: dadosUsuario['telefone']?.toString() ?? value.telefone,
          );

          sessaoExpiradaNotifier.value = false;
          debugPrint('SESSÃO RESTAURADA COM SUCESSO: id=$idStr, nome=$nomeStr, email=${value.email}');
          return ResultadoRestauraSessao.sucesso;
        } else {
          debugPrint('RESTAURAÇÃO DE SESSÃO: Lista de usuários vazia. Limpando token.');
          await logout();
          return ResultadoRestauraSessao.naoAutorizado;
        }
      } else if (response.statusCode == 401) {
        debugPrint('HTTP 401 na restauração de sessão. Token expirado. Limpando token.');
        await logout();
        return ResultadoRestauraSessao.naoAutorizado;
      } else if (response.statusCode == 403) {
        debugPrint('HTTP 403 na restauração de sessão. Token preservado.');
        return ResultadoRestauraSessao.acessoProibido;
      } else {
        tratarErroHttp(response.statusCode);
        return ResultadoRestauraSessao.servidorIndisponivel;
      }
    } catch (e) {
      debugPrint('FALHA DE CONEXÃO/TIMEOUT AO VERIFICAR SESSÃO (Token preservado): $e');
      return ResultadoRestauraSessao.servidorIndisponivel;
    } finally {
      if (createdClient) {
        httpClient.close();
      }
    }
  }

  Future<bool> cadastrarUsuario({
    required String nome,
    required String email,
    required String cpf,
    required String telefone,
    required String senha,
    http.Client? client,
  }) async {
    final createdClient = client == null;
    final httpClient = client ?? http.Client();

    try {
      debugPrint('INICIANDO CADASTRO DE USUÁRIO');

      final response = await httpClient
          .post(
            Uri.parse('$_baseUrl/usuarios'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'nome': nome,
              'email': email,
              'cpf': cpf,
              'telefone': telefone,
              'senha': senha,
            }),
          )
          .timeout(_timeout);

      debugPrint('RESPOSTA DO CADASTRO: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('USUÁRIO CADASTRADO COM SUCESSO');
        return true;
      }

      tratarErroHttp(response.statusCode);
      debugPrint('ERRO AO CADASTRAR (${response.statusCode}): ${response.body}');
      return false;
    } catch (e) {
      debugPrint('ERRO AO CADASTRAR USUÁRIO: $e');
      return false;
    } finally {
      if (createdClient) {
        httpClient.close();
      }
    }
  }

  Future<bool> login({
    required String email,
    required String senha,
    http.Client? client,
  }) async {
    final createdClient = client == null;
    final httpClient = client ?? http.Client();

    try {
      final url = Uri.parse('$_baseUrl/usuarios/login');
      debugPrint('INICIANDO LOGIN');

      final response = await httpClient
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'email': email,
              'senha': senha,
            }),
          )
          .timeout(_timeout);

      debugPrint('RESPOSTA DO LOGIN: ${response.statusCode}');

      if (response.statusCode == 200) {
        dynamic dadosRaw;
        try {
          dadosRaw = jsonDecode(response.body);
        } catch (_) {
          dadosRaw = jsonDecode(utf8.decode(response.bodyBytes));
        }
        final dadosUsuario = dadosRaw as Map<String, dynamic>;

        final idRaw = dadosUsuario['id'];
        final token = dadosUsuario['token']?.toString();

        if (!eIdInteiroPositivoValido(idRaw)) {
          debugPrint('LOGIN REJEITADO: Servidor retornou ID inválido ($idRaw).');
          return false;
        }

        if (token == null || token.trim().isEmpty) {
          debugPrint('ERRO: BACKEND NÃO RETORNOU UM TOKEN JWT');
          return false;
        }

        await salvarToken(token);

        // Preenche com os 5 campos retornados na resposta do UsuarioResponse no login
        value = UsuarioModel(
          id: int.parse(idRaw.toString().trim()).toString(),
          nome: dadosUsuario['nome']?.toString() ?? '',
          email: dadosUsuario['email']?.toString() ?? email,
          cpf: dadosUsuario['cpf']?.toString() ?? '',
          telefone: dadosUsuario['telefone']?.toString() ?? '',
        );

        sessaoExpiradaNotifier.value = false;
        debugPrint('LOGIN REALIZADO COM SUCESSO: ID=${value.id}, NOME=${value.nome}');
        return true;
      }

      debugPrint('FALHA DE AUTENTICAÇÃO NO LOGIN (${response.statusCode}): ${response.body}');
      return false;
    } catch (e) {
      debugPrint('ERRO DE CONEXÃO AO FAZER LOGIN: $e');
      return false;
    } finally {
      if (createdClient) {
        httpClient.close();
      }
    }
  }

  Future<bool> salvarPerfil({
    required String nome,
    required String email,
    required String cpf,
    required String telefone,
    http.Client? client,
  }) async {
    final createdClient = client == null;
    final httpClient = client ?? http.Client();

    try {
      if (value.id.isEmpty) {
        debugPrint('ERRO: Usuário não possui ID para atualização.');
        return false;
      }

      if (nome.trim().isEmpty ||
          email.trim().isEmpty ||
          cpf.trim().isEmpty ||
          telefone.trim().isEmpty) {
        debugPrint('ERRO DE VALIDAÇÃO: Todos os campos são obrigatórios.');
        return false;
      }

      final headers = await obterHeaders();
      final url = Uri.parse('$_baseUrl/usuarios/${value.id}');

      final response = await httpClient
          .put(
            url,
            headers: headers,
            body: jsonEncode({
              'nome': nome.trim(),
              'email': email.trim(),
              'cpf': cpf.trim(),
              'telefone': telefone.trim(),
            }),
          )
          .timeout(_timeout);

      debugPrint('RESPOSTA DA ATUALIZAÇÃO: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> dadosResposta = {};
        try {
          dadosResposta = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          dadosResposta = jsonDecode(utf8.decode(response.bodyBytes))
              as Map<String, dynamic>;
        }

        value = UsuarioModel(
          id: dadosResposta['id']?.toString() ?? value.id,
          nome: dadosResposta['nome']?.toString() ?? nome.trim(),
          email: dadosResposta['email']?.toString() ?? email.trim(),
          cpf: dadosResposta['cpf']?.toString() ?? cpf.trim(),
          telefone: dadosResposta['telefone']?.toString() ?? telefone.trim(),
        );

        debugPrint('PERFIL ATUALIZADO COM SUCESSO');
        return true;
      }

      tratarErroHttp(response.statusCode);
      debugPrint('ERRO AO ATUALIZAR PERFIL: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('ERRO AO ATUALIZAR PERFIL: $e');
      return false;
    } finally {
      if (createdClient) {
        httpClient.close();
      }
    }
  }

  void atualizarPerfil({
    required String nome,
    required String email,
    String? cpf,
    String? telefone,
  }) {
    value = UsuarioModel(
      id: value.id,
      nome: nome.trim(),
      email: email.trim(),
      cpf: (cpf != null && cpf.trim().isNotEmpty) ? cpf.trim() : value.cpf,
      telefone:
          (telefone != null && telefone.trim().isNotEmpty) ? telefone.trim() : value.telefone,
    );
  }
}
