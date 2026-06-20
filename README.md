## Jagat Tani - Project Notes

Jagat Tani adalah aplikasi mobile berbasis Flutter yang menerapkan ML on-device (TensorFlow Lite) untuk deteksi penyakit daun padi dan rekomendasi pemupukan berbasis cuaca.

Model dan dataset:

- Dataset Deteksi Penyakit Padi: https://www.kaggle.com/datasets/minhhuy2810/rice-diseases-image-dataset/data
- Dataset Rekomendasi Pupuk: https://www.kaggle.com/datasets/shankarpriya2913/crop-and-soil-dataset/data
- Model (team ML): https://drive.google.com/drive/folders/1WJDjgki_Oe4YtFWXf-QESfa5yDlA0mcS

Library / external APIs yang digunakan:

- tflite_flutter (on-device inference) — menangani pemuatan model dan inference
- image (image preprocessing)
- camera / image_picker (mengambil foto dari perangkat)
- OpenWeatherMap API (digunakan oleh service rekomendasi cuaca)

Assets model disimpan di `assets/models/model_padi.tflite` dan label di `assets/models/labels.txt`.

Jika Anda ingin mengganti model:

1. Ganti file TFLite di `assets/models/` dan perbarui `labels.txt`.
2. Pastikan ukuran input model (mis. 224x224) di-handle oleh pre-processing. Service `PadiClassifierService` mencoba membaca bentuk input dari model secara otomatis.
3. Jalankan `flutter pub get` lalu build aplikasi.
