import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/cartao_model.dart';
import '../../data/repositories/cartao_repository.dart';

class CadastroEdicaoCartaoPagina extends StatefulWidget {
  final CartaoModel? cartao;

  const CadastroEdicaoCartaoPagina({super.key, this.cartao});

  @override
  State<CadastroEdicaoCartaoPagina> createState() =>
      _CadastroEdicaoCartaoPaginaState();
}

class _CadastroEdicaoCartaoPaginaState
    extends State<CadastroEdicaoCartaoPagina> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _digitosController;

  String _bandeira = 'Visa';
  Color _corSelecionada = const Color(0xFF1B2A4A);
  bool _salvando = false;

  final List<String> _bandeiras = [
    'Visa',
    'Mastercard',
    'Elo',
    'American Express',
    'Outra',
  ];

  final List<Color> _coresDisponiveis = [
    const Color(0xFF1B2A4A), // Azul Escuro Padrão
    const Color(0xFF820AD1), // Roxo Nubank
    const Color(0xFF003399), // Azul Itaú
    const Color(0xFFCC0000), // Vermelho Bradesco
    const Color(0xFF00875A), // Verde Sicredi/Sicoob
    const Color(0xFF2C436D), // Azul Slate
    const Color(0xFF333333), // Grafite Black Card
  ];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.cartao?.nome ?? '');
    _digitosController =
        TextEditingController(text: widget.cartao?.ultimosDigitos ?? '');
    if (widget.cartao != null) {
      _bandeira = widget.cartao!.bandeira;
      _corSelecionada = widget.cartao!.cor;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _digitosController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final cartao = CartaoModel(
      id: widget.cartao?.id ?? '',
      usuarioId: widget.cartao?.usuarioId ?? '',
      nome: _nomeController.text.trim(),
      bandeira: _bandeira,
      ultimosDigitos: _digitosController.text.trim(),
      cor: _corSelecionada,
    );

    bool sucesso = false;
    if (widget.cartao == null) {
      sucesso = await CartaoRepository.instance.adicionarCartao(cartao);
    } else {
      sucesso = await CartaoRepository.instance.atualizarCartao(cartao);
    }

    if (!mounted) return;
    setState(() => _salvando = false);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.cartao == null
                ? 'Cartão cadastrado com sucesso!'
                : 'Cartão atualizado com sucesso!',
          ),
          backgroundColor: const Color(0xFF1B2A4A),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar o cartão.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.cartao != null;

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
                  Text(
                    isEdicao ? 'EDITAR CARTÃO' : 'NOVO CARTÃO',
                    style: const TextStyle(
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Aviso de Segurança
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.shield_outlined,
                              color: Color(0xFF1B2A4A), size: 24),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Segurança: Digite apenas os 4 últimos dígitos para identificação visual. Nunca informe número completo, CVV ou senhas.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF1B2A4A),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Formulário
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
                            'Nome de Identificação do Cartão',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nomeController,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF1B2A4A)),
                            decoration: InputDecoration(
                              hintText:
                                  'Ex: Nubank, Cartão Pessoal, Itaú Empresa',
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black26),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe um nome de identificação';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          const Text(
                            'Bandeira do Cartão',
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
                              child: DropdownButton<String>(
                                value: _bandeira,
                                isExpanded: true,
                                items: _bandeiras.map((b) {
                                  return DropdownMenuItem<String>(
                                    value: b,
                                    child: Text(b),
                                  );
                                }).toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => _bandeira = v);
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          const Text(
                            'Últimos 4 Dígitos do Cartão',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _digitosController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(4),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF1B2A4A)),
                            decoration: InputDecoration(
                              hintText: 'Ex: 1234',
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.black26),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().length != 4) {
                                return 'Informe exatamente os 4 últimos dígitos';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          const Text(
                            'Cor de Destaque Visual',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2A4A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _coresDisponiveis.map((cor) {
                              final selecionada =
                                  _corSelecionada.toARGB32() == cor.toARGB32();
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _corSelecionada = cor);
                                },
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: cor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selecionada
                                          ? Colors.white
                                          : Colors.transparent,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      if (selecionada)
                                        BoxShadow(
                                          color: Colors.black.withAlpha(50),
                                          blurRadius: 4,
                                        ),
                                    ],
                                  ),
                                  child: selecionada
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 20)
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _salvando ? null : _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B2A4A),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: _salvando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEdicao
                                  ? 'SALVAR ALTERAÇÕES'
                                  : 'CADASTRAR CARTÃO',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
}
