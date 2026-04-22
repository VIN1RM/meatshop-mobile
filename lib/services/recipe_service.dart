import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class RecipeService {
  static const String _apiKey = 'AIzaSyBJ2UDM9Gya-FPQDSUQiJcHRmIKbrBV8YQ';

  static const String _systemPrompt =
      'Você é um assistente especializado exclusivamente em carnes e receitas '
      'com carne. Se sair do tema, responda: "Só posso ajudar com carnes 🥩".';

  late final GenerativeModel _model;
  late ChatSession _chat;

  RecipeService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemPrompt),
    );
    _chat = _model.startChat();
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      final response = await _chat.sendMessage(Content.text(userMessage));
      return response.text ?? 'Sem resposta.';
    } catch (e) {
      debugPrint('Erro Gemini: $e');
      return 'Erro ao responder.';
    }
  }

  void clearHistory() {
    _chat = _model.startChat();
  }
}
