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

      print('🌐 Running on web: $kIsWeb');

      if (apiKey.isEmpty) {
        throw Exception('LLaMA API key not configured');
      }
      
      // Prepare conversation context
      List<Map<String, String>> messages = [];
      
      // Add system prompt to set AI personality
      messages.add({
        'role': 'system',
        'content': 'You are a casual, friendly person chatting naturally. Respond like a real human friend would - be conversational, use natural language, and keep it brief (1-2 sentences max). Avoid being overly helpful or formal. Just chat normally like you would with a friend. Don\'t repeat the same phrases or be robotic.'
      });
      
      // Add conversation history if provided (last 10 messages for context)
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        final recentHistory = conversationHistory.length > 10 
            ? conversationHistory.sublist(conversationHistory.length - 10)
            : conversationHistory;
        messages.addAll(recentHistory);
      }
      
      // Add current user message
      messages.add({
        'role': 'user',
        'content': userMessage,
      });
      
      print('🤖 Sending request to: $apiUrl');
      print('🔑 Using API key: ${apiKey.substring(0, 10)}...');
      print('🔗 API Key length: ${apiKey.length}');
      print('🌐 Headers: HTTP-Referer: https://lumo-chat.app, X-Title: Lumo Chat App');

      final requestBody = {
        'model': 'meta-llama/llama-3.3-70b-instruct:free', // Updated to 3.3 model
        'messages': messages,
        'max_tokens': 100, // Reduced for shorter, more natural responses
        'temperature': 0.8, // Slightly higher for more natural variation
        'stream': false,
      };

      print('📝 Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://lumo-chat.app', // Optional. Site URL for rankings on openrouter.ai
          'X-Title': 'Lumo Chat App', // Optional. Site title for rankings on openrouter.ai
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));
      
      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final aiResponse = data['choices'][0]['message']['content'] as String;
          print('✅ AI Response: $aiResponse');
          return aiResponse.trim();
        } else {
          print('❌ No choices in response');
          return "I received an empty response. Please try again.";
        }
      } else {
        print('❌ AI API Error: ${response.statusCode} - ${response.body}');
        return _getErrorResponse(response.statusCode);
      }
    } on TimeoutException catch (e) {
      print('⏰ AI Service Timeout: $e');
      return "I'm taking too long to respond. Please try again.";
    } on http.ClientException catch (e) {
      print('🌐 HTTP Client Error: $e');
      if (kIsWeb) {
        return "CORS or network issue detected. This might be a browser security restriction.";
      }
      return "Network connection error. Please check your internet connection.";
    } catch (e, stackTrace) {
      print('💥 AI Service Error: $e');
      print('🔍 Error type: ${e.runtimeType}');
      print('📍 Stack trace: $stackTrace');
      return _getFallbackResponse();
    }
  }
  
  /// Returns appropriate error response based on status code
  String _getErrorResponse(int statusCode) {
    switch (statusCode) {
      case 401:
        return "Sorry, there's an authentication issue with the AI service. Please check the API configuration.";
      case 429:
        return "I'm getting too many requests right now. Please try again in a moment.";
      case 500:
        return "The AI service is temporarily unavailable. Please try again later.";
      default:
        return "I'm having trouble connecting right now. Please try again.";
    }
  }
  
  /// Returns a fallback response when AI service fails
  String _getFallbackResponse() {
    final fallbackResponses = [
      "I'm having some technical difficulties right now. How can I help you?",
      "Sorry, I'm experiencing some connection issues. What would you like to talk about?",
      "I'm here to chat! Though I'm having some technical hiccups at the moment.",
      "Let me know what's on your mind! I might be a bit slow to respond due to technical issues.",
    ];
    
    return fallbackResponses[DateTime.now().millisecond % fallbackResponses.length];
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
