import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestion_amasanderia/main.dart';

void main() {
  testWidgets('Carga de pantalla PoC SQLite', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PoCSQLiteScreen()));
    expect(find.textContaining('PoC SQLite'), findsOneWidget);
  });
}