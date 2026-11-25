import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/assinatura_model.dart';
import '../models/resumo_financeiro_model.dart';
import '../../core/services/notificacao_service.dart';
import 'usuario_repository.dart';

class AssinaturasRepository extends ChangeNotifier {
  AssinaturasRepository._();

  static final AssinaturasRepository instance = AssinaturasRepository._();

  final String _baseUrl =
      'https://assinei-e-esqueci-backend-production.up.railway.app/assinaturas';

  final List<AssinaturaModel> _assinaturas = [];
  bool _carregando = false;

  ResumoFinanceiroModel? _resumoFinanceiro;
  bool _carregandoResumo = false;
  String? _erroResumo;

  List<AssinaturaModel> get assinaturas => List.unmodifiable(_assinaturas);
  bool get carregando => _carregando;

  ResumoFinanceiroModel? get resumoFinanceiro => _resumoFinanceiro;
  bool get carregandoResumo => _carregandoResumo;
  String? get erroResumo => _erroResumo;

  double get totalGastoMensal =>
      _assinaturas.fold(0.0, (total, item) => total + item.valor);

  Future<Map<String, String>> _obterHeaders() async {
    return await UsuarioRepository.instance.obterHeaders();
  }

  Future<ResumoFinanceiroModel?> carregarResumoFinanceiro({
    http.Client? client,
  }) async {
    _carregandoResumo = true;
    _erroResumo = null;
    notifyListeners();

    final createdClient = client == null;
    final httpClient = client ?? http.Client();

    try {
      final token = await UsuarioRepository.instance.obterToken();
      if (token == null || token.trim().isEmpty) {
        _resumoFinanceiro = null;
        return null;
      }

      final headers = await _obterHeaders();
      final url = '$_baseUrl/resumo-financeiro';

      final response = await httpClient.get(
        Uri.parse(url),
        headers: headers,
      );

      debugPrint('RESPOSTA RESUMO FINANCEIRO: ${response.statusCode}');

      if (response.statusCode == 200) {
        dynamic bodyDecodificado;
        try {
          bodyDecodificado = jsonDecode(response.body);
        } catch (_) {
          bodyDecodificado = jsonDecode(utf8.decode(response.bodyBytes));
        }

        final resumo = ResumoFinanceiroModel.fromJson(
          bodyDecodificado as Map<String, dynamic>,
        );

        _resumoFinanceiro = resumo;
        return resumo;
      } else {
        UsuarioRepository.instance.tratarErroHttp(response.statusCode);
        _erroResumo = 'Erro (${response.statusCode}) ao obter resumo financeiro.';
        return null;
      }
    } catch (e) {
      _erroResumo = 'Falha de conexão ao obter resumo financeiro.';
      debugPrint('Erro ao carregar resumo financeiro: $e');
      return null;
    } finally {
      _carregandoResumo = false;
      notifyListeners();
      if (createdClient) {
        httpClient.close();
      }
    }
  }

