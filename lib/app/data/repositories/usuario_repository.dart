import 'package:flutter/material.dart';

class UsuarioModel {
  String nome;
  String email;
  String cpf;
  String telefone;

  UsuarioModel({
    this.nome = '',
    this.email = '',
    this.cpf = '',
    this.telefone = '',
  });
}

class UsuarioRepository extends ValueNotifier<UsuarioModel> {
  UsuarioRepository._() : super(UsuarioModel());

  static final UsuarioRepository instance = UsuarioRepository._();

  void atualizarPerfil({
    required String nome,
    required String email,
    String cpf = '',
    String telefone = '',
  }) {
    value = UsuarioModel(
      nome: nome,
      email: email,
      cpf: cpf,
      telefone: telefone,
    );
    notifyListeners();
  }
}