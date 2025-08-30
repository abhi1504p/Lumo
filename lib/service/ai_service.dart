import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../env/env.dart';

class AIService {
  static const String _aiUserId = 'AI_BOT';
  static const String _aiUserEmail = 'ai@lumo.app';
  
  /// Sends a message to LLaMA-3 API and returns the AI response
  Future<String> getAIResponse(String userMessage, {List<Map<String, String>>? conversationHistory}) async {
    try {
      final apiKey = Env.llamaApiKey;
      final apiUrl = Env.llamaApiUrl;

      if (apiKey.isEmpty) {
        throw Exception('LLaMA API key not configured');
      }

      // Prepare conversation context
      List<Map<String, String>> messages = [];

      // Add system prompt to set AI personality
      messages.add({
        'role': 'system',
        'content': 'You are a casual, friendly person chatting naturally. Respond like a real human friend would - be conversational, use natural language, and keep it brief. Avoid being overly helpful or formal. Just chat normally like you would with a friend.'
      });

      // Add conversation history if provided (last 5 messages for context)
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        final recentHistory = conversationHistory.length > 5
            ? conversationHistory.sublist(conversationHistory.length - 5)
            : conversationHistory;
        messages.addAll(recentHistory);
      }

      // Add current user message
      messages.add({
        'role': 'user',
        'content': userMessage,
      });

      final requestBody = {
        'model': 'meta-llama/llama-3.3-70b-instruct:free',
        'messages': messages,
        'temperature': 0.8,
        'stream': false,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://lumo-chat.app',
          'X-Title': 'Lumo Chat App',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final aiResponse = data['choices'][0]['message']['content'] as String;
          return aiResponse.trim();
        } else {
          return "I received an empty response. Please try again.";
        }
      } else {
        return _getErrorResponse(response.statusCode);
      }
    } on TimeoutException catch (e) {
      return "I'm taking too long to respond. Please try again.";
    } on http.ClientException catch (e) {
      if (kIsWeb) {
        return "Network issue detected. Please check your connection.";
      }
      return "Network connection error. Please check your internet connection.";
    } catch (e) {
      return _getFallbackResponse();
    }
  }
  
  /// Returns appropriate error response based on status code
  String _getErrorResponse(int statusCode) {
    switch (statusCode) {
      case 401:
        return "Authentication issue. Please check API configuration.";
      case 429:
        return "Too many requests. Please try again in a moment.";
      case 500:
        return "Service temporarily unavailable. Please try again later.";
      default:
        return "Connection issue. Please try again.";
    }
  }

  /// Returns a fallback response when AI service fails
  String _getFallbackResponse() {
    final responses = [
      "Sorry, I'm having technical difficulties.",
      "Please try again in a moment.",
      "Something went wrong. Please try again.",
      "I'm having trouble right now.",
    ];

    return responses[DateTime.now().millisecond % responses.length];
  }
  
  /// Converts chat history to the format expected by the AI API
  List<Map<String, String>> formatConversationHistory(List<Map<String, dynamic>> messages) {
    return messages.map((message) {
      final isAI = message['senderId'] == _aiUserId;
      return {
        'role': isAI ? 'assistant' : 'user',
        'content': message['message'] as String,
      };
    }).toList();
  }
  
  /// Gets the AI user ID for identifying AI messages
  static String get aiUserId => _aiUserId;
  
  /// Gets the AI user email for identifying AI messages
  static String get aiUserEmail => _aiUserEmail;
  
  /// Checks if a message is from AI
  static bool isAIMessage(String senderId) {
    return senderId == _aiUserId;
  }
}
