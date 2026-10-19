
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/assinatura_model.dart';
import 'usuario_repository.dart';

class AssinaturasRepository extends ChangeNotifier {
  AssinaturasRepository._();

  static final AssinaturasRepository instance =
  AssinaturasRepository._();

  // Celular e computador devem estar na mesma rede Wi-Fi.
  // Emulador Android: http://10.0.2.2:8080/assinaturas
  // Simulador iOS: http://localhost:8080/assinaturas
  final String _baseUrl =
      'http://192.168.2.111:8080/assinaturas';

  final List<AssinaturaModel> _assinaturas = [];
  bool _carregando = false;

  List<AssinaturaModel> get assinaturas =>
      List.unmodifiable(_assinaturas);

  bool get carregando => _carregando;

  double get totalGastoMensal {
    return _assinaturas.fold(
      0.0,
          (total, item) => total + item.valor,
    );
  }

  // Busca somente as assinaturas do usuário logado.
  Future<void> carregarAssinaturas() async {
    _carregando = true;
    notifyListeners();

    try {
      final usuarioId = UsuarioRepository.instance.value.id;

      if (usuarioId.isEmpty) {
        debugPrint(
          'ERRO: nenhum usuário está logado.',
        );

        _assinaturas.clear();
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl?usuarioId=$usuarioId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> listaJson =
        jsonDecode(utf8.decode(response.bodyBytes));

        _assinaturas.clear();

        for (final item in listaJson) {
          _assinaturas.add(
            AssinaturaModel.fromJson(item),
          );
        }
      } else {
        debugPrint(
          'Erro ao carregar assinaturas: '
              '${response.statusCode}',
        );
        debugPrint('Resposta: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao carregar: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  // Cadastra uma assinatura vinculada ao usuário logado.
  Future<void> adicionarAssinatura(
      AssinaturaModel assinatura,
      ) async {
    try {
      final usuarioId = UsuarioRepository.instance.value.id;

      if (usuarioId.isEmpty) {
        debugPrint(
          'ERRO: nenhum usuário está logado.',
        );
        return;
      }

      final dados = assinatura.toJson();
      dados.remove('id');

      final response = await http.post(
        Uri.parse('$_baseUrl?usuarioId=$usuarioId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(dados),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        debugPrint('CADASTRO OK');
        debugPrint('Resposta do servidor: ${response.body}');

        await carregarAssinaturas();
      } else {
        debugPrint('ERRO AO SALVAR');
        debugPrint('Status: ${response.statusCode}');
        debugPrint('Resposta: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao salvar: $e');
    }
  }

  // Atualiza os dados de uma assinatura.
  Future<bool> atualizarAssinatura(
      AssinaturaModel assinatura,
      ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/${assinatura.id}'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'nome': assinatura.nome,
          'valor': assinatura.valor,
          'dataVencimento':
          assinatura.dataVencimento.toIso8601String(),
          'metodoPagamento': assinatura.metodoPagamento,
          'plano': assinatura.plano,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('ASSINATURA ATUALIZADA COM SUCESSO');
        debugPrint('Resposta do servidor: ${response.body}');

        await carregarAssinaturas();
        return true;
      }

      debugPrint('ERRO AO ATUALIZAR ASSINATURA');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Resposta: ${response.body}');

      return false;
    } catch (e) {
      debugPrint(
        'ERRO DE CONEXÃO AO ATUALIZAR ASSINATURA: $e',
      );
      return false;
    }
  }

  // Remove uma assinatura pelo ID.
  Future<void> removerAssinatura(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204) {
        _assinaturas.removeWhere(
              (item) => item.id == id,
        );

        notifyListeners();
      } else {
        debugPrint(
          'Erro ao deletar assinatura: ${response.statusCode}',
        );
        debugPrint('Resposta: ${response.body}');
      }
    } catch (e) {
      debugPrint('Erro de conexão ao deletar: $e');
    }
  }
}
