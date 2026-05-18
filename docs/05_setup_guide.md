# Setup Guide

## Prerequisites
- Flutter SDK (stable)
- Python 3.10+
- Xcode (for iOS builds on macOS)
- Android Studio + Android SDK
- Firebase project (Spark/free tier is enough for v1)

## Mobile Setup
1. Open project root and run:
   - `flutter pub get`
2. Add Firebase app configs:
   - Android: `google-services.json`
   - iOS: `GoogleService-Info.plist`
3. Initialize Firebase project for Flutter if needed:
   - `flutterfire configure`
4. Run app:
   - `flutter run`

## ML Setup
1. Enter ML directory:
   - `cd ml`
2. Install dependencies:
   - `pip install -r requirements.txt`
3. Train:
   - `python src/train.py`
4. Convert:
   - `python src/convert_to_tflite.py`

## Firestore Setup
- Enable Authentication -> Anonymous provider.
- Create Firestore database in production mode with proper rules.
- Ensure app has write access to:
  - `users/{uid}/triage_records/{recordId}`

## Verification Checklist
- App launches on Android and iOS.
- Image capture/gallery selection works.
- Result screen shows class, confidence, triage, reason, disclaimer.
- Firestore receives triage records after analysis.
