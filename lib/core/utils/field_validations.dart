import '../auth/password_policy.dart';

final class FieldValidations {
  FieldValidations._();

  static const states = {
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO',
  };
  static const _areaCodes = {
    '11',
    '12',
    '13',
    '14',
    '15',
    '16',
    '17',
    '18',
    '19',
    '21',
    '22',
    '24',
    '27',
    '28',
    '31',
    '32',
    '33',
    '34',
    '35',
    '37',
    '38',
    '41',
    '42',
    '43',
    '44',
    '45',
    '46',
    '47',
    '48',
    '49',
    '51',
    '53',
    '54',
    '55',
    '61',
    '62',
    '63',
    '64',
    '65',
    '66',
    '67',
    '68',
    '69',
    '71',
    '73',
    '74',
    '75',
    '77',
    '79',
    '81',
    '82',
    '83',
    '84',
    '85',
    '86',
    '87',
    '88',
    '89',
    '91',
    '92',
    '93',
    '94',
    '95',
    '96',
    '97',
    '98',
    '99',
  };

  static String digits(String value) => value.replaceAll(RegExp(r'\D'), '');

  static String? required(
    String? value, {
    String message = 'Campo obrigatório',
  }) => value == null || value.trim().isEmpty ? message : null;

  static String? text(
    String? value, {
    String requiredMessage = 'Campo obrigatório',
    int minimumLength = 1,
    int? maximumLength,
    bool optional = false,
  }) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) {
      return optional ? null : requiredMessage;
    }
    if (cleaned.length < minimumLength) {
      return 'Use pelo menos $minimumLength caracteres';
    }
    if (maximumLength != null && cleaned.length > maximumLength) {
      return 'Use até $maximumLength caracteres';
    }
    return null;
  }

  static String? name(String? value) => text(
    value,
    requiredMessage: 'Informe o nome',
    minimumLength: 2,
    maximumLength: 100,
  );

  static bool isValidCpf(String value) {
    final cleaned = value.trim();
    if (!RegExp(r'^[0-9.\s-]+$').hasMatch(cleaned)) {
      return false;
    }
    final number = digits(cleaned);
    if (number.length != 11 || RegExp(r'^(\d)\1+$').hasMatch(number)) {
      return false;
    }
    final first = _digit(number.substring(0, 9), [10, 9, 8, 7, 6, 5, 4, 3, 2]);
    final second = _digit('${number.substring(0, 9)}$first', [
      11,
      10,
      9,
      8,
      7,
      6,
      5,
      4,
      3,
      2,
    ]);
    return number.endsWith('$first$second');
  }

  static bool isValidCnpj(String value) {
    final cleaned = value.trim();
    if (!RegExp(r'^[0-9./\s-]+$').hasMatch(cleaned)) {
      return false;
    }
    final number = digits(cleaned);
    if (number.length != 14 || RegExp(r'^(\d)\1+$').hasMatch(number)) {
      return false;
    }
    final first = _digit(number.substring(0, 12), [
      5,
      4,
      3,
      2,
      9,
      8,
      7,
      6,
      5,
      4,
      3,
      2,
    ]);
    final second = _digit('${number.substring(0, 12)}$first', [
      6,
      5,
      4,
      3,
      2,
      9,
      8,
      7,
      6,
      5,
      4,
      3,
      2,
    ]);
    return number.endsWith('$first$second');
  }

  static int _digit(String value, List<int> weights) {
    var sum = 0;
    for (var index = 0; index < value.length; index++) {
      sum += int.parse(value[index]) * weights[index];
    }
    final remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }

  static String? cpf(String? value) =>
      required(value, message: 'Informe o CPF') ??
      (isValidCpf(value!) ? null : 'CPF inválido');
  static String? cnpj(String? value) =>
      required(value, message: 'Informe o CNPJ') ??
      (isValidCnpj(value!) ? null : 'CNPJ inválido');

  static bool isValidEmail(String value) {
    final cleaned = value.trim();
    if (cleaned.length > 150 || cleaned.contains(RegExp(r'\s'))) {
      return false;
    }
    final parts = cleaned.split('@');
    if (parts.length != 2) {
      return false;
    }
    final local = parts[0];
    if (local.isEmpty ||
        local.length > 64 ||
        local.startsWith('.') ||
        local.endsWith('.') ||
        local.contains('..')) {
      return false;
    }
    if (!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+$").hasMatch(local)) {
      return false;
    }
    final labels = parts[1].split('.');
    if (labels.length < 2 || labels.last.length < 2) {
      return false;
    }
    return labels.every(
          (label) =>
              label.length <= 63 &&
              RegExp(
                r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$',
              ).hasMatch(label),
        ) &&
        RegExp(r'[a-zA-Z]').hasMatch(labels.last);
  }

  static String? email(
    String? value, {
    String requiredMessage = 'Informe o e-mail',
  }) =>
      required(value, message: requiredMessage) ??
      (isValidEmail(value!) ? null : 'E-mail inválido');

  static String normalizeMobilePhone(String value) {
    final number = digits(value);
    return number.length == 13 && number.startsWith('55')
        ? number.substring(2)
        : number;
  }

  static String? requiredAny(
    Iterable<String?> values, {
    required String message,
  }) => values.any((value) => required(value) == null) ? null : message;

  static bool isValidMobilePhone(String value) {
    if (!RegExp(r'^[0-9()+.\s-]+$').hasMatch(value.trim())) {
      return false;
    }
    if (value.contains('+') &&
        (!value.trim().startsWith('+55') ||
            '+'.allMatches(value).length != 1 ||
            digits(value).length != 13)) {
      return false;
    }
    final number = normalizeMobilePhone(value);
    return number.length == 11 &&
        _areaCodes.contains(number.substring(0, 2)) &&
        number[2] == '9';
  }

  static String? mobilePhone(String? value) =>
      required(value, message: 'Informe o celular') ??
      (isValidMobilePhone(value!) ? null : 'Celular inválido');

  static String? cep(String? value) =>
      value != null && RegExp(r'^\d{5}-?\d{3}$').hasMatch(value.trim())
      ? null
      : 'CEP inválido';
  static String? state(String? value) =>
      states.contains(value?.trim().toUpperCase()) ? null : 'UF inválida';

  static String? existingPassword(
    String? value, {
    String requiredMessage = 'Informe a senha',
    int minimumLength = 1,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }
    return value.length < minimumLength
        ? 'Mínimo $minimumLength caracteres'
        : null;
  }

  static String? newPassword(
    String? value, {
    String requiredMessage = 'Informe a senha',
  }) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }
    if (!PasswordPolicy.hasMinimumLength(value)) {
      return 'Mínimo 8 caracteres';
    }
    if (value.length > PasswordPolicy.maximumLength) {
      return 'Máximo 64 caracteres';
    }
    if (!PasswordPolicy.hasUppercase(value)) {
      return 'Adicione uma letra maiúscula';
    }
    if (!PasswordPolicy.hasLowercase(value)) {
      return 'Adicione uma letra minúscula';
    }
    if (!PasswordPolicy.hasNumber(value)) {
      return 'Adicione um número';
    }
    if (!PasswordPolicy.hasSpecialCharacter(value)) {
      return 'Adicione um caractere especial';
    }
    return null;
  }

  static String? passwordConfirmation(
    String? value,
    String password, {
    String requiredMessage = 'Confirme a senha',
  }) =>
      existingPassword(value, requiredMessage: requiredMessage) ??
      (value == password ? null : 'As senhas não coincidem');

  static String? vehicleYear(String? value, {int? currentYear}) {
    final year = int.tryParse(value?.trim() ?? '');
    return year != null &&
            year >= 1950 &&
            year <= (currentYear ?? DateTime.now().year) + 1
        ? null
        : 'Informe um ano válido';
  }

  static String? licensePlate(String? value) {
    if (required(value) != null) {
      return 'Informe a placa';
    }
    return RegExp(
          r'^[A-Z]{3}[ -]?[0-9][A-Z0-9][0-9]{2}$',
        ).hasMatch(value!.trim().toUpperCase())
        ? null
        : 'Placa inválida';
  }

  static double? parseMoney(String? value) {
    var cleaned = value?.trim() ?? '';
    if (RegExp(r'^\d{1,3}(?:\.\d{3})+,\d{1,2}$').hasMatch(cleaned)) {
      cleaned = cleaned.replaceAll('.', '');
    }
    cleaned = cleaned.replaceAll(',', '.');
    if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(cleaned)) {
      return null;
    }
    final parsed = double.tryParse(cleaned);
    return parsed != null && parsed.isFinite ? parsed : null;
  }

  static String? money(
    String? value, {
    double minimum = 0.01,
    double maximum = 9999999999.99,
    String message = 'Informe um valor positivo com até duas casas decimais',
  }) {
    final parsed = parseMoney(value);
    return parsed != null && parsed >= minimum && parsed <= maximum
        ? null
        : message;
  }

  static String? verificationCode(String? value) =>
      value != null && RegExp(r'^\d{6}$').hasMatch(value)
      ? null
      : 'Informe um código de 6 dígitos';
}
