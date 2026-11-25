import 'package:flutter/material.dart';

/// Shared composer for order conversations and the recipe assistant.
class MessageComposer extends StatelessWidget {
  const MessageComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.onChanged,
    this.onStop,
    this.onRetry,
    this.enabled = true,
    this.busy = false,
    this.hint = 'Escreva uma mensagem...',
    this.maxLength,
  });
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onStop;
  final VoidCallback? onRetry;
  final bool enabled;
  final bool busy;
  final String hint;
  final int? maxLength;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF2E2E2E),
    child: SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onRetry != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFFA99F),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tentar novamente'),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  onChanged: onChanged,
                  minLines: 1,
                  maxLines:
                      MediaQuery.sizeOf(context).height -
                              View.of(context).viewInsets.bottom /
                                  View.of(context).devicePixelRatio <
                          360
                      ? 2
                      : 4,
                  maxLength: maxLength,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  cursorColor: const Color(0xFFFFA99F),
                  scrollPadding: const EdgeInsets.all(20),
                  decoration: InputDecoration(
                    hintText: hint,
                    counterText: '',
                    hintStyle: const TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF3A3A3A),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFF555555)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFF555555)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0xFFC0392B),
                        width: 1.5,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFF444444)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final canStop = busy && onStop != null;
                  final canSend =
                      enabled && !busy && value.text.trim().isNotEmpty;
                  return SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton.filled(
                      tooltip: canStop
                          ? 'Interromper resposta'
                          : busy
                          ? 'Enviando mensagem'
                          : 'Enviar mensagem',
                      onPressed: canStop
                          ? onStop
                          : canSend
                          ? onSend
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFC0392B),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF444444),
                        disabledForegroundColor: Colors.white38,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: busy && !canStop
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white70,
                              ),
                            )
                          : Icon(
                              canStop ? Icons.stop_rounded : Icons.send_rounded,
                              size: 22,
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
