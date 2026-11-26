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

  void limparCartoesLocais() {
    _cartoes.clear();
    notifyListeners();
  }

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

  Future<void> carregarCartoes({http.Client? client}) async {
    _carregando = true;
    notifyListeners();

    final createdClient = client == null;
    final httpClient = client ?? http.Client();

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

      final response = await httpClient.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        dynamic bodyDecodificado;
        try {
          bodyDecodificado = jsonDecode(response.body);
        } catch (_) {
          bodyDecodificado = jsonDecode(utf8.decode(response.bodyBytes));
        }

        final listaJson = bodyDecodificado as List<dynamic>;
        _cartoes
          ..clear()
          ..addAll(listaJson.map((item) =>
              CartaoModel.fromJson(item as Map<String, dynamic>)));
      } else {
        UsuarioRepository.instance.tratarErroHttp(response.statusCode);
        debugPrint('Erro ao carregar cartões (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao carregar cartões: $e');
    } finally {
      _carregando = false;
      notifyListeners();
      if (createdClient) {
        httpClient.close();
      }
    }
  }

  Future<bool> adicionarCartao(CartaoModel cartao, {http.Client? client}) async {
    final createdClient = client == null;
    final httpClient = client ?? http.Client();
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    CartaoModel? cartaoTemp;

    try {
      final headers = await _obterHeaders();
      final usuarioId = UsuarioRepository.instance.value.id;

      final cartaoComUsuario = cartao.copyWith(usuarioId: usuarioId);
      final dados = cartaoComUsuario.toJson()..remove('id');

      // Adição temporária local
      cartaoTemp = cartaoComUsuario.copyWith(id: tempId);
      _cartoes.add(cartaoTemp);
      notifyListeners();

      final url = usuarioId.isNotEmpty
          ? '$_baseUrl?usuarioId=$usuarioId'
          : _baseUrl;

      final response = await httpClient.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(dados),
      );

      debugPrint('RESPOSTA ADICIONAR CARTÃO: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await carregarCartoes(client: httpClient);
        return true;
      }

      // Em caso de falha HTTP, remove o cartão temporário
      _cartoes.removeWhere((c) => c.id == tempId);
      UsuarioRepository.instance.tratarErroHttp(response.statusCode);
      debugPrint('Erro HTTP ao cadastrar cartão (${response.statusCode}): ${response.body}');
      notifyListeners();
      return false;
    } catch (e) {
      if (cartaoTemp != null) {
        _cartoes.removeWhere((c) => c.id == tempId);
      }
      debugPrint('Erro de conexão ao cadastrar cartão: $e');
      notifyListeners();
      return false;
    } finally {
      if (createdClient) {
        httpClient.close();
      }
    }
  }

  Future<bool> atualizarCartao(CartaoModel cartao, {http.Client? client}) async {
    final createdClient = client == null;
    final httpClient = client ?? http.Client();

    try {
      final headers = await _obterHeaders();
      final index = _cartoes.indexWhere((c) => c.id == cartao.id);
      if (index != -1) {
        _cartoes[index] = cartao;
        notifyListeners();
      }

      final response = await httpClient.put(
        Uri.parse('$_baseUrl/${cartao.id}'),
        headers: headers,
        body: jsonEncode(cartao.toJson()),
      );

      if (response.statusCode == 200) {
        await carregarCartoes(client: httpClient);
        return true;
      } else {
        UsuarioRepository.instance.tratarErroHttp(response.statusCode);
        debugPrint('Erro ao atualizar cartão (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao atualizar cartão: $e');
      return false;
    } finally {
      notifyListeners();
      if (createdClient) {
        httpClient.close();
      }
    }
  }

  Future<bool> removerCartao(String cartaoId, {http.Client? client}) async {
    final createdClient = client == null;
    final httpClient = client ?? http.Client();

    try {
      final headers = await _obterHeaders();

      final response = await httpClient.delete(
        Uri.parse('$_baseUrl/$cartaoId'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _cartoes.removeWhere((c) => c.id == cartaoId);
        notifyListeners();
        return true;
      }

      UsuarioRepository.instance.tratarErroHttp(response.statusCode);
      debugPrint('Erro ao remover cartão (${response.statusCode}): ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Erro ao remover cartão: $e');
      return false;
    } finally {
      if (createdClient) {
        httpClient.close();
      }
    }
  }
}
