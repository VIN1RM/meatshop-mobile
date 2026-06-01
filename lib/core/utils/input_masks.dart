import 'package:flutter/services.dart';

class CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final masked = _maskCpf(digits);
    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}

class CnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final masked = _maskCnpj(digits);
    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final masked = _maskPhone(digits);
    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}

class InputMasks {
  InputMasks._();

  static String cpf(String raw) => _maskCpf(raw.replaceAll(RegExp(r'\D'), ''));
  static String cnpj(String raw) => _maskCnpj(raw.replaceAll(RegExp(r'\D'), ''));
  static String phone(String raw) => _maskPhone(raw.replaceAll(RegExp(r'\D'), ''));
}

String _maskCpf(String d) {
  final n = d.length;
  if (n == 0) return '';
  final b = StringBuffer();
  for (var i = 0; i < n && i < 11; i++) {
    if (i == 3 || i == 6) b.write('.');
    if (i == 9) b.write('-');
    b.write(d[i]);
  }
  return b.toString();
}

String _maskCnpj(String d) {
  final n = d.length;
  if (n == 0) return '';
  final b = StringBuffer();
  for (var i = 0; i < n && i < 14; i++) {
    if (i == 2 || i == 5) b.write('.');
    if (i == 8) b.write('/');
    if (i == 12) b.write('-');
    b.write(d[i]);
  }
  return b.toString();
}

String _maskPhone(String d) {
  final n = d.length;
  if (n == 0) return '';
  final b = StringBuffer();
  for (var i = 0; i < n && i < 11; i++) {
    if (i == 0) b.write('(');
    if (i == 2) b.write(') ');
    final dashPos = n <= 10 ? 6 : 7;
    if (i == dashPos) b.write('-');
    b.write(d[i]);
  }
  return b.toString();
}