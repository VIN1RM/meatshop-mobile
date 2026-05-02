import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeService {
  static const String _baseUrl = 'https://meatshop-chatbot.onrender.com/chat';

  Future<String> sendMessage(String message) async {
    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': message}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'Sem resposta.';
      } else {
        return 'Erro: ${response.statusCode}';
      }
    } catch (e) {
      return 'Servidor iniciando... tente novamente ⏳';
    }
  }

  void clearHistory() {}
}
