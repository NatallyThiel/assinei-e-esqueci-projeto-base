import 'package:flutter/material.dart';

class CartaoModel {
  final String id;
  final String usuarioId;
  final String nome;
  final String bandeira;
  final String ultimosDigitos;
  final Color cor;

  CartaoModel({
    required this.id,
    required this.usuarioId,
    required this.nome,
    required this.bandeira,
    required this.ultimosDigitos,
    this.cor = const Color(0xFF1B2A4A),
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuarioId': usuarioId,
        'nome': nome,
        'bandeira': bandeira,
        'ultimosDigitos': ultimosDigitos,
        'corHex': cor.toARGB32(),
      };

  factory CartaoModel.fromJson(Map<String, dynamic> json) {
    return CartaoModel(
      id: json['id']?.toString() ?? '',
      usuarioId: json['usuarioId']?.toString() ?? '',
      nome: json['nome'] ?? 'Cartão',
      bandeira: json['bandeira'] ?? 'Visa',
      ultimosDigitos: json['ultimosDigitos']?.toString() ?? '0000',
      cor: json['corHex'] != null
          ? Color((json['corHex'] as num).toInt())
          : const Color(0xFF1B2A4A),
    );
  }

  CartaoModel copyWith({
    String? id,
    String? usuarioId,
    String? nome,
    String? bandeira,
    String? ultimosDigitos,
    Color? cor,
  }) {
    return CartaoModel(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nome: nome ?? this.nome,
      bandeira: bandeira ?? this.bandeira,
      ultimosDigitos: ultimosDigitos ?? this.ultimosDigitos,
      cor: cor ?? this.cor,
    );
  }
}
