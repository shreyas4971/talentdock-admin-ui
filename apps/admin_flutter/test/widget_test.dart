import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_flutter/main.dart';
import 'package:admin_flutter/src/api_client.dart';

void main() {
  testWidgets('AdminApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const AdminApp(),
      ),
    );
    expect(find.byType(AdminApp), findsOneWidget);
  });
}

