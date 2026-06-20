import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherService {
  /// Fetch current weather from OpenWeatherMap for given coordinates.
  /// Requires environment variable OWM_API_KEY to be set (use .env).
  Future<Map<String, dynamic>> getWeather({
    required double lat,
    required double lon,
  }) async {
    final apiKey = dotenv.env['OWM_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'OpenWeatherMap API key not configured. Set OWM_API_KEY in .env',
      );
    }

    final url = Uri.https('api.openweathermap.org', '/data/2.5/weather', {
      'lat': lat.toString(),
      'lon': lon.toString(),
      'appid': apiKey,
      'units': 'metric',
    });

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception(
        'Weather API error: ${res.statusCode} ${res.reasonPhrase}',
      );
    }

    return json.decode(res.body) as Map<String, dynamic>;
  }
}
