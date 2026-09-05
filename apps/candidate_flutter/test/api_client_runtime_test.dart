import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:candidate_flutter/src/api_client.dart';

void main() {
  group('CandidateApiClient Resume Policy & Failure Safety Tests', () {
    test('Offline backend throws Exception and NEVER returns fake REC ID', () async {
      final dio = Dio(BaseOptions(
        baseUrl: 'http://127.0.0.1:9999/api/v1',
        connectTimeout: const Duration(milliseconds: 200),
      ));
      final client = CandidateApiClient(dio);

      expect(
        () async => await client.submitApplication(
          positionId: 'pos-001',
          firstName: 'Jane',
          lastName: 'Doe',
          email: 'jane@example.com',
          resumeFile: PlatformFile(name: 'test.pdf', size: 3, bytes: Uint8List.fromList([1, 2, 3])),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Backend rejection for non-PDF file throws DioException and does NOT return success', () async {
      final dio = Dio(BaseOptions(
        baseUrl: 'http://127.0.0.1:8787/api/v1',
        connectTimeout: const Duration(seconds: 3),
      ));
      final client = CandidateApiClient(dio);

      try {
        await client.submitApplication(
          positionId: 'pos-001',
          firstName: 'Test',
          lastName: 'User',
          email: 'test.user@example.com',
          resumeFile: PlatformFile(name: 'resume.docx', size: 10, bytes: Uint8List.fromList([80, 75, 3, 4])),
        );
        fail('Expected DioException for non-PDF resume');
      } catch (e) {
        expect(e, isA<DioException>());
        final dioErr = e as DioException;
        expect(dioErr.response?.statusCode, 400);
        final friendlyMsg = getFriendlyErrorMessage(dioErr);
        expect(friendlyMsg.contains('PDF'), true);
      }
    });

    test('Backend rejection for fake PDF (invalid magic bytes) throws DioException', () async {
      final dio = Dio(BaseOptions(
        baseUrl: 'http://127.0.0.1:8787/api/v1',
        connectTimeout: const Duration(seconds: 3),
      ));
      final client = CandidateApiClient(dio);

      try {
        await client.submitApplication(
          positionId: 'pos-001',
          firstName: 'Test',
          lastName: 'Fake',
          email: 'test.fake@example.com',
          resumeFile: PlatformFile(name: 'fake.pdf', size: 20, bytes: Uint8List.fromList([78, 79, 84, 95, 80, 68, 70])),
        );
        fail('Expected DioException for fake PDF');
      } catch (e) {
        expect(e, isA<DioException>());
        final dioErr = e as DioException;
        expect(dioErr.response?.statusCode, 400);
        expect(dioErr.response?.data['message'], contains('Invalid PDF'));
      }
    });

    test('Backend accepts valid PDF within 2 MB and returns real referenceId', () async {
      final dio = Dio(BaseOptions(
        baseUrl: 'http://127.0.0.1:8787/api/v1',
        connectTimeout: const Duration(seconds: 3),
      ));
      final client = CandidateApiClient(dio);

      final pdfBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x34]); // %PDF-1.4
      final result = await client.submitApplication(
        positionId: 'pos-001',
        firstName: 'Live',
        lastName: 'Candidate',
        email: 'live.candidate@example.com',
        resumeFile: PlatformFile(name: 'live_resume.pdf', size: pdfBytes.length, bytes: pdfBytes),
      );

      expect(result['referenceId'], isNotNull);
      expect(result['referenceId'].toString().startsWith('REC-2026-'), true);
      expect(result['applicationId'], isNotNull);
    });

    test('Mock mode browsing succeeds for GET requests', () async {
      final dio = Dio(BaseOptions(baseUrl: ''));
      final client = CandidateApiClient(dio);
      expect(client.isMockMode, true);
      final positions = await client.getPublicPositions();
      expect(positions.isNotEmpty, true);
    });
  });
}
