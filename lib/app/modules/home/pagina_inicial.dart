import 'package:flutter/material.dart';
import '../../data/models/assinatura_model.dart';
import '../../data/repositories/assinatura_repository.dart';
import '../../data/repositories/usuario_repository.dart';
import '../alertas/alertas_pagina.dart';
import '../alertas/gerenciar_lembrete_pagina.dart';
import '../assinaturas/assinaturas_pagina.dart';
import '../assinaturas/cadastro_assinatura_pagina.dart';
import '../perfil/perfil_pagina.dart';
import 'detalhes_cancelamento_pagina.dart';

class PaginaInicial extends StatefulWidget {
  final int abaInicial;

  const PaginaInicial({super.key, this.abaInicial = 0});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  late int _indiceAba;

  @override
  void initState() {
    super.initState();
    _indiceAba = widget.abaInicial;

    AssinaturasRepository.instance.carregarAssinaturas();
  }

  void _mudarAba(int index) {
    setState(() {
      _indiceAba = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _indiceAba,
        children: [
          _HomeDashboardView(
            onIrParaAssinaturas: () => _mudarAba(1),
          ),
          const AssinaturasPagina(),
          const AlertasPagina(),
          const PerfilPagina(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceAba,
        onTap: _mudarAba,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1B2A4A),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        selectedLabelStyle:
        const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.layers), label: 'Assinaturas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Alertas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _HomeDashboardView extends StatelessWidget {
  final VoidCallback onIrParaAssinaturas;

  const _HomeDashboardView({required this.onIrParaAssinaturas});

  Future<void> _abrirCadastroAssinatura(BuildContext context) async {
    final repository = AssinaturasRepository.instance;
    final novaAssinatura = await Navigator.push<AssinaturaModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const CadastroAssinaturaPagina(),
      ),
    );

    if (novaAssinatura != null) {
      repository.adicionarAssinatura(novaAssinatura);
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
                  top: 50, left: 20, right: 20, bottom: 20),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 38,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'Assinei\n& Esqueci',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2A4A),
                          fontSize: 12),
                    ),
                  ),
                  ValueListenableBuilder<UsuarioModel>(
                    valueListenable: UsuarioRepository.instance,
                    builder: (context, usuario, child) {
                      final primeiroNome = usuario.nome.isNotEmpty
                          ? usuario.nome.trim().split(' ').first
                          : 'Usuário';

                      return Row(
                        children: [
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Color(0xFF5AC8FA),
                            child: Icon(Icons.person,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            primeiroNome,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B2A4A)),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListenableBuilder(
                listenable: repository,
                builder: (context, child) {
                  final assinaturasAtivas = repository.assinaturas;

                  if (assinaturasAtivas.isEmpty) {
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
                        children: [
                          const Icon(
                            Icons.subscriptions_outlined,
                            size: 64,
                            color: Color(0xFF1B2A4A),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhuma assinatura cadastrada',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Organize seus gastos recorrentes e nunca mais perca a data de um vencimento.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 28),

                          InkWell(
                            onTap: () => _abrirCadastroAssinatura(context),
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B2A4A),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(38),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_circle_outline,
                                      color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      'CRIE SUA PRIMEIRA ASSINATURA',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final totalGasto = repository.totalGastoMensal
                      .toStringAsFixed(2)
                      .replaceAll('.', ',');

                  final proximaAssinatura = List<AssinaturaModel>.from(assinaturasAtivas)
                    ..sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));
                  final itemMaisProximo = proximaAssinatura.first;

                  final hoje = DateTime.now();
                  final dataVenc = itemMaisProximo.dataVencimento;
                  final diferencaDias = DateTime(dataVenc.year, dataVenc.month, dataVenc.day)
                      .difference(DateTime(hoje.year, hoje.month, hoje.day))
                      .inDays;

                  final String textoDias = diferencaDias < 0
                      ? 'VENCEU'
                      : diferencaDias == 0
                      ? 'HOJE'
                      : '$diferencaDias ${diferencaDias == 1 ? "DIA" : "DIAS"}';

                  return Column(
                    children: [
                      _cardBase(
                        color: const Color(0xFFB0B7C6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SUA ASSINATURA ${itemMaisProximo.nome.toUpperCase()} VENCE EM:',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    textoDias,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1B2A4A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetalhesCancelamentoPagina(
                                              assinatura: itemMaisProximo,
                                            ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B2A4A),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    minimumSize: const Size(110, 32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'CANCELAR AGORA',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            GerenciarLembretePagina(
                                              assinatura: itemMaisProximo,
                                            ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C436D),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    minimumSize: const Size(110, 32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'LEMBRAR DEPOIS',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      _cardBase(
                        child: Column(
                          children: [
                            const Text('TOTAL GASTO MENSAL',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B2A4A))),
                            const SizedBox(height: 4),
                            Text('R\$ $totalGasto',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B2A4A))),
                            const Text('ESTIMADO',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      _cardBase(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PRÓXIMAS COBRANÇAS',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B2A4A))),
                            const SizedBox(height: 12),
                            ...assinaturasAtivas.take(2).map((item) {
                              final valorStr = item.valor
                                  .toStringAsFixed(2)
                                  .replaceAll('.', ',');
                              final dataStr =
                                  "${item.dataVencimento.day.toString().padLeft(2, '0')}/${item.dataVencimento.month.toString().padLeft(2, '0')}";
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: _linhaCobranca(
                                  item.nome.toUpperCase(),
                                  'Venc. $dataStr',
                                  'R\$ $valorStr',
                                  item.icone,
                                  item.corIcone,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      InkWell(
                        onTap: onIrParaAssinaturas,
                        borderRadius: BorderRadius.circular(16),
                        child: _cardBase(
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('ASSINATURAS ATIVAS',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B2A4A))),
                                  Icon(Icons.arrow_forward_ios,
                                      size: 14, color: Color(0xFF1B2A4A)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...assinaturasAtivas.map(
                                    (item) {
                                  final valorStr = item.valor
                                      .toStringAsFixed(2)
                                      .replaceAll('.', ',');
                                  return Padding(
                                    padding:
                                    const EdgeInsets.only(bottom: 8.0),
                                    child: _linhaSimples(
                                      item.nome.toUpperCase(),
                                      'R\$ $valorStr',
                                      item.icone,
                                      item.corIcone,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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

  static Widget _cardBase(
      {required Widget child, Color color = const Color(0xFFC8CEDC)}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
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

  static Widget _linhaCobranca(String titulo, String sub, String valor,
      IconData icone, Color corIcone) {
    return Row(
      children: [
        Icon(icone, color: corIcone, size: 20),
        const SizedBox(width: 8),
        Expanded(
            child: Text(titulo,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2A4A)))),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(sub,
                style: const TextStyle(fontSize: 9, color: Colors.black54)),
            Text(valor,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2A4A))),
          ],
        )
      ],
    );
  }

  static Widget _linhaSimples(
      String titulo, String valor, IconData icone, Color corIcone) {
    return Row(
      children: [
        Icon(icone, color: corIcone, size: 20),
        const SizedBox(width: 8),
        Expanded(
            child: Text(titulo,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B2A4A)))),
        Text(valor,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2A4A))),
      ],
    );
  }
}