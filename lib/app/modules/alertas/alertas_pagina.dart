import 'package:flutter/material.dart';
import '../../data/models/assinatura_model.dart';
import '../../data/repositories/assinatura_repository.dart';
import 'gerenciar_lembrete_pagina.dart';

class AlertasPagina extends StatelessWidget {
  const AlertasPagina({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AssinaturasRepository.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFD3D3D3),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 50, left: 16, right: 16, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2C436D),
                    Color(0xFF7E9BB8),
                    Color(0xFFD3D3D3),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Color(0xFF1B2A4A), size: 28),
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 38,
                        errorBuilder: (context, error, stackTrace) =>
                        const Text(
                          'Assinei\n& Esqueci',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2A4A),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'ALERTAS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2A4A),
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListenableBuilder(
                listenable: repository,
                builder: (context, child) {
                  final assinaturas = repository.assinaturas;

                  if (assinaturas.isEmpty) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 20, bottom: 40),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Color(0xFF1B2A4A),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum alerta pendente',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Cadastre assinaturas para visualizar e gerenciar seus lembretes de cobrança.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final listaOrdenada = List<AssinaturaModel>.from(assinaturas)
                    ..sort((a, b) =>
                        a.dataVencimento.compareTo(b.dataVencimento));

                  return Column(
                    children: listaOrdenada.map((item) {
                      final hoje = DateTime.now();
                      final dataVenc = item.dataVencimento;
                      final diferencaDias = DateTime(
                          dataVenc.year, dataVenc.month, dataVenc.day)
                          .difference(DateTime(hoje.year, hoje.month, hoje.day))
                          .inDays;

                      final String textoDias = diferencaDias < 0
                          ? 'Venceu há ${-diferencaDias} dia(s)'
                          : diferencaDias == 0
                          ? 'Vence HOJE!'
                          : 'Vence em $diferencaDias dia(s)';

                      final dataFormatada =
                          "${dataVenc.day.toString().padLeft(2, '0')}/${dataVenc.month.toString().padLeft(2, '0')}/${dataVenc.year}";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(12),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.nome.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B2A4A),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            GerenciarLembretePagina(
                                              assinatura: item,
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'VER DETALHES',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: item.corIcone.withAlpha(30),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item.icone,
                                    color: item.corIcone,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        textoDias,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: diferencaDias <= 3
                                              ? Colors.redAccent
                                              : const Color(0xFF2C436D),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Vencimento: $dataFormatada',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.notifications_active,
                                  color: Color(0xFF1B2A4A),
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}