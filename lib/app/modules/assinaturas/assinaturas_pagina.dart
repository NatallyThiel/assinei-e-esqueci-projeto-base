
import 'package:flutter/material.dart';
import '../../data/models/assinatura_model.dart';
import '../../data/repositories/assinatura_repository.dart';
import 'cadastro_assinatura_pagina.dart';
import 'detalhes_assinatura_pagina.dart';

class AssinaturasPagina extends StatelessWidget {
  const AssinaturasPagina({super.key});

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
      body: ListenableBuilder(
        listenable: repository,
        builder: (context, child) {
          final assinaturas = repository.assinaturas;

          final proximoVencimento = assinaturas.isEmpty
              ? null
              : assinaturas
              .map((a) => a.dataVencimento)
              .reduce((a, b) => a.isBefore(b) ? a : b);

          final totalMensal = repository.totalGastoMensal
              .toStringAsFixed(2)
              .replaceAll('.', ',');

          return SingleChildScrollView(
            child: Column(
              children: [
                // Cabeçalho
                Container(
                  padding: const EdgeInsets.only(
                    top: 50,
                    left: 16,
                    right: 20,
                    bottom: 16,
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
                        'ASSINATURAS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2A4A),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!repository.carregando) ...[
                        const SizedBox(height: 8),

                        // US02 — Painel Consolidado de Gastos
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC8CEDC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'RESUMO DOS GASTOS',
                                style: TextStyle(
                                  color: Color(0xFF1B2A4A),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Total mensal estimado',
                                style: TextStyle(
                                  color: Color(0xFF1B2A4A),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'R\$ $totalMensal',
                                style: const TextStyle(
                                  color: Color(0xFF1B2A4A),
                                  fontSize: 27,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(
                                color: Color(0xFF9BA9BE),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.subscriptions_outlined,
                                    color: Color(0xFF1B2A4A),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${assinaturas.length} assinatura(s) cadastrada(s)',
                                      style: const TextStyle(
                                        color: Color(0xFF1B2A4A),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.event_outlined,
                                    color: Color(0xFF1B2A4A),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      proximoVencimento == null
                                          ? 'Nenhum vencimento cadastrado'
                                          : 'Próximo vencimento: ${_dataFormatada(proximoVencimento)}',
                                      style: const TextStyle(
                                        color: Color(0xFF1B2A4A),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      if (repository.carregando)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF1B2A4A),
                            ),
                          ),
                        )
                      else ...[
                        if (assinaturas.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Você ainda não possui assinaturas cadastradas.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF1B2A4A),
                                fontSize: 13,
                              ),
                            ),
                          ),

                        ...assinaturas.map(
                              (item) => _cardAssinatura(context, item),
                        ),

                        const SizedBox(height: 10),

                        // Botão para adicionar assinatura
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () async {
                              final novaAssinatura =
                              await Navigator.push<AssinaturaModel>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const CadastroAssinaturaPagina(),
                                ),
                              );

                              if (novaAssinatura != null) {
                                // O formulário já salva a assinatura no backend.
                                // Aqui apenas recarregamos a lista para evitar duplicar o POST.
                                await repository.carregarAssinaturas();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1B2A4A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Text(
                              'ADICIONAR NOVA ASSINATURA',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _cardAssinatura(
      BuildContext context,
      AssinaturaModel item,
      ) {
    final dataStr = _dataFormatada(item.dataVencimento);
    final valorStr = item.valor.toStringAsFixed(2).replaceAll('.', ',');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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
              GestureDetector(
                onTap: () async {
                  final bool? foiExcluido = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalhesAssinaturaPagina(
                        assinatura: item,
                      ),
                    ),
                  );

                  if (foiExcluido == true) {
                    await AssinaturasRepository.instance
                        .removerAssinatura(item.id);
                  }
                },
                child: const Text(
                  'VER DETALHES',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icone,
                  color: item.corIcone,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'R\$ $valorStr/mês',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2A4A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Plano: ${item.plano}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF1B2A4A),
                      ),
                    ),
                    Text(
                      'Vencimento: $dataStr',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF1B2A4A),
                      ),
                    ),
                    Text(
                      'Próxima Cobrança: R\$ $valorStr',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2A4A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
