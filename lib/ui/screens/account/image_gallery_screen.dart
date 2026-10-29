import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/utils/image_urls.dart';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({
    super.key,
    required this.images,
    required this.title,
    this.initialImage,
    this.loadImages,
  });
  final List<String> images;
  final String title;
  final String? initialImage;
  final Future<List<String>> Function()? loadImages;
  static Future<void> show(
    BuildContext context, {
    required List<String> images,
    required String title,
    String? initialImage,
    Future<List<String>> Function()? loadImages,
  }) => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => ImageGalleryScreen(
        images: images,
        title: title,
        initialImage: initialImage,
        loadImages: loadImages,
      ),
    ),
  );
  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late List<String> _images;
  late PageController _pages;
  int _index = 0;
  bool _loading = false;
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    _images = uniqueImageUrls(widget.images);
    final index = _images.indexOf(widget.initialImage ?? '');
    _index = index < 0 ? 0 : index;
    _pages = PageController(initialPage: _index);
    if (widget.loadImages != null) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final images = await widget.loadImages!();
      if (mounted) {
        setState(() => _images = uniqueImageUrls([..._images, ...images]));
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Fechar fotos',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(color: Color(0xFFC0392B)),
          if (_failed)
            TextButton(
              onPressed: _load,
              child: const Text(
                'Não foi possível carregar todas as fotos. Tentar novamente',
                style: TextStyle(color: Colors.white),
              ),
            ),
          Expanded(
            child: _images.isEmpty
                ? Center(
                    child: Text(
                      _loading
                          ? 'Carregando fotos…'
                          : 'Nenhuma foto cadastrada.',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                : PageView.builder(
                    controller: _pages,
                    itemCount: _images.length,
                    onPageChanged: (index) => setState(() => _index = index),
                    itemBuilder: (context, index) => InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Center(
                        child: Image(
                          image: _image(_images[index]),
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                          errorBuilder: (_, _, _) => const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white70,
                                size: 48,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Não foi possível carregar esta foto.',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
          if (_images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${_index + 1} de ${_images.length} · Deslize para ver mais fotos',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    ),
  );
  ImageProvider _image(String url) => url.startsWith('data:image')
      ? MemoryImage(base64Decode(url.split(',').last))
      : NetworkImage(url);
}
