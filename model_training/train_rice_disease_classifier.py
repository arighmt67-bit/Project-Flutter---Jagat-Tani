"""
Train a rice disease image classifier (transfer learning) and export a TFLite model.

Usage example:
python train_rice_disease_classifier.py --data_dir data/rice_diseases --output_dir output/disease_model --img_size 224 --epochs 10

Expect dataset layout:
data/rice_diseases/train/<class_name>/*.jpg
data/rice_diseases/val/<class_name>/*.jpg  (optional)

The script will write:
- {output_dir}/model.h5
- {output_dir}/model_padi.tflite
- {output_dir}/labels.txt
"""

import os
import argparse
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import numpy as np


def build_dataset(data_dir, img_size, batch_size):
    train_dir = os.path.join(data_dir, 'train')
    val_dir = os.path.join(data_dir, 'val')

    train_ds = tf.keras.preprocessing.image_dataset_from_directory(
        train_dir,
        labels='inferred',
        label_mode='int',
        image_size=(img_size, img_size),
        batch_size=batch_size,
        shuffle=True,
    )

    if os.path.exists(val_dir):
        val_ds = tf.keras.preprocessing.image_dataset_from_directory(
            val_dir,
            labels='inferred',
            label_mode='int',
            image_size=(img_size, img_size),
            batch_size=batch_size,
            shuffle=False,
        )
    else:
        val_ds = None

    class_names = train_ds.class_names

    return train_ds, val_ds, class_names


def build_model(img_size, num_classes):
    base_model = tf.keras.applications.MobileNetV2(
        input_shape=(img_size, img_size, 3),
        include_top=False,
        weights='imagenet')
    base_model.trainable = False

    inputs = keras.Input(shape=(img_size, img_size, 3))
    x = tf.keras.applications.mobilenet_v2.preprocess_input(inputs)
    x = base_model(x, training=False)
    x = layers.GlobalAveragePooling2D()(x)
    x = layers.Dropout(0.2)(x)
    outputs = layers.Dense(num_classes, activation='softmax')(x)
    model = keras.Model(inputs, outputs)
    return model


def convert_to_tflite(keras_model_path, output_tflite_path, quantize=False):
    model = tf.keras.models.load_model(keras_model_path)

    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    if quantize:
        # Post-training float16 quantization (good tradeoff for mobile)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.float16]
    tflite_model = converter.convert()
    with open(output_tflite_path, 'wb') as f:
        f.write(tflite_model)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--data_dir', required=True)
    parser.add_argument('--output_dir', required=True)
    parser.add_argument('--img_size', type=int, default=224)
    parser.add_argument('--batch_size', type=int, default=32)
    parser.add_argument('--epochs', type=int, default=8)
    parser.add_argument('--quantize', action='store_true', help='Use float16 quantization when converting to TFLite')
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)

    train_ds, val_ds, class_names = build_dataset(args.data_dir, args.img_size, args.batch_size)

    AUTOTUNE = tf.data.AUTOTUNE
    train_ds = train_ds.prefetch(buffer_size=AUTOTUNE)
    if val_ds is not None:
        val_ds = val_ds.prefetch(buffer_size=AUTOTUNE)

    model = build_model(args.img_size, len(class_names))
    model.compile(optimizer=keras.optimizers.Adam(learning_rate=1e-4),
                  loss='sparse_categorical_crossentropy',
                  metrics=['accuracy'])

    callbacks = [
        keras.callbacks.ModelCheckpoint(os.path.join(args.output_dir, 'model.h5'), save_best_only=True, monitor='val_accuracy'),
        keras.callbacks.EarlyStopping(monitor='val_accuracy', patience=3, restore_best_weights=True)
    ]

    if val_ds is not None:
        history = model.fit(train_ds, validation_data=val_ds, epochs=args.epochs, callbacks=callbacks)
    else:
        history = model.fit(train_ds, epochs=args.epochs, callbacks=callbacks)

    # Save best model path
    best_model_path = os.path.join(args.output_dir, 'model.h5')
    print('Saved Keras model to', best_model_path)

    # Save labels (class_names) in order
    labels_path = os.path.join(args.output_dir, 'labels.txt')
    with open(labels_path, 'w') as f:
        for c in class_names:
            f.write(c + '\n')
    print('Saved labels to', labels_path)

    # Convert to TFLite
    tflite_path = os.path.join(args.output_dir, 'model_padi.tflite')
    convert_to_tflite(best_model_path, tflite_path, quantize=args.quantize)
    print('Converted and saved TFLite model to', tflite_path)


if __name__ == '__main__':
    main()
