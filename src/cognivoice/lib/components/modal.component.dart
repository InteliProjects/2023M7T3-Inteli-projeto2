import 'package:flutter/material.dart';

class ModalLoadingOverlay extends StatelessWidget {
  const ModalLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.75), // Semi-transparent background
      child: const Center(
        child: CircularProgressIndicator(), // Progress indicator
      ),
    );
  }
}
