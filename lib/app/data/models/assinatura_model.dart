import 'package:flutter/material.dart';

class StatusCancelamento {
  static const String active = 'ACTIVE';
  static const String cancelRequested = 'CANCEL_REQUESTED';
  static const String awaitingConfirmation = 'AWAITING_CONFIRMATION';
  static const String cancelled = 'CANCELLED';
  static const String failed = 'FAILED';
}

class AssinaturaModel {
  final String id;
  final String nome;
  final double valor;
  final DateTime dataVencimento;
  final String metodoPagamento;
  final String plano;
  final String categoria;
  final IconData icone;
  final Color corIcone;
  final String plataforma;
  final bool testeGratis;
  final bool notificacaoAtivada;
  final String horarioAlerta;
  final String statusCancelamento;
  final DateTime? dataInicioTeste;
  final DateTime? dataFimTeste;
  final String? urlCancelamento;
  final String? cartaoId;

  AssinaturaModel({
    required this.id,
    required this.nome,
    required this.valor,
    required this.dataVencimento,
    required this.metodoPagamento,
    this.plano = 'Plano Padrão',
    this.categoria = 'OUTROS',
    this.icone = Icons.subscriptions,
    this.corIcone = const Color(0xFF1B2A4A),
    this.plataforma = '',
    this.testeGratis = false,
    this.notificacaoAtivada = true,
    this.horarioAlerta = '10:00',
    this.statusCancelamento = StatusCancelamento.active,
    this.dataInicioTeste,
    this.dataFimTeste,
    this.urlCancelamento,
    this.cartaoId,
  });

  int get diasRestantesTeste {
    if (!testeGratis || dataFimTeste == null) return 0;

    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);

    final fim = DateTime(
      dataFimTeste!.year,
      dataFimTeste!.month,
      dataFimTeste!.day,
    );

    final diff = fim.difference(inicioHoje).inDays;

    return diff < 0 ? 0 : diff;
  }

  bool get testeProximoDoFim {
    if (!testeGratis || dataFimTeste == null) return false;

    final dias = diasRestantesTeste;

    return dias >= 0 && dias <= 3;
  }

  AssinaturaModel copyWith({
    String? id,
    String? nome,
    double? valor,
    DateTime? dataVencimento,
    String? metodoPagamento,
    String? plano,
    String? categoria,
    IconData? icone,
    Color? corIcone,
    String? plataforma,
    bool? testeGratis,
    bool? notificacaoAtivada,
    String? horarioAlerta,
    String? statusCancelamento,
    DateTime? dataInicioTeste,
    DateTime? dataFimTeste,
    String? urlCancelamento,
    String? cartaoId,
  }) {
    return AssinaturaModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      valor: valor ?? this.valor,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      metodoPagamento: metodoPagamento ?? this.metodoPagamento,
      plano: plano ?? this.plano,
      categoria: categoria ?? this.categoria,
      icone: icone ?? this.icone,
      corIcone: corIcone ?? this.corIcone,
      plataforma: plataforma ?? this.plataforma,
      testeGratis: testeGratis ?? this.testeGratis,
      notificacaoAtivada:
      notificacaoAtivada ?? this.notificacaoAtivada,
      horarioAlerta: horarioAlerta ?? this.horarioAlerta,
      statusCancelamento:
      statusCancelamento ?? this.statusCancelamento,
      dataInicioTeste: dataInicioTeste ?? this.dataInicioTeste,
      dataFimTeste: dataFimTeste ?? this.dataFimTeste,
      urlCancelamento: urlCancelamento ?? this.urlCancelamento,
      cartaoId: cartaoId ?? this.cartaoId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'valor': valor,
    'dataVencimento': dataVencimento.toIso8601String(),
    'metodoPagamento': metodoPagamento,
    'plano': plano,
    'categoria': categoria.trim().isEmpty ? 'OUTROS' : categoria.trim(),
    'iconeCodePoint': icone.codePoint,
    'corIconeHex': corIcone.toARGB32(),
    'plataforma': plataforma,
    'testeGratis': testeGratis,
    'notificacaoAtivada': notificacaoAtivada,
    'horarioAlerta': horarioAlerta,

    // O backend Java utiliza o campo "status".
    'status': statusCancelamento,

    'dataInicioTeste': dataInicioTeste?.toIso8601String(),
    'dataFimTeste': dataFimTeste?.toIso8601String(),
    'urlCancelamento': urlCancelamento,
    'cartaoId': cartaoId,
  };

  factory AssinaturaModel.fromJson(Map<String, dynamic> json) {
    final catRaw = json['categoria']?.toString().trim();
    final catVal = (catRaw != null && catRaw.isNotEmpty) ? catRaw : 'OUTROS';

    return AssinaturaModel(
      id: json['id'].toString(),
      nome: json['nome'] ?? '',
      valor: (json['valor'] as num).toDouble(),
      dataVencimento: json['dataVencimento'] != null
          ? DateTime.parse(json['dataVencimento'])
          : DateTime.now(),
      metodoPagamento: json['metodoPagamento'] ?? '',
      plano: json['plano'] ?? 'Plano Padrão',
      categoria: catVal,
      icone: json['iconeCodePoint'] != null
          ? IconData(
              // ignore: non_const_argument_for_const_parameter
              (json['iconeCodePoint'] as num).toInt(),
              fontFamily: 'MaterialIcons',
            )
          : Icons.subscriptions,
      corIcone: json['corIconeHex'] != null
          ? Color((json['corIconeHex'] as num).toInt())
          : const Color(0xFF1B2A4A),
      plataforma: json['plataforma'] ?? '',
      testeGratis: json['testeGratis'] == true,
      notificacaoAtivada: json['notificacaoAtivada'] != false,
      horarioAlerta: json['horarioAlerta'] ?? '10:00',

      // Prioriza o campo novo e mantém compatibilidade com dados antigos.
      statusCancelamento:
      json['status'] ??
          json['statusCancelamento'] ??
          StatusCancelamento.active,

      dataInicioTeste: json['dataInicioTeste'] != null
          ? DateTime.parse(json['dataInicioTeste'])
          : null,
      dataFimTeste: json['dataFimTeste'] != null
          ? DateTime.parse(json['dataFimTeste'])
          : null,
      urlCancelamento: json['urlCancelamento'] as String?,
      cartaoId: json['cartaoId']?.toString(),
    );
  }
}
