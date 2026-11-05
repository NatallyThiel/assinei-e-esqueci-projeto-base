
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/theme/tema_app.dart';
import '../../core/services/notificacao_service.dart';
import '../../data/repositories/usuario_repository.dart';
import '../../data/services/biometria_service.dart';
import '../home/pagina_inicial.dart';
import 'registro_pagina.dart';

class LoginPagina extends StatefulWidget {
  const LoginPagina({super.key});

  @override
  State<LoginPagina> createState() => _LoginPaginaState();
}

class _LoginPaginaState extends State<LoginPagina> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _controleEmail = TextEditingController();
  final _controleSenha = TextEditingController();

  final _biometria = BiometriaService();
  final _armazenamento = const FlutterSecureStorage();

  bool _senhaVisivel = false;
  bool _carregando = false;
  bool _biometriaDisponivel = false;
  bool _biometriaAtivada = false;

  static const _chaveBiometriaAtivada = 'biometria_ativada';
  static const _chaveEmail = 'email_biometria';

  @override
  void initState() {
    super.initState();
    _verificarBiometria();
  }

  Future<void> _verificarBiometria() async {
    final disponivel = await _biometria.biometriaDisponivel();

    final ativada =
        await _armazenamento.read(key: _chaveBiometriaAtivada) == 'true';

    debugPrint('BIOMETRIA DISPONÍVEL: $disponivel');
    debugPrint('BIOMETRIA ATIVADA: $ativada');

    if (!mounted) return;

    setState(() {
      _biometriaDisponivel = disponivel;
      _biometriaAtivada = disponivel && ativada;
    });
  }

  Future<void> _entrar() async {
    if (!_chaveFormulario.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final email = _controleEmail.text.trim();

      final sucesso = await UsuarioRepository.instance.login(
        email: email,
        senha: _controleSenha.text,
      );

      if (!mounted) return;

      if (sucesso) {
        debugPrint('LOGIN REALIZADO COM SUCESSO');

        await _oferecerBiometria(email);
        if (!mounted) return;

        try {
          await NotificacaoService.instance.inicializar();
          await NotificacaoService.instance.solicitarPermissao();
          await NotificacaoService.instance.mostrarNotificacaoDeTeste();

          debugPrint('Notificação imediata executada!');
        } catch (e, stackTrace) {
          debugPrint('Erro ao exibir notificação: $e');
          debugPrintStack(stackTrace: stackTrace);
        }

        if (!mounted) return;

        setState(() => _carregando = false);
        _abrirInicio();
      } else {
        setState(() => _carregando = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-mail ou senha incorretos.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _carregando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao entrar: $e')),
      );
    }
  }

  Future<void> _oferecerBiometria(String email) async {
    final jaAtivada =
        await _armazenamento.read(key: _chaveBiometriaAtivada) == 'true';

    if (jaAtivada || !_biometriaDisponivel || !mounted) return;

    final ativar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ativar biometria?'),
        content: const Text(
          'Deseja usar a impressão digital neste dispositivo '
              'para confirmar sua identidade em acessos futuros?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ativar'),
          ),
        ],
      ),
    );

    if (ativar != true) return;

    final autenticado = await _biometria.autenticar();
    if (!mounted) return;

    if (autenticado) {
      await _armazenamento.write(
        key: _chaveEmail,
        value: email,
      );

      await _armazenamento.write(
        key: _chaveBiometriaAtivada,
        value: 'true',
      );

      setState(() => _biometriaAtivada = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometria ativada neste dispositivo.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível confirmar a biometria.'),
        ),
      );
    }
  }

  Future<void> _entrarComBiometria() async {
    if (_carregando) return;

    setState(() => _carregando = true);

    try {
      final autenticado = await _biometria.autenticar();
      if (!mounted) return;

      if (!autenticado) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Autenticação biométrica cancelada ou não reconhecida.',
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Biometria confirmada. Entre com e-mail e senha para validar '
                'sua conta nesta versão.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _abrirInicio() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PaginaInicial()),
    );
  }

  void _abrirTelaRegistro() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegistroPagina()),
    );
  }

  @override
  void dispose() {
    _controleEmail.dispose();
    _controleSenha.dispose();
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
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              child: Form(
                key: _chaveFormulario,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: TemaApp.corBotao,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _controleEmail,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: TemaApp.corBotao),
                      decoration: const InputDecoration(
                        hintText: 'Seu email',
                        hintStyle: TextStyle(color: Color(0xFF64748B)),
                        prefixIcon: Icon(
                          Icons.mark_email_read_outlined,
                          color: TemaApp.corBotao,
                        ),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: TemaApp.corBotao,
                            width: 2,
                          ),
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _controleSenha,
                      obscureText: !_senhaVisivel,
                      style: const TextStyle(color: TemaApp.corBotao),
                      decoration: InputDecoration(
                        hintText: 'Sua senha',
                        hintStyle: const TextStyle(color: Color(0xFF64748B)),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: TemaApp.corBotao,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _senhaVisivel
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: TemaApp.corBotao,
                          ),
                          onPressed: () {
                            setState(() {
                              _senhaVisivel = !_senhaVisivel;
                            });
                          },
                        ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: TemaApp.corBotao),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: TemaApp.corBotao,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (valor) {
                        if (valor == null || valor.isEmpty) {
                          return 'Informe a sua senha';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _carregando ? null : _entrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TemaApp.corBotao,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          elevation: 4,
                        ),
                        child: _carregando
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    if (_biometriaDisponivel) ...[
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed:
                        _carregando ? null : _entrarComBiometria,
                        icon: const Icon(Icons.fingerprint),
                        label: Text(
                          _biometriaAtivada
                              ? 'Confirmar com biometria'
                              : 'Testar biometria',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70),
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Esqueceu a senha?',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Expanded(
                          child: Divider(color: Colors.white54, thickness: 1),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Ou entre com',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.white54, thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _botaoSocial(
                            child: const Text(
                              'G',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontFamily: 'serif',
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _botaoSocial(
                            child: const Icon(
                              Icons.apple,
                              size: 30,
                              color: Colors.black,
                            ),
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Não tem conta? ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: _abrirTelaRegistro,
                          child: const Text(
                            'Cadastrar-se',
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

  Widget _botaoSocial({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFD9D4D4),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
