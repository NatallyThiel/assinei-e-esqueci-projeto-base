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

  AssinaturaModel({
    required this.id,
    required this.nome,
    required this.valor,
    required this.dataVencimento,
    required this.metodoPagamento,
    this.plano = 'Plano Padrão',
    this.icone = Icons.subscriptions,
    this.corIcone = const Color(0xFF1B2A4A),
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'valor': valor,
      'dataVencimento': dataVencimento.toIso8601String(),
      'metodoPagamento': metodoPagamento,
      'plano': plano,
      'iconeCodePoint': icone.codePoint,
      'corIconeHex': corIcone.value,
    };
  }

  factory AssinaturaModel.fromJson(Map<String, dynamic> json) {
    return AssinaturaModel(
      id: json['id'],
      nome: json['nome'],
      valor: (json['valor'] as num).toDouble(),
      dataVencimento: DateTime.parse(json['dataVencimento']),
      metodoPagamento: json['metodoPagamento'] ?? '',
      plano: json['plano'] ?? 'Plano Padrão',
      icone: json['iconeCodePoint'] != null
          ? IconData(json['iconeCodePoint'], fontFamily: 'MaterialIcons')
          : Icons.subscriptions,
      corIcone: json['corIconeHex'] != null
          ? Color(json['corIconeHex'])
          : const Color(0xFF1B2A4A),
    );
  }
}