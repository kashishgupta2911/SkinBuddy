# SkinBuddy Overview

SkinBuddy is a mobile triage support application for skin-condition screening.
It classifies a captured image into known classes and then returns a conservative
triage recommendation: `URGENT` or `NON-URGENT`.

Important safety note:
- SkinBuddy is a triage aid, not a diagnostic tool.
- The app must always present clear medical disclaimers.
- Low-confidence predictions escalate to urgent by design.

## Product Intent
- Platforms: Android + iOS (single Flutter codebase)
- ML runtime: on-device TensorFlow Lite (offline capable)
- Training stack: Python + TensorFlow
- Data backend: Firebase (Firestore + Auth), privacy-first records

## Scope of v1
- Capture photo from camera or gallery
- Run on-device model inference
- Apply triage rules with confidence thresholds
- Save triage metadata to Firestore (no image upload by default)
- Display triage rationale and disclaimer in result screen

## Out of Scope for v1
- Medical diagnosis
- Treatment recommendations
- Automatic image storage to cloud by default
