
# Proyek Rekomendasi Pupuk Padi

Ini adalah proyek model Machine Learning (Deep Learning) untuk merekomendasikan jenis pupuk yang sesuai untuk tanaman padi berdasarkan berbagai parameter tanah dan lingkungan.

## Dataset
Dataset yang digunakan berisi data parameter seperti Suhu, Kelembaban, Kelembaban Tanah, Jenis Tanah, Nitrogen, Kalium, Fosfor, dan Jenis Pupuk yang digunakan untuk tanaman padi.

## Data Preprocessing
Data dilakukan preprocessing meliputi:
- Filtering data hanya untuk 'Crop Type' = 'Paddy'.
- Menghapus kolom yang tidak relevan ('id', 'Crop Type').
- Scaling fitur numerik menggunakan `StandardScaler`.
- One-Hot Encoding fitur kategorikal ('Soil Type').
- Label Encoding target ('Fertilizer Name').
- Split data menjadi Training (80%) dan Validation (20%) dengan stratifikasi.

## Arsitektur Model
Model menggunakan arsitektur Sequential Deep Learning dengan layer:
- Input Layer (sesuai jumlah fitur setelah preprocessing)
- Dense Layer (128 unit, aktivasi 'relu', dengan Dropout 0.4)
- Dense Layer (64 unit, aktivasi 'relu', dengan Dropout 0.2)
- Output Layer (sesuai jumlah kelas pupuk, aktivasi 'softmax')

Model dikompilasi menggunakan optimizer 'adam' dan loss 'sparse_categorical_crossentropy'. Digunakan callback `EarlyStopping` dengan `patience=15` dan `restore_best_weights=True`.

## Hasil Pelatihan dan Evaluasi
(Bagian ini dapat diisi manual setelah menjalankan notebook)
*   **Jumlah Epoch Terbaik:** (Akan diisi)
*   **Loss Training (Epoch Terbaik):** (Akan diisi)
*   **Akurasi Training (Epoch Terbaik):** (Akan diisi)
*   **Loss Validasi (Epoch Terbaik):** 1.9407
*   **Akurasi Validasi:** 16.03%
*   **Classification Report:** (Akan dilampirkan atau dijelaskan secara manual)

## File Model yang Dihasilkan
Proyek ini menghasilkan model dalam format TF-Lite:
*   **TF-Lite:** `fertilizer_paddy_model.tflite`

## Cara Penggunaan (Inferensi)
(Bagian ini dapat menjelaskan cara memuat model TFLite dan melakukan prediksi menggunakan data input baru)
