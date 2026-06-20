import 'package:flutter/material.dart';
import 'package:jagat_tani/widget/menu_card.dart';
import 'camera_screen.dart';
import 'weather_recommend_screen.dart';
import '../widgets/menu_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jagat Tani")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MenuCard(
              title: "Deteksi Penyakit Daun Padi",
              description:
                  "Foto daun padi → klasifikasi penyakit (blas, hawar daun bakteri, bercak coklat) + saran awal.",
              icon: Icons.biotech,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CameraScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            MenuCard(
              title: "Rekomendasi Pupuk & Pola Tanam",
              description:
                  "Gunakan data cuaca harian untuk rekomendasi pemupukan dan waktu tanam yang lebih aman.",
              icon: Icons.grass,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WeatherRecommendScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}