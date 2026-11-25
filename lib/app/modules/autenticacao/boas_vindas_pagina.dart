import 'package:flutter/material.dart';
import '../../core/theme/tema_app.dart';
import '../../data/repositories/usuario_repository.dart';
import '../home/pagina_inicial.dart';
import 'login_pagina.dart';

class BoasVindasPagina extends StatefulWidget {
  const BoasVindasPagina({super.key});

  @override
  State<BoasVindasPagina> createState() => _BoasVindasPaginaState();
}

class _BoasVindasPaginaState extends State<BoasVindasPagina> {
  bool _verificandoSessao = true;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _checarSessaoAutomatica();
  }

  Future<void> _checarSessaoAutomatica() async {
    setState(() {
      _verificandoSessao = true;
      _mensagemErro = null;
    });

    final resultado =
        await UsuarioRepository.instance.verificarERestaurarSessao();

    if (!mounted) return;

    switch (resultado) {
      case ResultadoRestauraSessao.sucesso:
        debugPrint('FLUXO INICIALIZAÇÃO: Sessão restaurada com sucesso. Direcionando para PaginaInicial.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PaginaInicial()),
        );
        break;

      case ResultadoRestauraSessao.acessoProibido:
        setState(() {
          _verificandoSessao = false;
          _mensagemErro =
              'Acesso não autorizado ao servidor (HTTP 403). Verifique suas permissões ou tente novamente.';
        });
        break;

      case ResultadoRestauraSessao.servidorIndisponivel:
        setState(() {
          _verificandoSessao = false;
          _mensagemErro =
              'Servidor indisponível ou sem conexão com a internet. Seu token foi preservado.';
        });
        break;

      case ResultadoRestauraSessao.naoAutorizado:
        setState(() {
          _verificandoSessao = false;
          _mensagemErro = null;
        });
        break;
    }
  }

  void _irParaLogin() {
    if (_verificandoSessao) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPagina()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _irParaLogin,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                TemaApp.corFundo,
                Color(0xFF8BA5C2),
                Color(0xFF325983),
              ],
              stops: [0.0, 0.65, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 48.0, left: 24, right: 24),
                  child: Column(
                    children: [
                      if (_verificandoSessao) ...[
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Verificando autenticação...',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ] else if (_mensagemErro != null) ...[
                        Text(
                          _mensagemErro!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _checarSessaoAutomatica,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Tentar Novamente'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TemaApp.corBotao,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _irParaLogin,
                          child: const Text(
                            'Ir para o Login',
                            style: TextStyle(
                              color: Colors.white70,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Toque para continuar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
