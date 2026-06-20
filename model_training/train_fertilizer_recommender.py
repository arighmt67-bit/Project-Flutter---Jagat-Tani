"""
Train a small fertilizer recommendation model on tabular data and export TFLite.

This script is a template that expects a CSV with columns such as:
- temperatureC, humidity, soil_N, soil_P, soil_K, growth_stage (optional), target_N, target_P, target_K

It trains a simple feed-forward model to predict recommended N,P,K values given inputs.
"""

import os
import argparse
import pandas as pd
import numpy as np
import tensorflow as tf
from tensorflow import keras
from sklearn.model_selection import train_test_split


def build_model(n_inputs, n_outputs):
    inputs = keras.Input(shape=(n_inputs,))
    x = keras.layers.Dense(64, activation='relu')(inputs)
    x = keras.layers.Dense(32, activation='relu')(x)
    outputs = keras.layers.Dense(n_outputs, activation='linear')(x)
    model = keras.Model(inputs, outputs)
    model.compile(optimizer='adam', loss='mse', metrics=['mae'])
    return model


def convert_to_tflite(keras_model_path, output_tflite_path):
    model = tf.keras.models.load_model(keras_model_path)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    # You may add quantization here if desired
    tflite_model = converter.convert()
    with open(output_tflite_path, 'wb') as f:
        f.write(tflite_model)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--csv', required=True)
    parser.add_argument('--output_dir', required=True)
    parser.add_argument('--test_size', type=float, default=0.2)
    parser.add_argument('--epochs', type=int, default=50)
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)

    df = pd.read_csv(args.csv)

    # Example: assume target columns are 'target_N','target_P','target_K'
    target_cols = [c for c in df.columns if c.startswith('target_')]
    if not target_cols:
        raise RuntimeError('CSV must contain target columns starting with "target_"')

    # Features are all other numeric columns
    feature_cols = [c for c in df.columns if c not in target_cols]

    X = df[feature_cols].values.astype('float32')
    y = df[target_cols].values.astype('float32')

    X_train, X_val, y_train, y_val = train_test_split(X, y, test_size=args.test_size, random_state=42)

    model = build_model(X_train.shape[1], y_train.shape[1])
    callbacks = [keras.callbacks.EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True)]

    model.fit(X_train, y_train, validation_data=(X_val, y_val), epochs=args.epochs, callbacks=callbacks, batch_size=32)

    keras_path = os.path.join(args.output_dir, 'fertilizer_model.h5')
    model.save(keras_path)
    print('Saved Keras model to', keras_path)

    tflite_path = os.path.join(args.output_dir, 'fertilizer_model.tflite')
    convert_to_tflite(keras_path, tflite_path)
    print('Saved TFLite model to', tflite_path)


if __name__ == '__main__':
    main()
