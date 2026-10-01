import 'package:flutter/material.dart';
import '../../core/theme/tema_app.dart';
import '../perfil/perfil_pagina.dart';

class RegistroPagina extends StatefulWidget {
  const RegistroPagina({super.key});

  @override
  State<RegistroPagina> createState() => _RegistroPaginaState();
}

class _RegistroPaginaState extends State<RegistroPagina> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _controleNome = TextEditingController();
  final _controleCpf = TextEditingController();
  final _controleEmail = TextEditingController();
  final _controleSenha = TextEditingController();
  final _controleConfirmarSenha = TextEditingController();

  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;
  bool _carregando = false;

  void _registrarUsuario() async {
    if (_chaveFormulario.currentState!.validate()) {
      setState(() => _carregando = true);

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _carregando = false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PerfilPagina(
              nomeInicial: _controleNome.text,
              emailInicial: _controleEmail.text,
              cpfInicial: _controleCpf.text,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controleNome.dispose();
    _controleCpf.dispose();
    _controleEmail.dispose();
    _controleSenha.dispose();
    _controleConfirmarSenha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: Form(
                key: _chaveFormulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Criar conta',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: TemaApp.corBotao,
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _controleNome,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(color: TemaApp.corBotao),
                      decoration: const InputDecoration(
                        hintText: 'Nome completo',
                        hintStyle: TextStyle(color: Color(0xFF64748B)),
                        prefixIcon: Icon(Icons.person_outline, color: TemaApp.corBotao),
                        filled: false,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao, width: 2),
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe o seu nome completo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _controleCpf,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: TemaApp.corBotao),
                      decoration: const InputDecoration(
                        hintText: 'CPF',
                        hintStyle: TextStyle(color: Color(0xFF64748B)),
                        prefixIcon: Icon(Icons.badge_outlined, color: TemaApp.corBotao),
                        filled: false,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao, width: 2),
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe o seu CPF';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _controleEmail,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: TemaApp.corBotao),
                      decoration: const InputDecoration(
                        hintText: 'E-mail',
                        hintStyle: TextStyle(color: Color(0xFF64748B)),
                        prefixIcon: Icon(Icons.mark_email_read_outlined, color: TemaApp.corBotao),
                        filled: false,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao, width: 2),
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.trim().isEmpty) {
                          return 'Informe o seu e-mail';
                        }
                        if (!valor.contains('@')) {
                          return 'Informe um e-mail válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _controleSenha,
                      obscureText: !_senhaVisivel,
                      style: const TextStyle(color: TemaApp.corBotao),
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        hintStyle: const TextStyle(color: Color(0xFF64748B)),
                        prefixIcon: const Icon(Icons.lock_outline, color: TemaApp.corBotao),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaVisivel ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: TemaApp.corBotao,
                          ),
                          onPressed: () {
                            setState(() {
                              _senhaVisivel = !_senhaVisivel;
                            });
                          },
                        ),
                        filled: false,
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao, width: 2),
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'Informe uma senha';
                        }
                        if (valor.length < 6) {
                          return 'A senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _controleConfirmarSenha,
                      obscureText: !_confirmarSenhaVisivel,
                      style: const TextStyle(color: TemaApp.corBotao),
                      decoration: InputDecoration(
                        hintText: 'Confirmar senha',
                        hintStyle: const TextStyle(color: Color(0xFF64748B)),
                        prefixIcon: const Icon(Icons.lock_outline, color: TemaApp.corBotao),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmarSenhaVisivel ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: TemaApp.corBotao,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmarSenhaVisivel = !_confirmarSenhaVisivel;
                            });
                          },
                        ),
                        filled: false,
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao, width: 2),
                        ),
                      ),
                      validator: (valor) {
                        if (valor != _controleSenha.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _registrarUsuario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TemaApp.corBotao,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 4,
                        ),
                        child: _carregando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Cadastrar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Já tem uma conta? ',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(
                              color: TemaApp.corBotao,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}