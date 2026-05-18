# ML Pipeline

## Objective
Train a lightweight classifier using transfer learning and export it to TFLite
for on-device inference in Flutter.

## Training Steps
1. Place class-labeled images under `ml/data/<class_name>/...`.
2. Run training script:
   - `python src/train.py`
3. The script performs:
   - train/validation split (80/20),
   - MobileNetV2 transfer learning,
   - early stopping and best-checkpoint saving,
   - validation evaluation,
   - classification report + confusion matrix printing.
4. Export to TFLite:
   - `python src/convert_to_tflite.py`

## Artifacts
- SavedModel: `ml/models/saved_model`
- Best Keras checkpoint: `ml/models/best_model.keras`

## Notes for Coders
- Keep training preprocessing aligned with mobile preprocessing.
- If classes change, regenerate model and re-test triage thresholds.

## Recommended Evaluation Gate
Before shipping a new model:
- Validate no class collapse in confusion matrix.
- Ensure infection-like classes have acceptable recall.
- Confirm low-confidence fallback still behaves conservatively.
