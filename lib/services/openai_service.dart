import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class SkinAnalysisResult {
  const SkinAnalysisResult({
    required this.skinType,
    required this.suggestion,
    required this.concerns,
  });

  final String skinType;
  final String suggestion;
  final List<String> concerns;

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> json) {
    return SkinAnalysisResult(
      skinType: (json['skinType'] as String?) ?? 'unknown',
      suggestion: (json['suggestion'] as String?) ?? 'No suggestion.',
      concerns: List<String>.from(json['concerns'] ?? const []),
    );
  }
}

class OpenAIService {
  OpenAIService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;

  Future<SkinAnalysisResult> analyzeSkinImage(Uint8List imageBytes) async {
    const endpoint = 'https://api.openai.com/v1/chat/completions';

    final response = await _client.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4.1-mini', //gpt-4.1-nano - https://openai.com/zh-Hant/api/pricing/
        'messages': [
          {
            'role': 'system',
            'content': 'You are a strict skincare analyzer for men. Output valid JSON only.',
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text':
                    'Analyze this face image for men skincare. Return only JSON with keys skinType, suggestion, concerns (array of strings). Use Traditional Chinese for suggestion and concerns when possible.',
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,${base64Encode(imageBytes)}',
                },
              },
            ],
          },
        ],
        'response_format': {
          'type': 'json_schema',
          'json_schema': {
            'name': 'skin_analysis',
            'strict': true,
            'schema': {
              'type': 'object',
              'additionalProperties': false,
              'properties': {
                'skinType': {'type': 'string'},
                'suggestion': {'type': 'string'},
                'concerns': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
              },
              'required': ['skinType', 'suggestion', 'concerns'],
            },
          },
        },
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('OpenAI API error: ${response.statusCode} ${response.body}');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final content = ((payload['choices'] as List?)
                ?.firstOrNull as Map<String, dynamic>?)?['message']
            as Map<String, dynamic>?;

    final jsonText = (content?['content'] as String?) ?? '{}';
    final parsed = jsonDecode(jsonText) as Map<String, dynamic>;
    return SkinAnalysisResult.fromJson(parsed);
  }
}

extension _ListSafeAccess<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
