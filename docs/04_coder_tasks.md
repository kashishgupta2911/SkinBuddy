# Coder Task Board

## Mobile Tasks
- Integrate generated Firebase config files for Android/iOS.
- Add runtime permission handling for camera/gallery UX.
- Add retry/empty-state UX on failed analysis or network write failure.
- Add localization support for triage/disclaimer text.

## ML Tasks
- Add class imbalance handling (augmentation or weighted loss) if needed.
- Export validation metrics to file for model registry history.

## Safety and Compliance Tasks
- Add consent screen before storing any image-linked metadata.
- Add emergency guidance copy reviewed by clinical advisor.
- Add in-app link to privacy policy and terms.

## Testing Tasks
- Unit tests for `TriageLogic` threshold and urgent label mapping.
- Integration test for full capture -> inference -> result flow.
- Firestore write test for triage record schema.
