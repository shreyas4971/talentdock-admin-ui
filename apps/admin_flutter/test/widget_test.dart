import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_flutter/main.dart';

void main() {
  testWidgets('AdminApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AdminApp()));
    expect(find.byType(AdminApp), findsOneWidget);
  });
}
