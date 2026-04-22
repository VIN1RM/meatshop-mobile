import 'package:flutter/material.dart';
import 'package:meatshop_mobile/services/release_notes_service.dart';

class ReleaseNotesDialog extends StatefulWidget {
  final String version;

  const ReleaseNotesDialog({super.key, required this.version});

  static Future<void> show(BuildContext context, String version) {
    return showDialog(
      context: context,
      builder: (_) => ReleaseNotesDialog(version: version),
    );
  }

  @override
  State<ReleaseNotesDialog> createState() => _ReleaseNotesDialogState();
}

class _ReleaseNotesDialogState extends State<ReleaseNotesDialog> {
  static const Color _red = Color(0xFFC0392B);

  late Future<ReleaseNote?> _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture = ReleaseNotesService().getNotesForVersion(widget.version);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF2A2A2A),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          maxWidth: 420,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogHeader(),
            Flexible(child: _buildContent()),
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF3A3A3A))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.new_releases_outlined,
              color: Color.fromARGB(255, 255, 255, 255),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Novidades',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'v${widget.version}',
                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FutureBuilder<ReleaseNote?>(
      future: _notesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(color: Color(0xFFC0392B)),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Notas de versão não encontradas.',
              style: TextStyle(color: Color(0xFF9E9E9E)),
              textAlign: TextAlign.center,
            ),
          );
        }

        final note = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.date,
                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
              ),
              const SizedBox(height: 16),
              ...note.sections.entries.map(
                (entry) => _buildSection(entry.key, entry.value),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    final sectionMeta = _sectionMeta(title);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(sectionMeta.$1, color: sectionMeta.$2, size: 16),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: sectionMeta.$2,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((item) => _buildItem(item)),
        ],
      ),
    );
  }

  Widget _buildItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: CircleAvatar(radius: 3, backgroundColor: Color(0xFF9E9E9E)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF3A3A3A))),
      ),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            backgroundColor: _red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Fechar',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  (IconData, Color) _sectionMeta(String section) {
    if (section.contains('✨')) {
      return (Icons.auto_awesome_outlined, const Color(0xFF4CAF50));
    }
    if (section.contains('📈')) {
      return (Icons.trending_up, const Color(0xFF2196F3));
    }
    if (section.contains('🚀')) {
      return (Icons.rocket_launch_outlined, const Color(0xFFFF9800));
    }
    if (section.contains('🐛') || section.contains('🔧')) {
      return (Icons.bug_report_outlined, const Color(0xFFFF9800));
    }
    return (Icons.info_outline, const Color(0xFF9E9E9E));
  }
}
