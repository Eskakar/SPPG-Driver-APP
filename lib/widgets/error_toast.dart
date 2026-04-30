import 'package:flutter/material.dart';

void showErrorToast(BuildContext context, String message, {Color? colorBackground, Color? colorText}) {
  final overlay = Overlay.of(context);
  final warnaBackground = colorBackground ?? Colors.red;
  final warnaText = colorText ?? Colors.white;
  final overlayEntry = OverlayEntry(
    builder: (_) => Positioned(
      top: 60,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: warnaBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            style: TextStyle(color: warnaText),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}