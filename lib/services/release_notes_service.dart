import 'package:flutter/services.dart';

class ReleaseNote {
  final String version;
  final String date;
  final Map<String, List<String>> sections;

  const ReleaseNote({
    required this.version,
    required this.date,
    required this.sections,
  });
}

class ReleaseNotesService {
  static final ReleaseNotesService _instance = ReleaseNotesService._internal();
  factory ReleaseNotesService() => _instance;
  ReleaseNotesService._internal();

  String? _raw;

  Future<String> _loadRaw() async {
    _raw ??= await rootBundle.loadString('assets/RELEASES.md');
    return _raw!;
  }

  Future<ReleaseNote?> getNotesForVersion(String version) async {
    final raw = await _loadRaw();
    final blocks = _splitIntoVersionBlocks(raw);

    for (final block in blocks) {
      final headerMatch = RegExp(
        r'##\s+\[(\d+\.\d+\.\d+)\]\s*[—–-]+\s*(.+)',
      ).firstMatch(block);
      if (headerMatch == null) continue;

      final blockVersion = headerMatch.group(1)!;
      if (blockVersion != version) continue;

      final date = headerMatch.group(2)!.trim();
      final sections = _parseSections(block);
      return ReleaseNote(version: blockVersion, date: date, sections: sections);
    }

    return null;
  }

  List<String> _splitIntoVersionBlocks(String raw) {
    final pattern = RegExp(r'(?=## \[\d+\.\d+\.\d+\])');
    return raw.split(pattern).where((b) => b.trim().isNotEmpty).toList();
  }

  Map<String, List<String>> _parseSections(String block) {
    final result = <String, List<String>>{};
    final sectionPattern = RegExp(r'###\s+(.+)');
    final itemPattern = RegExp(r'^-\s+(.+)', multiLine: true);

    final lines = block.split('\n');
    String? currentSection;

    for (final line in lines) {
      final sectionMatch = sectionPattern.firstMatch(line);
      if (sectionMatch != null) {
        currentSection = sectionMatch.group(1)!.trim();
        result[currentSection] = [];
        continue;
      }

      if (currentSection != null) {
        final itemMatch = itemPattern.firstMatch(line);
        if (itemMatch != null) {
          result[currentSection]!.add(itemMatch.group(1)!.trim());
        }
      }
    }

    return result;
  }
}
