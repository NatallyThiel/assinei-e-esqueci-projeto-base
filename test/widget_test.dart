import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:assinei_e_esqueci/main.dart';

void main() {
  testWidgets('AssineiEEsqueciApp Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(const AssineiEEsqueciApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
