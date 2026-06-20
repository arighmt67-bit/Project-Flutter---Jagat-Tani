import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../padi_classifier_provider.dart';
import 'result_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _capturedFile;

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;

    final file = File(picked.path);
    setState(() {
      _capturedFile = file;
    });

    final provider = Provider.of<PadiClassifierProvider>(
      context,
      listen: false,
    );

    await provider.classifyImage(file);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResultScreen(imageFile: file)),
    );
  }

  @override
  void initState() {
    super.initState();
    // pastikan model sudah diload
    final provider = Provider.of<PadiClassifierProvider>(
      context,
      listen: false,
    );
    provider.initModel();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PadiClassifierProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Deteksi Penyakit Daun Padi")),
      body: Center(
        child:
            provider.modelReady
                ? ElevatedButton.icon(
                  onPressed: provider.isPredicting ? null : _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    provider.isPredicting ? "Menganalisis..." : "Ambil Foto",
                  ),
                )
                : const CircularProgressIndicator(),
      ),
    );
  }
}
