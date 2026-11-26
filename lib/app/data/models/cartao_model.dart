import 'package:flutter/material.dart';

Color _parseCor(dynamic rawColor, {Color corPadrao = const Color(0xFF1B2A4A)}) {
  if (rawColor == null) return corPadrao;

  if (rawColor is num) {
    return Color(rawColor.toInt());
  }

  if (rawColor is String) {
    final str = rawColor.trim();
    if (str.isEmpty) return corPadrao;

    final parsedInt = int.tryParse(str);
    if (parsedInt != null) {
      return Color(parsedInt);
    }

    var cleanHex = str.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }
    final hexInt = int.tryParse(cleanHex, radix: 16);
    if (hexInt != null) {
      return Color(hexInt);
    }
  }

  return corPadrao;
}

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
    final rawColor = json['corHex'] ?? json['cor'] ?? json['cor_hex'];

    return CartaoModel(
      id: json['id']?.toString() ?? '',
      usuarioId: json['usuarioId']?.toString() ?? json['usuario_id']?.toString() ?? '',
      nome: json['nome']?.toString() ?? 'Cartão',
      bandeira: json['bandeira']?.toString() ?? 'Visa',
      ultimosDigitos: json['ultimosDigitos']?.toString() ?? json['ultimos_digitos']?.toString() ?? '0000',
      cor: _parseCor(rawColor),
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
