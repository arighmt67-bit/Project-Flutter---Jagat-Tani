class FertilizerRecommendationService {
  String buildRecommendation({
    required double temperatureC,
    required int humidity,
    required String weatherMain,
  }) {
    // Contoh aturan awal (baseline):
    if (weatherMain == "Rain" || weatherMain == "Thunderstorm") {
      return "Saat hujan lebat, tunda pemupukan nitrogen tinggi karena rentan hanyut. Fokus perbaikan drainase dan pengecekan kondisi tanah.";
    }

    if (temperatureC >= 32 && humidity < 50) {
      return "Suhu tinggi dan kelembaban rendah. Prioritaskan pupuk tinggi kalium untuk ketahanan stres panas, batasi nitrogen berlebih.";
    }

    if (temperatureC >= 25 && temperatureC <= 30) {
      return "Kondisi relatif stabil. Anda bisa melakukan pemupukan NPK seimbang untuk fase vegetatif padi dan pantau kelembaban tanah.";
    }

    return "Gunakan dosis pupuk moderat. Pantau cuaca harian sebelum aplikasi dosis besar dan sesuaikan jadwal tanam dengan prakiraan cuaca.";
  }
}