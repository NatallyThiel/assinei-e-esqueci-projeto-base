import 'package:flutter/material.dart';
import '../../data/models/assinatura_model.dart';
import '../assinaturas/detalhes_assinatura_pagina.dart';

class GerenciarLembretePagina extends StatefulWidget {
  final AssinaturaModel assinatura;

  const GerenciarLembretePagina({
    super.key,
    required this.assinatura,
  });

  @override
  State<GerenciarLembretePagina> createState() =>
      _GerenciarLembretePaginaState();
}

class _GerenciarLembretePaginaState extends State<GerenciarLembretePagina> {
  late bool _notificacaoAtivada;

  @override
  void initState() {
    super.initState();
    _notificacaoAtivada = true;
  }

  void _editarAlerta() {
    showDatePicker(
      context: context,
      initialDate: widget.assinatura.dataVencimento,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).then((novaData) {
      if (novaData != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data do alerta atualizada!')),
        );
      }
    });
  }

  void _salvarAlteracoes() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alterações salvas com sucesso!'),
        backgroundColor: Color(0xFF1B2A4A),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.assinatura;
    final hoje = DateTime.now();
    final dataVenc = item.dataVencimento;
    final diferencaDias = DateTime(dataVenc.year, dataVenc.month, dataVenc.day)
        .difference(DateTime(hoje.year, hoje.month, hoje.day))
        .inDays;

    final String textoDias = diferencaDias < 0
        ? 'há ${-diferencaDias} dia(s)'
        : diferencaDias == 0
        ? 'hoje'
        : 'em $diferencaDias dia(s)';

    final dataVencFormatada =
        "${dataVenc.day.toString().padLeft(2, '0')}/${dataVenc.month.toString().padLeft(2, '0')}/${dataVenc.year}";

    final valorFormatado = item.valor.toStringAsFixed(2).replaceAll('.', ',');

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
                        onPressed: () => Navigator.pop(context),
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
                    'GERENCIAR LEMBRETE',
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
              child: Column(
                children: [
                  _cardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RESUMO DA ASSINATURA:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2A4A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _linhaTexto('SERVIÇO:', item.nome.toUpperCase()),
                        _linhaTexto('VALOR:', 'R\$ $valorFormatado/mês'),
                        _linhaTexto('VENCIMENTO:',
                            '$dataVencFormatada ($textoDias)'),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalhesAssinaturaPagina(
                                  assinatura: item,
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1B2A4A)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(double.infinity, 38),
                          ),
                          child: const Text(
                            'VER DETALHES DA ASSINATURA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _cardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MÉTODO DE PAGAMENTO:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2A4A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.credit_card,
                              color: Color(0xFF2C436D),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'CARTÃO DE CRÉDITO',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1B2A4A),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'VISA   ••• 1162',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Método de pagamento removido.'),
                                  ),
                                );
                              },
                              child: const Text(
                                'REMOVER',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _cardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STATUS DO LEMBRETE:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2A4A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _linhaTexto(
                          'ALERTA DEFINIDO PARA:',
                          '$dataVencFormatada ÀS 10h',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _linhaTexto(
                              'NOTIFICAÇÃO:',
                              _notificacaoAtivada ? 'Ativada' : 'Desativada',
                            ),
                            Switch(
                              value: _notificacaoAtivada,
                              activeColor: const Color(0xFF1B2A4A),
                              onChanged: (val) {
                                setState(() {
                                  _notificacaoAtivada = val;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _editarAlerta,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF1B2A4A)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            minimumSize: const Size(double.infinity, 38),
                          ),
                          child: const Text(
                            'EDITAR ALERTA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  _cardContainer(
                    child: const Text(
                      'AVISO: Suas informações são protegidas de acordo com nossa Política de Privacidade. Algumas alterações podem levar até 24h para serem processadas.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _salvarAlteracoes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B2A4A),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'SALVAR ALTERAÇÕES',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Componentes auxiliares de layout
  Widget _cardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFC8CEDC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _linhaTexto(String rotulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Color(0xFF1B2A4A)),
          children: [
            TextSpan(
              text: '$rotulo ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: valor),
          ],
        ),
      ),
    );
  }
}