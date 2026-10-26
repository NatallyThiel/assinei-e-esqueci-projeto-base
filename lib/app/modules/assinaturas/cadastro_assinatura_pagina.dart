import 'package:flutter/material.dart';

import '../../data/models/assinatura_model.dart';
import '../../data/repositories/assinatura_repository.dart';

class CadastroAssinaturaPagina extends StatefulWidget {
  const CadastroAssinaturaPagina({super.key});

  @override
  State<CadastroAssinaturaPagina> createState() =>
      _CadastroAssinaturaPaginaState();
}

class _CadastroAssinaturaPaginaState
    extends State<CadastroAssinaturaPagina> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _planoController = TextEditingController();
  final _valorController = TextEditingController();
  final _plataformaController = TextEditingController();

  DateTime? _dataVencimentoSelecionada;

  String _metodoPagamento = 'Cartão de Crédito';

  bool _lembreteAtivo = true;
  bool _testeGratis = false;
  bool _salvando = false;

  final List<String> _metodosPagamento = [
    'Cartão de Crédito',
    'Cartão de Débito',
    'Pix',
    'Boleto',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _planoController.dispose();
    _valorController.dispose();
    _plataformaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? selecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1B2A4A),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1B2A4A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selecionada != null) {
      setState(() {
        _dataVencimentoSelecionada = selecionada;
      });
    }
  }

  Future<void> _salvarAssinatura() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataVencimentoSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, selecione uma data de vencimento.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final valorTexto = _valorController.text
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '.');

    final valor = double.tryParse(valorTexto);

    if (valor == null || valor < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um valor válido.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    final novaAssinatura = AssinaturaModel(
      id: '',
      nome: _nomeController.text.trim(),
      valor: valor,
      dataVencimento: _dataVencimentoSelecionada!,
      metodoPagamento: _metodoPagamento,
      plano: _planoController.text.trim().isEmpty
          ? 'Plano Padrão'
          : _planoController.text.trim(),
      plataforma: _plataformaController.text.trim(),
      testeGratis: _testeGratis,
    );

    try {
      await AssinaturasRepository.instance
          .adicionarAssinatura(novaAssinatura);

      if (!mounted) return;

      await AssinaturasRepository.instance.carregarAssinaturas();

      if (!mounted) return;

      final assinaturas =
          AssinaturasRepository.instance.assinaturas;

      final encontrada = assinaturas.where(
            (item) =>
        item.nome == novaAssinatura.nome &&
            item.valor == novaAssinatura.valor &&
            item.dataVencimento.year ==
                novaAssinatura.dataVencimento.year &&
            item.dataVencimento.month ==
                novaAssinatura.dataVencimento.month &&
            item.dataVencimento.day ==
                novaAssinatura.dataVencimento.day,
      );

      if (encontrada.isNotEmpty) {
        final assinaturaSalva = encontrada.first;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assinatura salva no servidor!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, assinaturaSalva);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível confirmar o cadastro no servidor. '
                  'Confira o log do backend e a conexão.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar a assinatura: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF1B2A4A),
                          size: 28,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Image.asset(
                        'assets/images/logo.png',
                        height: 38,
                        errorBuilder:
                            (context, error, stackTrace) {
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'NOVA ASSINATURA',
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
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC8CEDC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'INFORMAÇÕES DA ASSINATURA',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),

                          const SizedBox(height: 14),

                          _campoTexto(
                            label: 'Nome do Serviço',
                            hint: 'Ex: Netflix, Spotify, Disney+',
                            controller: _nomeController,
                            validator: (valor) {
                              if (valor == null ||
                                  valor.trim().isEmpty) {
                                return 'Informe o nome do serviço';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          _campoTexto(
                            label: 'Plano (Opcional)',
                            hint: 'Ex: Premium, Individual, Família',
                            controller: _planoController,
                          ),

                          const SizedBox(height: 12),

                          _campoTexto(
                            label: 'Valor Mensal (R\$)',
                            hint: 'Ex: 29,90',
                            controller: _valorController,
                            keyboardType:
                            const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (valor) {
                              if (valor == null ||
                                  valor.trim().isEmpty) {
                                return 'Informe o valor';
                              }

                              final normalizado = valor
                                  .trim()
                                  .replaceAll('.', '')
                                  .replaceAll(',', '.');

                              final numero =
                              double.tryParse(normalizado);

                              if (numero == null || numero < 0) {
                                return 'Digite um valor válido';
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          _campoTexto(
                            label:
                            'Plataforma de contratação (opcional)',
                            hint:
                            'Ex: Google Play, App Store, site do serviço',
                            controller: _plataformaController,
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Data do Próximo Vencimento',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),

                          const SizedBox(height: 6),

                          InkWell(
                            onTap: () =>
                                _selecionarData(context),
                            borderRadius:
                            BorderRadius.circular(10),
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.black26,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _dataVencimentoSelecionada ==
                                        null
                                        ? 'Selecionar data'
                                        : '${_dataVencimentoSelecionada!.day.toString().padLeft(2, '0')}/'
                                        '${_dataVencimentoSelecionada!.month.toString().padLeft(2, '0')}/'
                                        '${_dataVencimentoSelecionada!.year}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                      _dataVencimentoSelecionada ==
                                          null
                                          ? Colors.black38
                                          : const Color(
                                        0xFF1B2A4A,
                                      ),
                                      fontWeight:
                                      _dataVencimentoSelecionada ==
                                          null
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Color(0xFF1B2A4A),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Método de Pagamento',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),

                          const SizedBox(height: 6),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.black26,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _metodoPagamento,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFF1B2A4A),
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF1B2A4A),
                                  fontWeight: FontWeight.bold,
                                ),
                                items: _metodosPagamento.map(
                                      (metodo) {
                                    return DropdownMenuItem<String>(
                                      value: metodo,
                                      child: Text(metodo),
                                    );
                                  },
                                ).toList(),
                                onChanged: (novoValor) {
                                  if (novoValor != null) {
                                    setState(() {
                                      _metodoPagamento = novoValor;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Ativar Alerta de Lembrete',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B2A4A),
                                  ),
                                ),
                              ),
                              Switch(
                                value: _lembreteAtivo,
                                activeColor:
                                const Color(0xFF1B2A4A),
                                onChanged: (val) {
                                  setState(() {
                                    _lembreteAtivo = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'É um teste grátis?',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2A4A),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<bool>(
                          value: _testeGratis,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF1B2A4A),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1B2A4A),
                            fontWeight: FontWeight.bold,
                          ),
                          items: const [
                            DropdownMenuItem<bool>(
                              value: false,
                              child: Text('Não'),
                            ),
                            DropdownMenuItem<bool>(
                              value: true,
                              child: Text('Sim'),
                            ),
                          ],
                          onChanged: (novoValor) {
                            if (novoValor != null) {
                              setState(() {
                                _testeGratis = novoValor;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _salvando
                            ? null
                            : _salvarAssinatura,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(0xFF1B2A4A),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 2,
                        ),
                        child: _salvando
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'CADASTRAR ASSINATURA',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoTexto({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2A4A),
          ),
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF1B2A4A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 12,
              color: Colors.black38,
            ),
            fillColor: Colors.white,
            filled: true,
            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Colors.black26),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Colors.black26),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF1B2A4A),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}