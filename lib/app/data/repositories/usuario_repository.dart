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

final String _baseUrl = 'http://10.0.2.2:8080';
static const Duration _timeout = Duration(seconds: 15);

Future<bool> cadastrarUsuario({
required String nome,
required String email,
required String cpf,
required String telefone,
required String senha,
}) async {
try {
debugPrint('INICIANDO CADASTRO DE USUÁRIO');
debugPrint('URL: $_baseUrl/usuarios');

final response = await http
    .post(
Uri.parse('$_baseUrl/usuarios'),
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
)
    .timeout(_timeout);

debugPrint('RESPOSTA DO CADASTRO: ${response.statusCode}');
debugPrint('CORPO DA RESPOSTA: ${response.body}');

if (response.statusCode == 200 || response.statusCode == 201) {
final dadosUsuario =
jsonDecode(response.body) as Map<String, dynamic>;

value = UsuarioModel(
id: dadosUsuario['id']?.toString() ?? '',
nome: dadosUsuario['nome'] ?? '',
email: dadosUsuario['email'] ?? '',
cpf: dadosUsuario['cpf'] ?? '',
telefone: dadosUsuario['telefone'] ?? '',
);

notifyListeners();

debugPrint('USUÁRIO CADASTRADO COM SUCESSO');
return true;
}

debugPrint('ERRO AO CADASTRAR USUÁRIO');
return false;
} catch (e) {
debugPrint('ERRO AO CADASTRAR USUÁRIO: $e');
return false;
}
}

Future<bool> login({
required String email,
required String senha,
}) async {
try {
final url = Uri.parse('$_baseUrl/usuarios/login');

debugPrint('INICIANDO LOGIN');
debugPrint('URL: $url');
debugPrint('Enviando requisição para o backend...');

final response = await http
    .post(
url,
headers: {
'Content-Type': 'application/json; charset=UTF-8',
},
body: jsonEncode({
'email': email,
'senha': senha,
}),
)
    .timeout(_timeout);

debugPrint('RESPOSTA DO LOGIN: ${response.statusCode}');
debugPrint('CORPO DA RESPOSTA: ${response.body}');

if (response.statusCode == 200) {
final dadosUsuario =
jsonDecode(response.body) as Map<String, dynamic>;

value = UsuarioModel(
id: dadosUsuario['id']?.toString() ?? '',
nome: dadosUsuario['nome'] ?? '',
email: dadosUsuario['email'] ?? '',
cpf: dadosUsuario['cpf'] ?? '',
telefone: dadosUsuario['telefone'] ?? '',
);

notifyListeners();

debugPrint('LOGIN REALIZADO COM SUCESSO');
debugPrint('Usuário: ${value.nome}');
debugPrint('ID do usuário: ${value.id}');

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

final url = Uri.parse('$_baseUrl/usuarios/${value.id}');

debugPrint('INICIANDO ATUALIZAÇÃO DO PERFIL');
debugPrint('URL: $url');

final response = await http
    .put(
url,
headers: {
'Content-Type': 'application/json; charset=UTF-8',
},
body: jsonEncode({
'nome': nome,
'email': email,
'cpf': cpf,
'telefone': telefone,
}),
)
    .timeout(_timeout);

debugPrint('RESPOSTA DA ATUALIZAÇÃO: ${response.statusCode}');
debugPrint('CORPO DA RESPOSTA: ${response.body}');

if (response.statusCode == 200) {
final dadosUsuario =
jsonDecode(response.body) as Map<String, dynamic>;

value = UsuarioModel(
id: dadosUsuario['id']?.toString() ?? '',
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
debugPrint('ERRO AO ATUALIZAR PERFIL: $e');
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