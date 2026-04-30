import 'package:flutter/material.dart';

Future<void> showSuccessDialog(
  BuildContext context,
  String message,
) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle,
                    color: Colors.white, size: 50),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  await Future.delayed(const Duration(seconds: 2));

  if (context.mounted) {
    Navigator.pop(context);
  }
}