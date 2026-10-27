import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool showBackButton;
  final VoidCallback? onBack;
  final VoidCallback? onFilter;
  final bool filterActive;

  const SearchWidget({
    super.key,
    required this.controller,
    this.hintText = 'Procure por produto ou corte',
    this.onChanged,
    this.onSubmitted,
    this.showBackButton = false,
    this.onBack,
    this.onFilter,
    this.filterActive = false,
  });

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          if (showBackButton) ...[
            GestureDetector(
              onTap: onBack ?? () => Navigator.maybePop(context),
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black54,
                  size: 20,
                ),
              ),
            ),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.black87, fontSize: 14),
              cursorColor: _red,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),

                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.black38,
                  size: 20,
                ),
                suffixIcon: ValueListenableBuilder(
                  valueListenable: controller,
                  builder: (_, value, _) => value.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.black38,
                            size: 18,
                          ),
                          onPressed: () {
                            controller.clear();
                            onChanged?.call('');
                          },
                        )
                      : const SizedBox.shrink(),
                ),
                filled: true,
                fillColor: const Color(0xFFE0E0E0),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (onFilter != null) ...[
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: filterActive ? 'Alterar filtros ativos' : 'Abrir filtros',
              child: IconButton(
                onPressed: onFilter,
                style: IconButton.styleFrom(
                  fixedSize: const Size(44, 44),
                  backgroundColor: filterActive
                      ? _red
                      : const Color(0xFFE0E0E0),
                  foregroundColor: filterActive ? Colors.white : Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  filterActive ? Icons.filter_alt : Icons.filter_alt_outlined,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
