import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/assinatura_model.dart';
import '../../data/repositories/assinatura_repository.dart';
import '../home/detalhes_cancelamento_pagina.dart';

class CentralCancelamentosPagina extends StatelessWidget {
  const CentralCancelamentosPagina({super.key});

  Color _corDoStatus(String status) {
    switch (status) {
      case StatusCancelamento.active:
        return const Color(0xFF1B2A4A);
      case StatusCancelamento.cancelRequested:
        return Colors.amber.shade900;
      case StatusCancelamento.awaitingConfirmation:
        return Colors.orange.shade800;
      case StatusCancelamento.cancelled:
        return Colors.green.shade700;
      case StatusCancelamento.failed:
        return Colors.red.shade700;
      default:
        return const Color(0xFF1B2A4A);
    }
  }

  String _rotuloDoStatus(String status) {
    switch (status) {
      case StatusCancelamento.active:
        return 'ATIVA';
      case StatusCancelamento.cancelRequested:
        return 'CANCELAMENTO SOLICITADO';
      case StatusCancelamento.awaitingConfirmation:
        return 'AGUARDANDO CONFIRMAÇÃO';
      case StatusCancelamento.cancelled:
        return 'CANCELADA';
      case StatusCancelamento.failed:
        return 'FALHA NO CANCELAMENTO';
      default:
        return status;
    }
  }

  Future<void> _abrirUrlOficial(BuildContext context, String? urlStr) async {
    if (urlStr == null || urlStr.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhum link oficial cadastrado para este serviço.',
          ),
          backgroundColor: Color(0xFF1B2A4A),
        ),
      );
      return;
    }

    try {
      final uri = Uri.parse(urlStr);
      final podeAbrir = await canLaunchUrl(uri);
      if (podeAbrir) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir o link: $urlStr'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao acessar URL: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
                top: 50,
                left: 16,
                right: 16,
                bottom: 20,
              ),
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
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF1B2A4A),
                          size: 28,
                        ),
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
                    'CENTRAL DE CANCELAMENTOS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2A4A),
                      letterSpacing: 1.0,
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
                      margin: const EdgeInsets.only(top: 30, bottom: 40),
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
                            Icons.cancel_outlined,
                            size: 64,
                            color: Color(0xFF1B2A4A),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhuma assinatura para gerenciar',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Cadastre suas assinaturas para iniciar ou acompanhar solicitações de cancelamento.',
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

                  return Column(
                    children: assinaturas.map((item) {
                      final corStatus = _corDoStatus(item.statusCancelamento);
                      final valorStr = item.valor
                          .toStringAsFixed(2)
                          .replaceAll('.', ',');

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.nome.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B2A4A),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: corStatus.withAlpha(25),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: corStatus,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    _rotuloDoStatus(item.statusCancelamento),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: corStatus,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
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
                                        'R\$ $valorStr',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B2A4A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Método: ${item.metodoPagamento}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetalhesCancelamentoPagina(
                                            assinatura: item,
                                          ),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF1B2A4A),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      minimumSize:
                                          const Size(double.infinity, 38),
                                    ),
                                    child: const Text(
                                      'GERENCIAR CANCELAMENTO',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B2A4A),
                                      ),
                                    ),
                                  ),
                                ),
                                if (item.urlCancelamento != null &&
                                    item.urlCancelamento!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.open_in_new,
                                      color: Color(0xFF2C436D),
                                    ),
                                    tooltip: 'Abrir site oficial',
                                    onPressed: () => _abrirUrlOficial(
                                      context,
                                      item.urlCancelamento,
                                    ),
                                  ),
                                ],
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
