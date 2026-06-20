import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../padi_classifier_provider.dart';
import '../models/prediction_result.dart';

class ResultScreen extends StatelessWidget {
  final File imageFile;

  const ResultScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PadiClassifierProvider>(context);
    final data = provider.result;

    if (data == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Hasil Deteksi")),
        body: const Center(child: Text("Belum ada hasil prediksi.")),
      );
    }

    final confidencePercent = (data.confidence * 100).toStringAsFixed(
      2,
    ); // ex: "91.23"

    return Scaffold(
      appBar: AppBar(title: const Text("Hasil Deteksi")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(imageFile),
            ),
            const SizedBox(height: 16),

            Text(
              "Deteksi: ${data.label}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              "Confidence: $confidencePercent%",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),
            const Text(
              "Saran Penanganan Awal: ",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(data.recommendation),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // kembali ke kamera
              },
              child: const Text("Ambil Foto Lagi"),
            ),
          ],
        ),
      ),
    );
  }
}
