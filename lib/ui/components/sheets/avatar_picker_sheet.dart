import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';
import 'package:meatshop_mobile/ui/screens/account/profile_photo_viewer_screen.dart';

class AvatarPickerSheet extends StatelessWidget {
  const AvatarPickerSheet({
    super.key,
    required this.hasPhoto,
    required this.onRemove,
    this.photoUrl,
  });

  final bool hasPhoto;
  final VoidCallback onRemove;
  final String? photoUrl;

  static Future<File?> show(
    BuildContext context, {
    required bool hasPhoto,
    required VoidCallback onRemove,
    String? photoUrl,
  }) {
    return showModalBottomSheet<File?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AvatarPickerSheet(
        hasPhoto: hasPhoto,
        onRemove: onRemove,
        photoUrl: photoUrl,
      ),
    );
  }

  Future<File?> _pick(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 800,
    );
    if (picked == null) return null;

    final ext = picked.path.split('.').last.toLowerCase();
    const allowed = ['jpg', 'jpeg', 'png', 'webp', 'heic'];
    if (!allowed.contains(ext)) {
      if (context.mounted) {
        CustomSnackBar.warning(
          'Selecione apenas arquivos de imagem.',
          context: context,
        );
      }
      return null;
    }

    return File(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Foto de perfil',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Escolha como deseja adicionar sua foto',
            style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _OptionButton(
                icon: Icons.camera_alt_outlined,
                label: 'Tirar foto',
                onTap: () async {
                  final file = await _pick(context, ImageSource.camera);
                  if (context.mounted) Navigator.pop(context, file);
                },
              ),
              _OptionButton(
                icon: Icons.photo_library_outlined,
                label: 'Galeria',
                onTap: () async {
                  final file = await _pick(context, ImageSource.gallery);
                  if (context.mounted) Navigator.pop(context, file);
                },
              ),
              if (hasPhoto && photoUrl != null)
                _OptionButton(
                  icon: Icons.visibility_outlined,
                  label: 'Visualizar',
                  onTap: () {
                    Navigator.pop(context, null);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProfilePhotoViewerScreen(photoUrl: photoUrl!),
                      ),
                    );
                  },
                ),
              if (hasPhoto)
                _OptionButton(
                  icon: Icons.delete_outline,
                  label: 'Remover',
                  iconColor: const Color(0xFFC0392B),
                  onTap: () {
                    Navigator.pop(context, null);
                    onRemove();
                  },
                ),
            ],
          ),

          const SizedBox(height: 20),

          GestureDetector(
            onTap: () => Navigator.pop(context, null),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Color(0xFFC0392B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? const Color(0xFFC0392B);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEAEAEA),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCCCCCC)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }
}
