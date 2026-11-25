import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/models/assinatura_model.dart';
import '../../data/repositories/assinatura_repository.dart';
import '../assinaturas/detalhes_assinatura_pagina.dart';

class CalendarioCobrancasPagina extends StatefulWidget {
  const CalendarioCobrancasPagina({super.key});

  @override
  State<CalendarioCobrancasPagina> createState() =>
      _CalendarioCobrancasPaginaState();
}

class _CalendarioCobrancasPaginaState extends State<CalendarioCobrancasPagina> {
  DateTime _diaFocado = DateTime.now();
  DateTime _diaSelecionado = DateTime.now();

  bool _mesmoDia(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<AssinaturaModel> _obterEventosDoDia(
      DateTime day, List<AssinaturaModel> assinaturas) {
    return assinaturas.where((a) {
      final venceNoDia = _mesmoDia(a.dataVencimento, day);
      final testeTerminaNoDia =
          a.testeGratis && _mesmoDia(a.dataFimTeste, day);
      return venceNoDia || testeTerminaNoDia;
    }).toList();
  }

  String _dataFormatada(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
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
                    'CALENDÁRIO DE COBRANÇAS',
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListenableBuilder(
                listenable: repository,
                builder: (context, child) {
                  final assinaturas = repository.assinaturas;
                  final eventosDoDiaSelecionado =
                      _obterEventosDoDia(_diaSelecionado, assinaturas);

                  final totalPrevistoNoDia = eventosDoDiaSelecionado.fold(
                    0.0,
                    (sum, item) => sum + item.valor,
                  );

                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(15),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TableCalendar<AssinaturaModel>(
                          locale: 'pt_BR',
                          firstDay: DateTime(2020),
                          lastDay: DateTime(2035),
                          focusedDay: _diaFocado,
                          selectedDayPredicate: (day) =>
                              _mesmoDia(_diaSelecionado, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _diaSelecionado = selectedDay;
                              _diaFocado = focusedDay;
                            });
                          },
                          eventLoader: (day) =>
                              _obterEventosDoDia(day, assinaturas),
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: const Color(0xFF7E9BB8),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Color(0xFF1B2A4A),
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, day, events) {
                              if (events.isEmpty) return const SizedBox();
                              final temAtrasado = events.any((a) {
                                final d = DateTime(
                                  a.dataVencimento.year,
                                  a.dataVencimento.month,
                                  a.dataVencimento.day,
                                );
                                final h = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                );
                                return d.isBefore(h);
                              });
                              final temTesteGratis =
                                  events.any((a) => a.testeGratis);

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 1),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: temAtrasado
                                          ? Colors.red
                                          : temTesteGratis
                                              ? Colors.amber.shade900
                                              : const Color(0xFF1B2A4A),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card com resumo do dia selecionado
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8CEDC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'COBRANÇAS EM ${_dataFormatada(_diaSelecionado)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B2A4A),
                                  ),
                                ),
                                Text(
                                  'Total: R\$ ${totalPrevistoNoDia.toStringAsFixed(2).replaceAll('.', ',')}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B2A4A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (eventosDoDiaSelecionado.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(
                                  child: Text(
                                    'Nenhum vencimento ou fim de teste cadastrado para este dia.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...eventosDoDiaSelecionado.map((item) {
                                final hoje = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                );
                                final dataVenc = DateTime(
                                  item.dataVencimento.year,
                                  item.dataVencimento.month,
                                  item.dataVencimento.day,
                                );

                                final isAtrasado = dataVenc.isBefore(hoje);
                                final isHoje = _mesmoDia(dataVenc, hoje);
                                final isFimTeste = item.testeGratis &&
                                    _mesmoDia(
                                        item.dataFimTeste, _diaSelecionado);

                                final String tagTexto = isFimTeste
                                    ? 'FIM DO TESTE GRÁTIS'
                                    : isAtrasado
                                        ? 'ATRASADO'
                                        : isHoje
                                            ? 'VENCE HOJE'
                                            : 'COBRANÇA FUTURA';

                                final Color corTag = isFimTeste
                                    ? Colors.amber.shade900
                                    : isAtrasado
                                        ? Colors.red.shade700
                                        : isHoje
                                            ? Colors.orange.shade800
                                            : const Color(0xFF1B2A4A);

                                final valorStr = item.valor
                                    .toStringAsFixed(2)
                                    .replaceAll('.', ',');

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        item.icone,
                                        color: item.corIcone,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.nome.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1B2A4A),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              tagTexto,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: corTag,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'R\$ $valorStr',
                                            style: const TextStyle(
                                              fontSize: 12,
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
                                                      DetalhesAssinaturaPagina(
                                                    assinatura: item,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'VER DETALHES',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
