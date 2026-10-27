class PasswordPolicy {
  static const minimumLength = 8;
  static const maximumLength = 64;

  static bool hasMinimumLength(String value) => value.length >= minimumLength;
  static bool hasUppercase(String value) => RegExp(r'[A-Z]').hasMatch(value);
  static bool hasLowercase(String value) => RegExp(r'[a-z]').hasMatch(value);
  static bool hasNumber(String value) => RegExp(r'[0-9]').hasMatch(value);
  static bool hasSpecialCharacter(String value) =>
      RegExp(r'[^a-zA-Z0-9\s]').hasMatch(value);

  static bool isValid(String value) =>
      hasMinimumLength(value) &&
      value.length <= maximumLength &&
      hasUppercase(value) &&
      hasLowercase(value) &&
      hasNumber(value) &&
      hasSpecialCharacter(value);

  static void validate(String value) {
    if (!isValid(value)) {
      throw ArgumentError(
        'A senha deve ter entre 8 e 64 caracteres, com letras maiúsculas, minúsculas, número e caractere especial.',
      );
    }
  }
}
