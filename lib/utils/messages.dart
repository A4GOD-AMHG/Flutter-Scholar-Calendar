import 'package:flutter/material.dart';
import 'package:get/get.dart';

///[showSuccess] muestra un [SnackBar] de éxito; sobrevive a la navegación porque
///el [ScaffoldMessenger] es el de la aplicación
void showSuccess(String message) => _show(message, error: false);

///[showError] muestra un [SnackBar] de error
void showError(String message) => _show(message, error: true);

void _show(String message, {required bool error}) {
  final context = Get.context;
  if (context == null) return;
  final scheme = Theme.of(context).colorScheme;
  final background = error ? scheme.error : const Color(0xFF2E7D32);
  final foreground = error ? scheme.onError : Colors.white;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: background,
      content: Row(
        children: [
          Icon(
            error ? Icons.error_outline : Icons.check_circle_outline,
            color: foreground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: foreground)),
          ),
        ],
      ),
    ),
  );
}
