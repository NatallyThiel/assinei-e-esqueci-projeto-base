import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/assinatura_model.dart';

class AssinaturasRepository extends ChangeNotifier {
  AssinaturasRepository._();
  static final AssinaturasRepository instance = AssinaturasRepository._();

  //  testar no emulador Android, use 'http://10.0.2.2:8080/assinaturas'
  // iOS simulator usar 'http://localhost:8080/assinaturas'
  final String _baseUrl = 'http://10.0.2.2:8080/assinaturas';

  final List<AssinaturaModel> _assinaturas = [];
  bool _carregando = false;

  List<AssinaturaModel> get assinaturas => List.unmodifiable(_assinaturas);
  bool get carregando => _carregando;

  double get totalGastoMensal {
    return _assinaturas.fold(0.0, (total, item) => total + item.valor);
  }

  // metodo para buscar todas as assinaturas do PostgreSQL via API
  Future<void> carregarAssinaturas() async {
    _carregando = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> listaJson = jsonDecode(utf8.decode(response.bodyBytes));

        _assinaturas.clear();
        for (var item in listaJson) {
          _assinaturas.add(AssinaturaModel.fromJson(item));
        }
      } else {
        debugPrint('Erro ao carregar assinaturas: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro de conexão: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // metodo para criar uma nova assinatura enviando para a API (PostgreSQL)
  Future<void> adicionarAssinatura(AssinaturaModel assinatura) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(assinatura.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ta recarregando a lista do servidor para garantir que o ID gerado pelo banco venha certinho
        await carregarAssinaturas();
      } else {
        debugPrint('Erro ao salvar assinatura: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao salvar: $e');
    }
  }

  // metodo para remover uma assinatura pelo ID na API
  Future<void> removerAssinatura(String id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        _assinaturas.removeWhere((item) => item.id == id);
        notifyListeners();
      } else {
        debugPrint('Erro ao deletar assinatura: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao deletar: $e');
    }
  }
}