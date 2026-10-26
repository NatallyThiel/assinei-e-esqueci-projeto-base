import 'package:flutter/material.dart';

class AssinaturaModel {
  final String id;
  final String nome;
  final double valor;
  final DateTime dataVencimento;
  final String metodoPagamento;
  final String plano;
  final IconData icone;
  final Color corIcone;
  final String plataforma;
  final bool testeGratis;

  AssinaturaModel({
    required this.id,
    required this.nome,
    required this.valor,
    required this.dataVencimento,
    required this.metodoPagamento,
    this.plano = 'Plano Padrão',
    this.icone = Icons.subscriptions,
    this.corIcone = const Color(0xFF1B2A4A),
    this.plataforma = '',
    this.testeGratis = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nome': nome,
    'valor': valor,
    'dataVencimento': dataVencimento.toIso8601String(),
    'metodoPagamento': metodoPagamento,
    'plano': plano,
    'iconeCodePoint': icone.codePoint,
    'corIconeHex': corIcone.value,
    'plataforma': plataforma,
    'testeGratis': testeGratis,
  };

  factory AssinaturaModel.fromJson(Map<String, dynamic> json) {
    return AssinaturaModel(
      id: json['id'].toString(),
      nome: json['nome'] ?? '',
      valor: (json['valor'] as num).toDouble(),
      dataVencimento: json['dataVencimento'] != null
          ? DateTime.parse(json['dataVencimento'])
          : DateTime.now(),
      metodoPagamento: json['metodoPagamento'] ?? '',
      plano: json['plano'] ?? 'Plano Padrão',
      icone: json['iconeCodePoint'] != null
          ? IconData((json['iconeCodePoint'] as num).toInt(),
          fontFamily: 'MaterialIcons')
          : Icons.subscriptions,
      corIcone: json['corIconeHex'] != null
          ? Color((json['corIconeHex'] as num).toInt())
          : const Color(0xFF1B2A4A),
      plataforma: json['plataforma'] ?? '',
      testeGratis: json['testeGratis'] == true,
    );
  }
}