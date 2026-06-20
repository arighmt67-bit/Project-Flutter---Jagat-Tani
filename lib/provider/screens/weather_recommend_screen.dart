import 'package:flutter/material.dart';
import '../../service/weather_service.dart';
import '../../service/fertilizer_recommendation_service.dart';

class WeatherRecommendScreen extends StatefulWidget {
  const WeatherRecommendScreen({super.key});

  @override
  State<WeatherRecommendScreen> createState() => _WeatherRecommendScreenState();
}

class _WeatherRecommendScreenState extends State<WeatherRecommendScreen> {
  final WeatherService _weatherService = WeatherService();
  final FertilizerRecommendationService _fertService =
      FertilizerRecommendationService();

  bool _loading = true;
  String? _error;
  String? _recommendation;
  Map<String, dynamic>? _weather;

  // sementara hardcode koordinat Bandung
  final double _lat = -6.914744;
  final double _lon = 107.60981;

  @override
  void initState() {
    super.initState();
    _loadRecommendation();
  }

  Future<void> _loadRecommendation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final w = await _weatherService.getWeather(lat: _lat, lon: _lon);

      final tempC = (w["main"]["temp"] as num).toDouble();
      final hum = (w["main"]["humidity"] as num).toInt();
      final mainCond = (w["weather"][0]["main"]).toString();

      final rec = _fertService.buildRecommendation(
        temperatureC: tempC,
        humidity: hum,
        weatherMain: mainCond,
      );

      setState(() {
        _weather = w;
        _recommendation = rec;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text("Error: $_error"));
    }

    if (_weather == null || _recommendation == null) {
      return const Center(child: Text("Data tidak tersedia"));
    }

    final temp = _weather!["main"]["temp"];
    final hum = _weather!["main"]["humidity"];
    final cond = _weather!["weather"][0]["main"];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cuaca Saat Ini",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text("Suhu: $temp°C"),
              Text("Kelembapan: $hum%"),
              Text("Kondisi: $cond"),
              const SizedBox(height: 16),
              const Text(
                "Rekomendasi Pupuk & Pola Tanam",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(_recommendation!),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadRecommendation,
                child: const Text("Refresh Data Cuaca"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rekomendasi Pupuk & Pola Tanam (Cuaca)"),
      ),
      body: _buildBody(),
    );
  }
}
