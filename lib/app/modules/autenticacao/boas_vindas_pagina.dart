
import 'package:flutter/material.dart';
import '../../core/theme/tema_app.dart';
import '../../core/services/notificacao_service.dart';
import 'login_pagina.dart';

class BoasVindasPagina extends StatefulWidget {
  const BoasVindasPagina({super.key});

  @override
  State<BoasVindasPagina> createState() => _BoasVindasPaginaState();
}

class _BoasVindasPaginaState extends State<BoasVindasPagina> {
  bool _testandoNotificacao = false;

  void _irParaLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPagina()),
    );
  }

  Future<void> _testarNotificacao() async {
    if (_testandoNotificacao) return;

    setState(() => _testandoNotificacao = true);

    try {
      await NotificacaoService.instance.inicializar();

      final permitida =
      await NotificacaoService.instance.solicitarPermissao();

      if (!mounted) return;

      if (!permitida) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permita as notificações nas configurações do Android.',
            ),
          ),
        );
        return;
      }

      await NotificacaoService.instance.mostrarNotificacaoDeTeste();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificação enviada! Confira o emulador.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao testar notificação: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _testandoNotificacao = false);
      }
    }
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
                const Padding(
                  padding: EdgeInsets.only(bottom: 48.0),
                  child: Text(
                    'Toque para continuar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                    ),
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
