# Model training helpers for Jagat Tani

This folder contains example training scripts to produce the two models you asked for:

1. Rice disease image classifier -> TensorFlow Lite
2. Rice fertilizer recommendation model (tabular) -> TensorFlow Lite

These scripts are templates. You should run them in a Python environment (recommended: conda/venv) and point them to the datasets you have (Kaggle links or your team's Drive folders).

Requirements (example):

```sh
pip install -r requirements.txt
```

Files

- `train_rice_disease_classifier.py` — trains an image classifier (transfer learning) and exports a TFLite model and `labels.txt`.
- `train_fertilizer_recommender.py` — trains a small feed-forward model on tabular data (N,P,K,weather,...) and converts to TFLite.
- `requirements.txt` — Python packages used for training.

Quick workflow (image model)

1. Download and extract the rice disease dataset to `data/rice_diseases/train/` with subfolders per class (use the Kaggle dataset or the Drive link). The folder layout expected by the script is:

```
data/rice_diseases/train/BacterialLeafBlight/...
data/rice_diseases/train/BrownSpot/...
...etc
```

2. Run training:

```sh
python train_rice_disease_classifier.py --data_dir data/rice_diseases --output_dir output/disease_model
```

3. After training, copy `output/disease_model/model_padi.tflite` and `output/disease_model/labels.txt` into your Flutter project's `assets/models/`.

Quick workflow (fertilizer model)

1. Prepare CSV with features and target (example columns: temperatureC, humidity, soil_N, soil_P, soil_K, growth_stage, recommended_N, recommended_P, recommended_K).
2. Run training:

```sh
python train_fertilizer_recommender.py --csv data/fertilizer/dataset.csv --output_dir output/fertilizer_model
```

3. Copy `output/fertilizer_model/fertilizer_model.tflite` to `assets/models/` and load it in the app (the app contains a stub `FertilizerRecommendationService` to add model inference later).

Notes and next steps

- These scripts use transfer learning (MobileNetV2) for speed on moderate GPUs/TPUs. For deployment to on-device inference, they export a TFLite model with optional float16 or full integer quantization.
- You must verify label order in `labels.txt` matches the model output indices. The image script writes labels in sorted class order (alphabetical) by default — check your model training target order and change code if needed.
- If your ML team already produced TFLite models, you can skip training and simply place their `.tflite` and `labels.txt` in `assets/models/`.

If you want, I can also:

- Run a local experiment and provide concrete hyperparameters and expected metrics (if you share a sample of the dataset), or
- Modify the Flutter `PadiClassifierService` to handle quantized outputs or a specific input shape the model needs.
