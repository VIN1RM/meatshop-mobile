import 'dart:convert';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';

class PersonalDataExportService {
  static Future<void> share(String json) async {
    await Share.shareXFiles(
      [
        XFile.fromData(
          Uint8List.fromList(utf8.encode(json)),
          mimeType: 'application/json',
        ),
      ],
      fileNameOverrides: ['meatshop-meus-dados.json'],
    );
  }
}
