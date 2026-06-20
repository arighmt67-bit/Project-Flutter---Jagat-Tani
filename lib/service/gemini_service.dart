import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static Future<Map<String, String>> getNutrition(String foodName) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final model = GenerativeModel(
      model: 'models/gemini-2.5-flash',
      apiKey: apiKey,
    );
    final prompt = '''
Berikan informasi nutrisi (kalori, karbohidrat, lemak, serat, protein) untuk makanan: $foodName dalam format JSON.
Contoh: {"Kalori":"xxx","Karbohidrat":"xxx","Lemak":"xxx","Serat":"xxx","Protein":"xxx"}
''';
    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text ?? '';
    final jsonStart = text.indexOf('{');
    final jsonEnd = text.lastIndexOf('}');
    if (jsonStart != -1 && jsonEnd != -1) {
      final jsonString = text.substring(jsonStart, jsonEnd + 1);
      final Map<String, dynamic> data = json.decode(jsonString);
      return data.map((k, v) => MapEntry(k, v.toString()));
    }
    return {};
  }
}
