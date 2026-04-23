import tensorflow as tf
import numpy as np
from sklearn.metrics import classification_report, confusion_matrix
from data_loader import load_data, SEED

DATA_DIR = "../data"
MODEL_DIR = "../models"
EPOCHS = 10

def build_model(num_classes):
    tf.random.set_seed(SEED)
    base = tf.keras.applications.MobileNetV2(
        input_shape=(224,224,3),
        include_top=False,
        weights="imagenet"
    )
    base.trainable = False

    x = base.output
    x = tf.keras.layers.GlobalAveragePooling2D()(x)
    outputs = tf.keras.layers.Dense(num_classes, activation="softmax")(x)

    inputs = tf.keras.Input(shape=(224, 224, 3))
    x = tf.keras.applications.mobilenet_v2.preprocess_input(inputs * 255.0)
    x = base(x, training=False)
    x = tf.keras.layers.GlobalAveragePooling2D()(x)
    outputs = tf.keras.layers.Dense(num_classes, activation="softmax")(x)

    model = tf.keras.Model(inputs=inputs, outputs=outputs)
    model.compile(optimizer="adam", loss="sparse_categorical_crossentropy", metrics=["accuracy"])
    return model

def main():
    train_ds, val_ds, class_names = load_data(DATA_DIR)
    model = build_model(len(class_names))

    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor="val_loss",
            patience=2,
            restore_best_weights=True
        ),
        tf.keras.callbacks.ModelCheckpoint(
            filepath=f"{MODEL_DIR}/best_model.keras",
            monitor="val_accuracy",
            save_best_only=True
        ),
    ]

    model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=EPOCHS,
        callbacks=callbacks
    )

    loss, accuracy = model.evaluate(val_ds, verbose=0)
    print(f"Validation loss: {loss:.4f}")
    print(f"Validation accuracy: {accuracy:.4f}")

    y_true = []
    y_pred = []
    for x_batch, y_batch in val_ds:
        probs = model.predict(x_batch, verbose=0)
        y_pred.extend(np.argmax(probs, axis=1).tolist())
        y_true.extend(y_batch.numpy().tolist())

    print("Classification report:")
    print(classification_report(y_true, y_pred, target_names=class_names, digits=4))
    print("Confusion matrix:")
    print(confusion_matrix(y_true, y_pred))

    model.save(f"{MODEL_DIR}/saved_model")

if __name__ == "__main__":
    main()
