
import 'package:flutter/material.dart';

import '../../data/models/assinatura_model.dart';
import '../../data/repositories/assinatura_repository.dart';
import '../../data/repositories/cartao_repository.dart';
import 'editar_assinatura_pagina.dart';
import '../home/detalhes_cancelamento_pagina.dart';

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

class _DetalhesAssinaturaPaginaState
    extends State<DetalhesAssinaturaPagina> {
  final AssinaturasRepository _repository =
      AssinaturasRepository.instance;

  late AssinaturaModel? _assinaturaAtual;

  bool _atualizandoNotificacao = false;
  bool _excluindo = false;

  @override
  void initState() {
    super.initState();
    _assinaturaAtual = widget.assinatura;
  }

  String _obterNomeCategoria(String chave) {
    const categorias = {
      'ENTRETENIMENTO': 'Entretenimento',
      'MUSICA': 'Música',
      'SOFTWARE': 'Software',
      'JOGOS': 'Jogos',
      'EDUCACAO': 'Educação',
      'SAUDE_BEM_ESTAR': 'Saúde e bem-estar',
      'COMPRAS': 'Compras',
      'OUTROS': 'Outros',
    };
    return categorias[chave] ?? chave;
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _calcularDiasVencimento(DateTime vencimento) {
    final hoje = DateTime.now();

    final dataHoje = DateTime(
      hoje.year,
      hoje.month,
      hoje.day,
    );

    final dataVencimento = DateTime(
      vencimento.year,
      vencimento.month,
      vencimento.day,
    );

    final diferenca = dataVencimento.difference(dataHoje).inDays;

    if (diferenca < 0) {
      return 'venceu há ${-diferenca} dia(s)';
    }

    if (diferenca == 0) {
      return 'vence hoje';
    }

    if (diferenca == 1) {
      return 'vence amanhã';
    }

    return 'em $diferenca dias';
  }

  String _formatarValor(double valor) {
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _obterHorarioAlerta(AssinaturaModel item) {
    final horario = item.horarioAlerta.trim();

    if (horario.isEmpty) {
      return 'Não definido';
    }

    return horario;
  }

  void _mostrarMensagem(
      String mensagem, {
        bool erro = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro
            ? Colors.redAccent
            : const Color(0xFF1B2A4A),
      ),
    );
  }

  void _voltarDaPagina() {
    if (widget.onVoltar != null) {
      widget.onVoltar!();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _atualizarAssinaturaLocal() async {
    final item = _assinaturaAtual;

    if (item == null) return;

    await _repository.carregarAssinaturas();

    if (!mounted) return;

    final atualizada = _repository.assinaturas.where(
          (assinatura) => assinatura.id == item.id,
    );

    if (atualizada.isNotEmpty) {
      setState(() {
        _assinaturaAtual = atualizada.first;
      });
    }
  }

  Future<void> _abrirEdicao() async {
    final item = _assinaturaAtual;

    if (item == null) return;

    final resultado = await Navigator.push<AssinaturaModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EditarAssinaturaPagina(
          assinatura: item,
        ),
      ),
    );

    if (!mounted) return;

    if (resultado != null) {
      setState(() {
        _assinaturaAtual = resultado;
      });

      await _atualizarAssinaturaLocal();
    }
  }

  Future<void> _abrirCancelamento() async {
    final item = _assinaturaAtual;

    if (item == null) return;

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesCancelamentoPagina(
          assinatura: item,
        ),
      ),
    );

    if (!mounted) return;

    await _atualizarAssinaturaLocal();

    if (!mounted) return;

    if (resultado == true) {
      if (widget.onVoltar != null) {
        widget.onVoltar!();
      } else {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _alternarNotificacao() async {
    if (_atualizandoNotificacao) return;

    final item = _assinaturaAtual;

    if (item == null) return;

    setState(() {
      _atualizandoNotificacao = true;
    });

    try {
      final novaAssinatura = item.copyWith(
        notificacaoAtivada: !item.notificacaoAtivada,
      );

      final sucesso = await _repository.atualizarAssinatura(
        novaAssinatura,
      );

      if (!mounted) return;

      if (sucesso) {
        setState(() {
          _assinaturaAtual = novaAssinatura;
        });

        _mostrarMensagem(
          novaAssinatura.notificacaoAtivada
              ? 'Notificações ativadas!'
              : 'Notificações desativadas!',
        );

        await _atualizarAssinaturaLocal();
      } else {
        _mostrarMensagem(
          'Não foi possível atualizar a notificação.',
          erro: true,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Erro ao atualizar notificação: $e');
      debugPrint('$stackTrace');

      _mostrarMensagem(
        'Ocorreu um erro ao atualizar a notificação.',
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _atualizandoNotificacao = false;
        });
      }
    }
  }

  Future<void> _confirmarExclusao() async {
    if (_excluindo) return;

    final item = _assinaturaAtual;

    if (item == null) return;

    final confirmar = await showDialog<bool>(
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
            'Tem certeza que deseja excluir a assinatura de '
                '"${item.nome}"? Essa ação não poderá ser desfeita.',
            style: const TextStyle(
              color: Color(0xFF1B2A4A),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
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
                Navigator.pop(ctx, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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

    if (!mounted || confirmar != true) return;

    setState(() {
      _excluindo = true;
    });

    try {
      await _repository.removerAssinatura(item.id);

      // Confirma a exclusão consultando novamente o backend.
      await _repository.carregarAssinaturas();

      if (!mounted) return;

      final aindaExiste = _repository.assinaturas.any(
            (assinatura) => assinatura.id == item.id,
      );

      if (!aindaExiste) {
        _mostrarMensagem(
          'Assinatura "${item.nome}" excluída com sucesso!',
        );

        if (widget.onVoltar != null) {
          widget.onVoltar!();
        } else {
          Navigator.pop(context, true);
        }
      } else {
        _mostrarMensagem(
          'Não foi possível excluir a assinatura.',
          erro: true,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Erro ao excluir assinatura: $e');
      debugPrint('$stackTrace');

      _mostrarMensagem(
        'Ocorreu um erro ao excluir a assinatura.',
        erro: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _excluindo = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _assinaturaAtual;

    if (item == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFD3D3D3),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.subscriptions_outlined,
                  size: 60,
                  color: Color(0xFF1B2A4A),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nenhuma assinatura encontrada.',
                  style: TextStyle(
                    color: Color(0xFF1B2A4A),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _voltarDaPagina,
                  child: const Text('VOLTAR'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final valorFormatado = _formatarValor(item.valor);
    final dataFormatada = _formatarData(item.dataVencimento);
    final diasVencimento =
    _calcularDiasVencimento(item.dataVencimento);

    return Scaffold(
      backgroundColor: const Color(0xFFD3D3D3),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabeçalho
            Container(
              padding: const EdgeInsets.only(
                top: 50,
                left: 16,
                right: 16,
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
                        onPressed: _voltarDaPagina,
                      ),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 38,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text(
                            'Assinei\n& Esqueci',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 48),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Card 1: Resumo da assinatura
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
                        _linhaInfo('CATEGORIA:', _obterNomeCategoria(item.categoria)),
                        _linhaInfo(
                          'VALOR:',
                          'R\$ $valorFormatado',
                        ),
                        _linhaInfo(
                          'VENCIMENTO:',
                          '$dataFormatada ($diasVencimento)',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Botão editar assinatura
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton(
                      onPressed: _abrirEdicao,
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

                  // Card 2: Método de pagamento
                  ListenableBuilder(
                    listenable: CartaoRepository.instance,
                    builder: (context, child) {
                      final cartaoVinculado =
                      CartaoRepository.instance.obterCartaoPorId(
                        item.cartaoId,
                      );

                      final rotuloMetodo =
                      item.metodoPagamento.toUpperCase();

                      final detalheCartao = cartaoVinculado != null
                          ? '${cartaoVinculado.nome} '
                          '(${cartaoVinculado.bandeira} '
                          '•••• ${cartaoVinculado.ultimosDigitos})'
                          : 'Nenhum cartão específico vinculado';

                      final corBgIcone =
                          cartaoVinculado?.cor ??
                              const Color(0xFF1B2A4A);

                      return _construirCardBase(
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
                                    color: corBgIcone,
                                    borderRadius:
                                    BorderRadius.circular(6),
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
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rotuloMetodo,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B2A4A),
                                        ),
                                      ),
                                      Text(
                                        detalheCartao,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: OutlinedButton(
                                onPressed: _abrirEdicao,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                  const Color(0xFF1B2A4A),
                                  side: const BorderSide(
                                    color: Color(0xFF1B2A4A),
                                    width: 1.5,
                                  ),
                                  shape: const StadiumBorder(),
                                ),
                                child: const Text(
                                  'ALTERAR MÉTODO / CARTÃO',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // Card 3: Status do lembrete
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
                        _linhaInfo(
                          'ALERTA DEFINIDO PARA:',
                          '${_formatarData(item.dataVencimento)} '
                              'ÀS ${_obterHorarioAlerta(item)}',
                        ),
                        _linhaInfo(
                          'NOTIFICAÇÃO:',
                          item.notificacaoAtivada
                              ? 'Ativada'
                              : 'Desativada',
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 36,
                          child: OutlinedButton(
                            onPressed: _atualizandoNotificacao
                                ? null
                                : _alternarNotificacao,
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                              const Color(0xFF1B2A4A),
                              side: const BorderSide(
                                color: Color(0xFF1B2A4A),
                                width: 1.5,
                              ),
                              shape: const StadiumBorder(),
                            ),
                            child: _atualizandoNotificacao
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : Text(
                              item.notificacaoAtivada
                                  ? 'DESATIVAR ALERTA'
                                  : 'ATIVAR ALERTA',
                              style: const TextStyle(
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
                      'AVISO: Suas informações são protegidas de acordo '
                          'com nossa Política de Privacidade. Algumas '
                          'alterações podem levar até 24h para serem '
                          'processadas.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botão cancelar assinatura
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _abrirCancelamento,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1B2A4A),
                        side: const BorderSide(
                          color: Color(0xFF1B2A4A),
                          width: 1.5,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'CANCELAR ASSINATURA',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botão excluir assinatura
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _excluindo
                          ? null
                          : _confirmarExclusao,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 2,
                      ),
                      child: _excluindo
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
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

  Widget _construirCardBase({
    required Widget child,
  }) {
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
      padding: const EdgeInsets.only(bottom: 3),
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
