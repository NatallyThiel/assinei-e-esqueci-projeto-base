import 'package:flutter/material.dart';
import '../../core/theme/tema_app.dart';
import 'login_pagina.dart';

class BoasVindasPagina extends StatelessWidget {
  const BoasVindasPagina({super.key});

  void _irParaLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPagina()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => _irParaLogin(context),
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