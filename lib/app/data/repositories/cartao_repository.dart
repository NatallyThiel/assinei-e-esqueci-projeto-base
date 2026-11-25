import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/cartao_model.dart';
import 'usuario_repository.dart';

class CartaoRepository extends ChangeNotifier {
  CartaoRepository._();
  static final CartaoRepository instance = CartaoRepository._();

  final String _baseUrl =
      'https://assinei-e-esqueci-backend-production.up.railway.app/cartoes';

  final List<CartaoModel> _cartoes = [];
  bool _carregando = false;

  List<CartaoModel> get cartoes => List.unmodifiable(_cartoes);
  bool get carregando => _carregando;

  CartaoModel? obterCartaoPorId(String? id) {
    if (id == null || id.isEmpty) return null;
    try {
      return _cartoes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>> _obterHeaders() async {
    return await UsuarioRepository.instance.obterHeaders();
  }

  Future<void> carregarCartoes() async {
    _carregando = true;
    notifyListeners();
    try {
      final token = await UsuarioRepository.instance.obterToken();
      if (token == null || token.trim().isEmpty) {
        _cartoes.clear();
        return;
      }

      final headers = await _obterHeaders();
      final usuarioId = UsuarioRepository.instance.value.id;

      final url = usuarioId.isNotEmpty
          ? '$_baseUrl?usuarioId=$usuarioId'
          : _baseUrl;

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final listaJson = jsonDecode(utf8.decode(response.bodyBytes))
            as List<dynamic>;
        _cartoes
          ..clear()
          ..addAll(listaJson.map((item) =>
              CartaoModel.fromJson(item as Map<String, dynamic>)));
      } else {
        UsuarioRepository.instance.tratarErroHttp(response.statusCode);
        debugPrint('Erro ao carregar cartões: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao carregar cartões: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> adicionarCartao(CartaoModel cartao) async {
    try {
      final headers = await _obterHeaders();
      final usuarioId = UsuarioRepository.instance.value.id;

      final cartaoComUsuario = cartao.copyWith(usuarioId: usuarioId);
      final dados = cartaoComUsuario.toJson()..remove('id');

      // Adição otimista local
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final cartaoComIdTemp = cartaoComUsuario.copyWith(id: tempId);
      _cartoes.add(cartaoComIdTemp);
      notifyListeners();

      final url = usuarioId.isNotEmpty
          ? '$_baseUrl?usuarioId=$usuarioId'
          : _baseUrl;

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(dados),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await carregarCartoes();
        return true;
      }

      UsuarioRepository.instance.tratarErroHttp(response.statusCode);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao cadastrar cartão: $e');
      notifyListeners();
      return true;
    }
  }

  Future<bool> atualizarCartao(CartaoModel cartao) async {
    try {
      final headers = await _obterHeaders();
      final index = _cartoes.indexWhere((c) => c.id == cartao.id);
      if (index != -1) {
        _cartoes[index] = cartao;
        notifyListeners();
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/${cartao.id}'),
        headers: headers,
        body: jsonEncode(cartao.toJson()),
      );

      if (response.statusCode == 200) {
        await carregarCartoes();
      } else {
        UsuarioRepository.instance.tratarErroHttp(response.statusCode);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar cartão: $e');
      notifyListeners();
      return true;
    }
  }

  Future<bool> removerCartao(String cartaoId) async {
    try {
      final headers = await _obterHeaders();
      _cartoes.removeWhere((c) => c.id == cartaoId);
      notifyListeners();

      final response = await http.delete(
        Uri.parse('$_baseUrl/$cartaoId'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      UsuarioRepository.instance.tratarErroHttp(response.statusCode);
      return true;
    } catch (e) {
      debugPrint('Erro ao remover cartão: $e');
      return true;
    }
  }
}
