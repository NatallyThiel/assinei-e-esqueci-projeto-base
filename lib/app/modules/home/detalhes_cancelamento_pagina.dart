
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/assinatura_model.dart';
import '../../data/repositories/assinatura_repository.dart';
import '../../data/services/biometria_service.dart';

class DetalhesCancelamentoPagina extends StatefulWidget {
  final AssinaturaModel assinatura;

  const DetalhesCancelamentoPagina({
    super.key,
    required this.assinatura,
  });

  @override
  State<DetalhesCancelamentoPagina> createState() =>
      _DetalhesCancelamentoPaginaState();
}

class _DetalhesCancelamentoPaginaState
    extends State<DetalhesCancelamentoPagina> {
  final BiometriaService _biometriaService = BiometriaService();

  bool _processando = false;

  Future<void> _abrirUrlCancelamento(String url) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir o link: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao abrir link: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _iniciarProcessoCancelamento() async {
    if (_processando) return;

    final confirmou = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFC8CEDC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Solicitar Cancelamento?',
          style: TextStyle(
            color: Color(0xFF1B2A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Deseja iniciar a solicitação de cancelamento de '
              '${widget.assinatura.nome}?\n\n'
              'Sua identidade será confirmada via biometria local '
              'antes de registrar o pedido.',
          style: const TextStyle(
            color: Color(0xFF1B2A4A),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('VOLTAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B2A4A),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );

    if (!mounted || confirmou != true) return;

    setState(() => _processando = true);

    try {
      final autenticado = await _biometriaService.autenticar(
        motivo: 'Confirme sua identidade para solicitar o cancelamento.',
      );

      if (!mounted) return;

      if (!autenticado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Biometria não confirmada. '
                  'O processo de cancelamento foi suspenso.',
            ),
            backgroundColor: Color(0xFFB71C1C),
          ),
        );

        return;
      }

      final sucesso =
      await AssinaturasRepository.instance.atualizarStatusCancelamento(
        widget.assinatura.id,
        StatusCancelamento.cancelRequested,
      );

      if (!mounted) return;

      if (!sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível registrar a solicitação. '
                  'Verifique sua conexão e tente novamente.',
            ),
            backgroundColor: Colors.red,
          ),
        );

        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Solicitação de cancelamento registrada! '
                'Siga as instruções abaixo.',
          ),
          backgroundColor: Color(0xFF1B2A4A),
        ),
      );

      final url = widget.assinatura.urlCancelamento;

      if (url != null && url.isNotEmpty) {
        await _abrirUrlCancelamento(url);
      }
    } catch (e, stackTrace) {
      debugPrint('ERRO NO PROCESSO DE CANCELAMENTO: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível concluir a solicitação. Tente novamente.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  Future<void> _atualizarStatus(
      String novoStatus,
      String mensagem,
      ) async {
    if (_processando) return;

    setState(() => _processando = true);

    try {
      final sucesso =
      await AssinaturasRepository.instance.atualizarStatusCancelamento(
        widget.assinatura.id,
        novoStatus,
      );

      if (!mounted) return;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensagem),
            backgroundColor: const Color(0xFF1B2A4A),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível atualizar o status. Tente novamente.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('ERRO AO ATUALIZAR STATUS: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível atualizar o status. Tente novamente.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  Widget _linhaPasso({
    required int numero,
    required String titulo,
    required String descricao,
    required bool concluido,
    required bool emAndamento,
  }) {
    final color = concluido
        ? Colors.green.shade700
        : emAndamento
        ? Colors.amber.shade900
        : Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color,
            child: Text(
              '$numero',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  descricao,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = AssinaturasRepository.instance;

    return ListenableBuilder(
      listenable: repository,
      builder: (context, child) {
        final item = repository.assinaturas.firstWhere(
              (a) => a.id == widget.assinatura.id,
          orElse: () => widget.assinatura,
        );

        final status = item.statusCancelamento;

        final valorFormatado =
        item.valor.toStringAsFixed(2).replaceAll('.', ',');

        final bool isCancelado =
            status == StatusCancelamento.cancelled;

        final bool isSolicitado =
            status == StatusCancelamento.cancelRequested ||
                status == StatusCancelamento.awaitingConfirmation;

        final bool podeIniciar =
            status == StatusCancelamento.active ||
                status == StatusCancelamento.failed;

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
                            onPressed: _processando
                                ? null
                                : () => Navigator.pop(context),
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
                        'PROCESSO DE CANCELAMENTO',
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Resumo do Serviço
                      _cardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'SERVIÇO A CANCELAR:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B2A4A),
                              ),
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
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.nome.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B2A4A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'R\$ $valorFormatado',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Fluxo e Status do Processo
                      _cardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ANDAMENTO DO CANCELAMENTO:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B2A4A),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _linhaPasso(
                              numero: 1,
                              titulo: 'Confirmação Biométrica Local',
                              descricao:
                              'Confirmação de identidade para iniciar o pedido.',
                              concluido:
                              status != StatusCancelamento.active &&
                                  status != StatusCancelamento.failed,
                              emAndamento:
                              status == StatusCancelamento.active ||
                                  status == StatusCancelamento.failed,
                            ),
                            _linhaPasso(
                              numero: 2,
                              titulo: 'Solicitação do Pedido',
                              descricao:
                              'Acesso ao canal oficial ou envio de instrução de cancelamento.',
                              concluido:
                              status ==
                                  StatusCancelamento.awaitingConfirmation ||
                                  status == StatusCancelamento.cancelled,
                              emAndamento:
                              status ==
                                  StatusCancelamento.cancelRequested,
                            ),
                            _linhaPasso(
                              numero: 3,
                              titulo: 'Confirmação Final',
                              descricao:
                              'Validação final de que o serviço não gerará novas cobranças.',
                              concluido: isCancelado,
                              emAndamento:
                              status ==
                                  StatusCancelamento.awaitingConfirmation,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Link de cancelamento se existir
                      if (item.urlCancelamento != null &&
                          item.urlCancelamento!.isNotEmpty) ...[
                        _cardContainer(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CANAL OFICIAL DE CANCELAMENTO:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B2A4A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Clique abaixo para abrir a página oficial de cancelamento do serviço:',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: _processando
                                    ? null
                                    : () => _abrirUrlCancelamento(
                                  item.urlCancelamento!,
                                ),
                                icon: const Icon(
                                  Icons.open_in_new,
                                  size: 18,
                                ),
                                label: const Text(
                                  'ABRIR PÁGINA OFICIAL DE CANCELAMENTO',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2C436D),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(
                                    double.infinity,
                                    44,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Botões de Ação
                      if (podeIniciar) ...[
                        ElevatedButton.icon(
                          onPressed: _processando
                              ? null
                              : _iniciarProcessoCancelamento,
                          icon: const Icon(
                            Icons.fingerprint,
                            size: 22,
                          ),
                          label: _processando
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text(
                            status == StatusCancelamento.failed
                                ? 'TENTAR NOVAMENTE'
                                : 'CONFIRMAR E INICIAR CANCELAMENTO',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B2A4A),
                            minimumSize: const Size(
                              double.infinity,
                              48,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ] else if (isSolicitado) ...[
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: _processando
                                  ? null
                                  : () => _atualizarStatus(
                                        StatusCancelamento.cancelled,
                                        'Cancelamento confirmado com sucesso!',
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade800,
                                minimumSize: const Size(
                                  double.infinity,
                                  44,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              child: const Text(
                                'MARCAR COMO CANCELADO COM SUCESSO',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (status == StatusCancelamento.cancelRequested) ...[
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: _processando
                                    ? null
                                    : () => _atualizarStatus(
                                          StatusCancelamento.awaitingConfirmation,
                                          'Status alterado para Aguardando Confirmação.',
                                        ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF1B2A4A),
                                  ),
                                  minimumSize: const Size(
                                    double.infinity,
                                    44,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                                child: const Text(
                                  'AVANÇAR PARA AGUARDANDO CONFIRMAÇÃO',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B2A4A),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isCancelado
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCancelado
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                          child: Text(
                            isCancelado
                                ? 'Esta assinatura já está marcada como CANCELADA.'
                                : 'Status atual: FALHA NO CANCELAMENTO. Tente novamente ou abra o suporte.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isCancelado
                                  ? Colors.green.shade900
                                  : Colors.red.shade900,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
}
