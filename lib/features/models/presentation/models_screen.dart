import 'package:flutter/material.dart';

class ModelsScreen extends StatelessWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Models')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No models installed. Use the Store tab to download a model.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
