import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
}

class UsuarioRepository extends ValueNotifier<UsuarioModel> {
  UsuarioRepository._() : super(UsuarioModel());

  static final UsuarioRepository instance = UsuarioRepository._();

  final String _baseUrl = 'http://192.168.2.119:8080/usuarios';

  Future<bool> cadastrarUsuario({
    required String nome,
    required String email,
    required String cpf,
    required String telefone,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'cpf': cpf,
          'telefone': telefone,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('USUÁRIO CADASTRADO COM SUCESSO');
        debugPrint('Resposta: ${response.body}');

        final dadosUsuario = jsonDecode(response.body);

        value = UsuarioModel(
          id: dadosUsuario['id'].toString(),
          nome: dadosUsuario['nome'] ?? '',
          email: dadosUsuario['email'] ?? '',
          cpf: dadosUsuario['cpf'] ?? '',
          telefone: dadosUsuario['telefone'] ?? '',
        );

        notifyListeners();

        return true;
      }

      debugPrint('ERRO AO CADASTRAR USUÁRIO');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Resposta: ${response.body}');

      return false;
    } catch (e) {
      debugPrint('ERRO DE CONEXÃO AO CADASTRAR USUÁRIO: $e');
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        final dadosUsuario = jsonDecode(response.body);

        value = UsuarioModel(
          id: dadosUsuario['id'].toString(),
          nome: dadosUsuario['nome'] ?? '',
          email: dadosUsuario['email'] ?? '',
          cpf: dadosUsuario['cpf'] ?? '',
          telefone: dadosUsuario['telefone'] ?? '',
        );

        notifyListeners();

        debugPrint('LOGIN REALIZADO COM SUCESSO');
        debugPrint('Usuário: ${dadosUsuario['nome']}');
        debugPrint('ID do usuário: ${dadosUsuario['id']}');

        return true;
      }

      debugPrint('ERRO AO FAZER LOGIN');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Resposta: ${response.body}');

      return false;
    } catch (e) {
      debugPrint('ERRO DE CONEXÃO AO FAZER LOGIN: $e');
      return false;
    }
  }

  Future<bool> salvarPerfil({
    required String nome,
    required String email,
    required String cpf,
    required String telefone,
  }) async {
    try {
      if (value.id.isEmpty) {
        debugPrint('ERRO: usuário não possui ID.');
        return false;
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/${value.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'nome': nome,
          'email': email,
          'cpf': cpf,
          'telefone': telefone,
        }),
      );

      if (response.statusCode == 200) {
        final dadosUsuario = jsonDecode(response.body);

        value = UsuarioModel(
          id: dadosUsuario['id'].toString(),
          nome: dadosUsuario['nome'] ?? '',
          email: dadosUsuario['email'] ?? '',
          cpf: dadosUsuario['cpf'] ?? '',
          telefone: dadosUsuario['telefone'] ?? '',
        );

        notifyListeners();

        debugPrint('PERFIL ATUALIZADO COM SUCESSO');

        return true;
      }

      debugPrint('ERRO AO ATUALIZAR PERFIL');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Resposta: ${response.body}');

      return false;
    } catch (e) {
      debugPrint('ERRO DE CONEXÃO AO ATUALIZAR PERFIL: $e');
      return false;
    }
  }

  void atualizarPerfil({
    required String nome,
    required String email,
    String cpf = '',
    String telefone = '',
  }) {
    value = UsuarioModel(
      id: value.id,
      nome: nome,
      email: email,
      cpf: cpf,
      telefone: telefone,
    );

    notifyListeners();
  }
}