import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sharpface/services/openai_service.dart';

void main() {
  test('analyzeSkinImage returns parsed JSON result', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), 'https://api.openai.com/v1/chat/completions');
      expect(request.headers['Authorization'], 'Bearer test-key');

      final payload = jsonDecode(request.body) as Map<String, dynamic>;
      expect(payload['model'], 'gpt-4.1-mini');

      final body = jsonEncode({
        'choices': [
          {
            'message': {
              'content': jsonEncode({
                'skinType': '混合肌',
                'suggestion': '加強保濕與防曬',
                'concerns': ['痘痘', '黑眼圈'],
              }),
            },
          }
        ],
      });
      return http.Response.bytes(
        utf8.encode(body),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final service = OpenAIService(apiKey: 'test-key', client: client);
    final result = await service.analyzeSkinImage(Uint8List.fromList([1, 2, 3]));

    expect(result.skinType, '混合肌');
    expect(result.suggestion, '加強保濕與防曬');
    expect(result.concerns, ['痘痘', '黑眼圈']);
  });

  test('analyzeSkinImage throws when API returns error', () async {
    final client = MockClient((_) async {
      return http.Response('{"error":"bad request"}', 400);
    });

    final service = OpenAIService(apiKey: 'test-key', client: client);

    expect(
      () => service.analyzeSkinImage(Uint8List.fromList([1, 2, 3])),
      throwsException,
    );
  });
}
