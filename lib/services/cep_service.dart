import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

sealed class CepResult {
  const CepResult();
}

final class CepSuccess extends CepResult {
  const CepSuccess(this.data);
  final CepData data;
}

final class CepFailure extends CepResult {
  const CepFailure(this.message);
  final String message;
}

extension CepResultX on CepResult {
  void fold({
    required void Function(CepData)   onSuccess,
    required void Function(String)    onFailure,
  }) {
    switch (this) {
      case CepSuccess(:final data):    onSuccess(data);
      case CepFailure(:final message): onFailure(message);
    }
  }
}


class CepData {
  const CepData({
    required this.zipCode,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
  });

  final String zipCode;
  final String street;
  final String neighborhood;
  final String city;
  final String state;

  factory CepData.fromJson(Map<String, dynamic> json) => CepData(
        zipCode:      json['cep']        as String? ?? '',
        street:       json['logradouro'] as String? ?? '',
        neighborhood: json['bairro']     as String? ?? '',
        city:         json['localidade'] as String? ?? '',
        state:        json['uf']         as String? ?? '',
      );
}

abstract final class CepService {
  static const _baseUrl = 'https://viacep.com.br/ws';
  static const _timeout = Duration(seconds: 10);

  static Future<CepResult> fetch(String digits) async {
    assert(digits.length == 8 && int.tryParse(digits) != null,
        'Passe somente os 8 dígitos do CEP');

    try {
      final uri      = Uri.parse('$_baseUrl/$digits/json/');
      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        return const CepFailure('Serviço indisponível. Tente novamente.');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (body['erro'] == true) {
        return const CepFailure('CEP não encontrado.');
      }

      return CepSuccess(CepData.fromJson(body));
    } on SocketException {
      return const CepFailure('Sem conexão com a internet.');
    } on HttpException {
      return const CepFailure('Erro ao acessar o serviço de CEP.');
    } on FormatException {
      return const CepFailure('Resposta inválida do servidor.');
    } catch (_) {
      return const CepFailure('Erro inesperado. Tente novamente.');
    }
  }
}