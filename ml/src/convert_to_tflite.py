import tensorflow as tf
from pathlib import Path

SAVED_MODEL_DIR = Path("../models/saved_model")
OUTPUT_PATH = Path("../models/model.tflite")
ENABLE_QUANTIZATION = True

def main():
    if not SAVED_MODEL_DIR.exists():
        raise FileNotFoundError(f"SavedModel not found: {SAVED_MODEL_DIR.resolve()}")

    converter = tf.lite.TFLiteConverter.from_saved_model(str(SAVED_MODEL_DIR))
    if ENABLE_QUANTIZATION:
        converter.optimizations = [tf.lite.Optimize.DEFAULT]

    tflite_model = converter.convert()
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_bytes(tflite_model)

    if not OUTPUT_PATH.exists() or OUTPUT_PATH.stat().st_size == 0:
        raise RuntimeError("TFLite export failed: empty output file.")

    print(f"TFLite model exported at: {OUTPUT_PATH.resolve()}")
    print(f"File size (bytes): {OUTPUT_PATH.stat().st_size}")

if __name__ == "__main__":
    main()
