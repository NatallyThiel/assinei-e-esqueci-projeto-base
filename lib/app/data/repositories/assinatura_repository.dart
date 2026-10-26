import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/assinatura_model.dart';
import 'usuario_repository.dart';

class AssinaturasRepository extends ChangeNotifier {
  AssinaturasRepository._();
  static final AssinaturasRepository instance = AssinaturasRepository._();

  final String _baseUrl = 'http://10.0.2.2:8080/assinaturas';

  final List<AssinaturaModel> _assinaturas = [];
  bool _carregando = false;

  List<AssinaturaModel> get assinaturas => List.unmodifiable(_assinaturas);
  bool get carregando => _carregando;

  double get totalGastoMensal =>
      _assinaturas.fold(0.0, (total, item) => total + item.valor);

  Future<void> carregarAssinaturas() async {
    _carregando = true;
    notifyListeners();
    try {
      final usuarioId = UsuarioRepository.instance.value.id;
      if (usuarioId.isEmpty) {
        _assinaturas.clear();
        return;
      }

      final response =
      await http.get(Uri.parse('$_baseUrl?usuarioId=$usuarioId'));
      if (response.statusCode == 200) {
        final listaJson = jsonDecode(utf8.decode(response.bodyBytes))
        as List<dynamic>;
        _assinaturas
          ..clear()
          ..addAll(listaJson.map((item) =>
              AssinaturaModel.fromJson(item as Map<String, dynamic>)));
      } else {
        debugPrint('Erro ao carregar assinaturas: ${response.statusCode}');
        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint('Erro de conexão ao carregar assinaturas: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> adicionarAssinatura(AssinaturaModel assinatura) async {
    try {
      final usuarioId = UsuarioRepository.instance.value.id;
      if (usuarioId.isEmpty) {
        debugPrint('ERRO: nenhum usuário está logado.');
        return;
      }

      final dados = assinatura.toJson()..remove('id');
      final response = await http.post(
        Uri.parse('$_baseUrl?usuarioId=$usuarioId'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(dados),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await carregarAssinaturas();
      } else {
        debugPrint('Erro ao cadastrar: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro ao cadastrar assinatura: $e');
    }
  }

  Future<bool> atualizarAssinatura(AssinaturaModel assinatura) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/${assinatura.id}'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'nome': assinatura.nome,
          'valor': assinatura.valor,
          'dataVencimento': assinatura.dataVencimento.toIso8601String(),
          'metodoPagamento': assinatura.metodoPagamento,
          'plano': assinatura.plano,
          'plataforma': assinatura.plataforma,
        }),
      );
      if (response.statusCode == 200) {
        await carregarAssinaturas();
        return true;
      }
      debugPrint('Erro ao atualizar: ${response.statusCode} ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Erro ao atualizar assinatura: $e');
      return false;
    }
  }

  // CANCELAMENTO SIMULADO: atualiza o status no backend/PostgreSQL.
  // Não acessa cartão nem serviço externo.
  Future<bool> cancelarAssinatura(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id/cancelar'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await carregarAssinaturas();
        return true;
      }

      debugPrint('Erro ao cancelar: ${response.statusCode} ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Erro de conexão ao cancelar assinatura: $e');
      return false;
    }
  }

  Future<void> removerAssinatura(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200 || response.statusCode == 204) {
        _assinaturas.removeWhere((item) => item.id == id);
        notifyListeners();
      } else {
        debugPrint('Erro ao excluir: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao excluir assinatura: $e');
    }
  }
}
