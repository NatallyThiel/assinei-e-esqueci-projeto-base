import 'package:flutter/material.dart';

import '../../data/models/assinatura_model.dart';
import '../../data/repositories/assinatura_repository.dart';

class EditarAssinaturaPagina extends StatefulWidget {
  final AssinaturaModel assinatura;

  const EditarAssinaturaPagina({
    super.key,
    required this.assinatura,
  });

  @override
  State<EditarAssinaturaPagina> createState() =>
      _EditarAssinaturaPaginaState();
}

class _EditarAssinaturaPaginaState
    extends State<EditarAssinaturaPagina> {
  final _chaveFormulario = GlobalKey<FormState>();

  late TextEditingController _controleNome;
  late TextEditingController _controleValor;

  late DateTime _dataVencimento;

  late String _metodoPagamento;
  late String _plano;

  bool _salvando = false;

  final List<String> _metodosPagamento = [
    'Cartão de Crédito',
    'Cartão de Débito',
    'Pix',
    'Boleto',
    'Outro',
  ];

  final List<String> _planos = [
    'Plano Padrão',
    'Plano Básico',
    'Plano Premium',
    'Plano Família',
  ];

  @override
  void initState() {
    super.initState();

    final assinatura = widget.assinatura;

    _controleNome = TextEditingController(
      text: assinatura.nome,
    );

    _controleValor = TextEditingController(
      text: assinatura.valor.toStringAsFixed(2).replaceAll('.', ','),
    );

    _dataVencimento = assinatura.dataVencimento;

    _metodoPagamento = _metodosPagamento.contains(
      assinatura.metodoPagamento,
    )
        ? assinatura.metodoPagamento
        : _metodosPagamento.first;

    _plano = _planos.contains(assinatura.plano)
        ? assinatura.plano
        : _planos.first;
  }

  @override
  void dispose() {
    _controleNome.dispose();
    _controleValor.dispose();

    super.dispose();
  }

  Future<void> _selecionarData() async {
    final dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataVencimento,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data de vencimento',
      cancelText: 'CANCELAR',
      confirmText: 'CONFIRMAR',
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataVencimento = dataSelecionada;
      });
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  double? _converterValor(String valor) {
    final valorLimpo = valor
        .trim()
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(valorLimpo);
  }

  Future<void> _salvarAlteracoes() async {
    if (!_chaveFormulario.currentState!.validate()) {
      return;
    }

    final valor = _converterValor(_controleValor.text);

    if (valor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um valor válido.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      _salvando = true;
    });

    final assinaturaAtualizada = AssinaturaModel(
      id: widget.assinatura.id,
      nome: _controleNome.text.trim(),
      valor: valor,
      dataVencimento: _dataVencimento,
      metodoPagamento: _metodoPagamento,
      plano: _plano,
      icone: widget.assinatura.icone,
      corIcone: widget.assinatura.corIcone,
    );

    final sucesso =
    await AssinaturasRepository.instance.atualizarAssinatura(
      assinaturaAtualizada,
    );

    if (!mounted) return;

    setState(() {
      _salvando = false;
    });

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assinatura atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(
        context,
        assinaturaAtualizada,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível atualizar a assinatura.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF1B2A4A),
                          size: 28,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'EDITAR ASSINATURA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B2A4A),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Form(
                key: _chaveFormulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _construirCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DADOS DA ASSINATURA',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _campoTexto(
                            controller: _controleNome,
                            label: 'Nome do serviço',
                            icon: Icons.subscriptions_outlined,
                            validator: (valor) {
                              if (valor == null ||
                                  valor.trim().isEmpty) {
                                return 'Informe o nome do serviço';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          _campoTexto(
                            controller: _controleValor,
                            label: 'Valor mensal',
                            icon: Icons.attach_money,
                            keyboardType:
                            const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (valor) {
                              if (valor == null ||
                                  valor.trim().isEmpty) {
                                return 'Informe o valor';
                              }

                              if (_converterValor(valor) == null) {
                                return 'Informe um valor válido';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Data de vencimento',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),

                          const SizedBox(height: 6),

                          InkWell(
                            onTap: _selecionarData,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF1B2A4A),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: Color(0xFF1B2A4A),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _formatarData(_dataVencimento),
                                    style: const TextStyle(
                                      color: Color(0xFF1B2A4A),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          _construirDropdown(
                            titulo: 'Método de pagamento',
                            valor: _metodoPagamento,
                            itens: _metodosPagamento,
                            icone: Icons.credit_card_outlined,
                            onChanged: (valor) {
                              if (valor != null) {
                                setState(() {
                                  _metodoPagamento = valor;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 16),

                          _construirDropdown(
                            titulo: 'Plano',
                            valor: _plano,
                            itens: _planos,
                            icone: Icons.workspace_premium_outlined,
                            onChanged: (valor) {
                              if (valor != null) {
                                setState(() {
                                  _plano = valor;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                        _salvando ? null : _salvarAlteracoes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B2A4A),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 3,
                        ),
                        child: _salvando
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'SALVAR ALTERAÇÕES',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
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
                          'CANCELAR',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirCard({required Widget child}) {
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

  Widget _campoTexto({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Color(0xFF1B2A4A),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF1B2A4A),
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF1B2A4A),
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF1B2A4A),
          ),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF1B2A4A),
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF1B2A4A),
            width: 2,
          ),
        ),
      ),
      validator: validator,
    );
  }

  Widget _construirDropdown({
    required String titulo,
    required String valor,
    required List<String> itens,
    required IconData icone,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: valor,
      decoration: InputDecoration(
        labelText: titulo,
        labelStyle: const TextStyle(
          color: Color(0xFF1B2A4A),
        ),
        prefixIcon: Icon(
          icone,
          color: const Color(0xFF1B2A4A),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF1B2A4A),
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFF1B2A4A),
            width: 2,
          ),
        ),
      ),
      dropdownColor: const Color(0xFFC8CEDC),
      style: const TextStyle(
        color: Color(0xFF1B2A4A),
        fontSize: 14,
      ),
      items: itens.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}