  Future<void> carregarAssinaturas() async {
    _carregando = true;
    notifyListeners();

    try {
      final token = await UsuarioRepository.instance.obterToken();

      if (token == null || token.trim().isEmpty) {
        _assinaturas.clear();
        _resumoFinanceiro = null;
        return;
      }

      final headers = await _obterHeaders();
      final usuarioId = UsuarioRepository.instance.value.id;

      final url = usuarioId.isNotEmpty
          ? '$_baseUrl?usuarioId=$usuarioId'
          : _baseUrl;

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final listaJson = jsonDecode(
          utf8.decode(response.bodyBytes),
        ) as List<dynamic>;

        _assinaturas
          ..clear()
          ..addAll(
            listaJson.map(
                  (item) => AssinaturaModel.fromJson(
                item as Map<String, dynamic>,
              ),
            ),
          );

        await NotificacaoService.instance.sincronizarNotificacoes(_assinaturas);
        await carregarResumoFinanceiro();
      } else {
        UsuarioRepository.instance.tratarErroHttp(response.statusCode);

        debugPrint(
          'Erro ao carregar assinaturas: ${response.statusCode}',
        );

        debugPrint(response.body);
      }
    } catch (e) {
      debugPrint('Erro ao carregar assinaturas: $e');
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<bool> adicionarAssinatura(AssinaturaModel assinatura) async {
    try {
      final headers = await _obterHeaders();
      final usuarioId = UsuarioRepository.instance.value.id;

      final dados = assinatura.toJson()..remove('id');

      final url = usuarioId.isNotEmpty
          ? '$_baseUrl?usuarioId=$usuarioId'
          : _baseUrl;

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(dados),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        await carregarAssinaturas();

        debugPrint('ASSINATURA CADASTRADA COM SUCESSO');

        return true;
      }

      UsuarioRepository.instance.tratarErroHttp(
        response.statusCode,
      );

      debugPrint(
        'Erro ao cadastrar: ${response.statusCode} ${response.body}',
      );

      return false;
    } catch (e) {
      debugPrint('Erro ao cadastrar assinatura: $e');
      return false;
    }
  }

  Future<bool> atualizarAssinatura(AssinaturaModel assinatura) async {
    try {
      final headers = await _obterHeaders();
      final dados = assinatura.toJson();

      // O backend Java espera datas no formato yyyy-MM-dd.
      dados['dataVencimento'] =
          assinatura.dataVencimento.toIso8601String().split('T').first;

      dados['dataInicioTeste'] =
          assinatura.dataInicioTeste?.toIso8601String().split('T').first;

      dados['dataFimTeste'] =
          assinatura.dataFimTeste?.toIso8601String().split('T').first;

      final response = await http.put(
        Uri.parse('$_baseUrl/${assinatura.id}'),
        headers: headers,
        body: jsonEncode(dados),
      );

      if (response.statusCode == 200) {
        await carregarAssinaturas();

        return true;
      }

      UsuarioRepository.instance.tratarErroHttp(response.statusCode);

      debugPrint(
        'Erro ao atualizar: ${response.statusCode} ${response.body}',
      );

      return false;
    } catch (e) {
      debugPrint('Erro ao atualizar assinatura: $e');
      return false;
    }
  }

  Future<bool> atualizarStatusCancelamento(
      String id,
      String novoStatus,
      ) async {
    try {
      final headers = await _obterHeaders();

      final response = await http.put(
        Uri.parse('$_baseUrl/$id/cancelar'),
        headers: headers,
        body: jsonEncode({
          'status': novoStatus,
        }),
      );

      if (response.statusCode != 200) {
        UsuarioRepository.instance.tratarErroHttp(response.statusCode);

        debugPrint(
          'Erro ao atualizar cancelamento: '
              '${response.statusCode} ${response.body}',
        );

        return false;
      }

      await carregarAssinaturas();

      if (novoStatus == StatusCancelamento.cancelled) {
        await NotificacaoService.instance.cancelarNotificacao(id);
      }

      return true;
    } catch (e, stackTrace) {
      debugPrint('Erro ao atualizar status de cancelamento: $e');
      debugPrint('$stackTrace');

      return false;
    }
  }

  Future<bool> cancelarAssinatura(String id) async {
    return await atualizarStatusCancelamento(
      id,
      StatusCancelamento.cancelled,
    );
  }

  Future<void> removerAssinatura(String id) async {
    try {
      final headers = await _obterHeaders();

      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await NotificacaoService.instance.cancelarNotificacao(id);

        _assinaturas.removeWhere((item) => item.id == id);

        await carregarResumoFinanceiro();
        notifyListeners();
      } else {
        UsuarioRepository.instance.tratarErroHttp(response.statusCode);

        debugPrint(
          'Erro ao excluir: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('Erro de conexão ao excluir assinatura: $e');
    }
  }
}
