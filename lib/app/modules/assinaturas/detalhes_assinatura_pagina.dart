import 'package:flutter/material.dart';
import '../../data/models/assinatura_model.dart';
import 'editar_assinatura_pagina.dart';

class DetalhesAssinaturaPagina extends StatefulWidget {
  final AssinaturaModel? assinatura;
  final VoidCallback? onVoltar;

  const DetalhesAssinaturaPagina({
    super.key,
    this.assinatura,
    this.onVoltar,
  });

  @override
  State<DetalhesAssinaturaPagina> createState() =>
      _DetalhesAssinaturaPaginaState();
}

class _DetalhesAssinaturaPaginaState extends State<DetalhesAssinaturaPagina> {
  bool notificacaoAtiva = true;

  void _confirmarExclusao(BuildContext context, String idAssinatura, String nomeAssinatura) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: const Color(0xFFC8CEDC),
          title: const Text(
            'Excluir Assinatura',
            style: TextStyle(
              color: Color(0xFF1B2A4A),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Tem certeza que deseja excluir a assinatura de "$nomeAssinatura"? Essa ação não poderá ser desfeita.',
            style: const TextStyle(
              color: Color(0xFF1B2A4A),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'CANCELAR',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Fecha o modal de confirmação

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Assinatura "$nomeAssinatura" excluída com sucesso!'),
                    backgroundColor: Colors.redAccent,
                  ),
                );

                // Retorna 'true' para sinalizar que a assinatura foi excluída
                if (widget.onVoltar != null) {
                  widget.onVoltar!();
                } else {
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'EXCLUIR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.assinatura ??
        AssinaturaModel(
          id: '1',
          nome: 'IFOOD',
          valor: 19.90,
          dataVencimento: DateTime(2027, 9, 20),
          metodoPagamento: 'Cartão de Crédito',
        );

    final valorFormatado = item.valor.toStringAsFixed(2).replaceAll('.', ',');
    final dataFormatada =
        "${item.dataVencimento.day.toString().padLeft(2, '0')}/${item.dataVencimento.month.toString().padLeft(2, '0')}/${item.dataVencimento.year}";

    return Scaffold(
      backgroundColor: const Color(0xFFD3D3D3),
      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
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
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF1B2A4A), size: 28),
                        onPressed: widget.onVoltar ?? () => Navigator.pop(context),
                      ),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 38,
                        errorBuilder: (context, error, stackTrace) => const Text(
                          'Assinei\n& Esqueci',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2A4A),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'DETALHES DA ASSINATURA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2A4A),
                      letterSpacing: 0.8,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Card 1: Resumo da Assinatura
                  _construirCardBase(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RESUMO DA ASSINATURA:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2A4A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _linhaInfo('SERVIÇO:', item.nome),
                        _linhaInfo('VALOR:', 'R\$ $valorFormatado/mês'),
                        _linhaInfo('VENCIMENTO:', '$dataFormatada (em 3 dias)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                      // Botao Editar Dados da Assinatura
                  // Botão Editar Dados da Assinatura
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () async {
                        final assinaturaAtualizada = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditarAssinaturaPagina(
                              assinatura: item,
                            ),
                          ),
                        );

                        if (assinaturaAtualizada != null) {
                          debugPrint('Assinatura retornou da edição.');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1B2A4A),
                        side: const BorderSide(
                          color: Color(0xFF1B2A4A),
                          width: 1.5,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'EDITAR DADOS DA ASSINATURA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),


                  _construirCardBase(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MÉTODO DE PAGAMENTO:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2A4A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B2A4A),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.credit_card,
                                color: Colors.amber,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.metodoPagamento.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B2A4A),
                                    ),
                                  ),
                                  const Text(
                                    'VISA *** 1162',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'REMOVER',
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
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1B2A4A),
                              side: const BorderSide(color: Color(0xFF1B2A4A), width: 1.5),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              'ALTERAR MÉTODO DE PAGAMENTO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card 3: status do lembrete
                  _construirCardBase(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STATUS DO LEMBRETE:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2A4A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        _linhaInfo('ALERTA DEFINIDO PARA:', '$dataFormatada ÀS 10h'),
                        _linhaInfo('NOTIFICAÇÃO:', notificacaoAtiva ? 'Ativada' : 'Desativada'),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                notificacaoAtiva = !notificacaoAtiva;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1B2A4A),
                              side: const BorderSide(color: Color(0xFF1B2A4A), width: 1.5),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              'EDITAR ALERTA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card 4: Aviso
                  _construirCardBase(
                    child: const Text(
                      'AVISO: Suas informações são protegidas de acordo com nossa Política de Privacidade. Algumas alterações podem levar até 24h para serem processadas.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão Excluir Assinatura
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _confirmarExclusao(context, item.id, item.nome),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C), // Vermelho discreto e elegante
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 2,
                      ),
                      child: const Text(
                        'EXCLUIR ASSINATURA',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCardBase({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFC8CEDC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _linhaInfo(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        children: [
          Text(
            '$titulo ',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2A4A),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}