import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/core/theme/tema_app.dart';
import 'app/core/services/notificacao_service.dart';
import 'app/data/repositories/usuario_repository.dart';
import 'app/modules/autenticacao/login_pagina.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa os dados de localização em português.
  await initializeDateFormatting('pt_BR', null);

  await NotificacaoService.instance.inicializar();

  // Garante a limpeza de qualquer token armazenado na inicialização
  await UsuarioRepository.instance.logout();

  runApp(const AssineiEEsqueciApp());
}

class AssineiEEsqueciApp extends StatefulWidget {
  const AssineiEEsqueciApp({super.key});

  @override
  State<AssineiEEsqueciApp> createState() => _AssineiEEsqueciAppState();
}

class _AssineiEEsqueciAppState extends State<AssineiEEsqueciApp> {
  @override
  void initState() {
    super.initState();
    UsuarioRepository.instance.sessaoExpiradaNotifier
        .addListener(_tratarSessaoExpirada);
  }

  @override
  void dispose() {
    UsuarioRepository.instance.sessaoExpiradaNotifier
        .removeListener(_tratarSessaoExpirada);
    super.dispose();
  }

  void _tratarSessaoExpirada() {
    if (UsuarioRepository.instance.sessaoExpiradaNotifier.value) {
      UsuarioRepository.instance.sessaoExpiradaNotifier.value = false;

      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sessão expirada. Faça login novamente.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPagina()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Assinei & Esqueci',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.temaClaro,
      home: const LoginPagina(),
    );
  }
}
