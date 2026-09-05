import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
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
  });
}
