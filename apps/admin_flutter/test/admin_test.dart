import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_flutter/src/api_client.dart';
import 'package:dio/dio.dart';

void main() {
  group('AdminApiClient Tests', () {
    test('Mock Mode login returns mock user and token', () async {
      final client = AdminApiClient(Dio());
      final res = await client.login('admin@talentdock.local', 'password');
      expect(res['token'], isNotNull);
      expect(res['user']['email'], 'admin@talentdock.local');
    });

    test('Mock Mode getPositions returns list', () async {
      final client = AdminApiClient(Dio());
      final positions = await client.getPositions();
      expect(positions.isNotEmpty, true);
    });

    test('Mock Mode getCandidateDetails returns details with documents', () async {
      final client = AdminApiClient(Dio());
      final details = await client.getCandidateDetails('cand-1');
      expect(details['candidate'], isNotNull);
      expect(details['documents'], isNotNull);
      final docs = details['documents'] as List<dynamic>;
      expect(docs.isNotEmpty, true);
    });

    test('Mock Mode downloadResumeBytes returns PDF magic bytes', () async {
      final client = AdminApiClient(Dio());
      final bytes = await client.downloadResumeBytes('cand-1');
      expect(bytes, isA<Uint8List>());
      expect(bytes.sublist(0, 5), equals([37, 80, 68, 70, 45])); // %PDF-
    });

    test('Mock Mode updateCandidateStatus succeeds', () async {
      final client = AdminApiClient(Dio());
      final success = await client.updateCandidateStatus('cand-1', 'REVIEWING');
      expect(success, true);
    });
  });

  group('Session Persistence Tests', () {
    test('AuthTokenNotifier loads and saves token to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      // Initially null
      expect(container.read(authTokenProvider), isNull);

      // Generate a valid mock JWT with future expiry
      final exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      final payload = base64Url.encode(utf8.encode(jsonEncode({'userId': 'usr-1', 'exp': exp})));
      final validJwt = 'eyJhbGciOiJIUzI1NiJ9.$payload.signature';

      // Set token
      container.read(authTokenProvider.notifier).setToken(validJwt);
      expect(container.read(authTokenProvider), validJwt);
      expect(prefs.getString('auth_token'), validJwt);

      // Create new container simulating app reload with saved prefs
      final newContainer = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      expect(newContainer.read(authTokenProvider), validJwt);

      // Clear token (logout)
      container.read(authTokenProvider.notifier).setToken(null);
      expect(prefs.getString('auth_token'), isNull);
    });
  });
}
