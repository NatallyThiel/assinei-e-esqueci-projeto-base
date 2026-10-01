import 'package:flutter/material.dart';
import 'app/core/theme/tema_app.dart';
import 'app/modules/autenticacao/boas_vindas_pagina.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AssineiEEsqueciApp());
}

class AssineiEEsqueciApp extends StatelessWidget {
  const AssineiEEsqueciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assinei & Esqueci',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.temaClaro,
      home: const BoasVindasPagina(),
    );
  }
}