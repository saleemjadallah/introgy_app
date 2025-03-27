import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  final String _baseUrl = 'https://api-inference.huggingface.co/models';
  late final String _apiKey;
  
  AIService() {
    _apiKey = dotenv.env['HUGGINGFACE_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      debugPrint('Warning: HUGGINGFACE_API_KEY not found in environment variables');
    }
  }

  /// Generate content using a specific HuggingFace model
  Future<String> generateContent({
    required String model,
    required String prompt,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final url = '$_baseUrl/$model';
      final defaultParams = {
        'temperature': 0.7,
        'max_length': 100,
        'top_p': 0.9,
        'repetition_penalty': 1.0,
      };
      
      final requestBody = {
        'inputs': prompt,
        'parameters': parameters ?? defaultParams,
      };
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result is List && result.isNotEmpty) {
          if (result[0] is Map && result[0].containsKey('generated_text')) {
            return result[0]['generated_text'];
          }
          return result[0].toString();
        }
        return result.toString();
      } else {
        debugPrint('Error generating content: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to generate content: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception in AI service: $e');
      throw Exception('AI service error: $e');
    }
  }
  
  /// Generate a personalized wellbeing tip
  Future<String> generateWellbeingTip(String userProfile) async {
    return generateContent(
      model: 'gpt2',
      prompt: 'Generate a personalized wellbeing tip for a user with the following profile: $userProfile',
    );
  }
  
  /// Generate connection building suggestions
  Future<String> generateConnectionSuggestions(String connectionContext) async {
    return generateContent(
      model: 'gpt2',
      prompt: 'Suggest ways to strengthen this connection: $connectionContext',
    );
  }
  
  /// Generate social battery management tips
  Future<String> generateSocialBatteryTips(int currentLevel) async {
    return generateContent(
      model: 'gpt2',
      prompt: 'Provide tips for managing social energy when current battery level is $currentLevel out of 100',
    );
  }
  
  /// Generate a personalized bio suggestion
  Future<String> generateBioSuggestion(String interests, String personality) async {
    return generateContent(
      model: 'gpt2',
      prompt: 'Generate a short bio for a person with these interests: $interests and personality traits: $personality',
    );
  }
}
