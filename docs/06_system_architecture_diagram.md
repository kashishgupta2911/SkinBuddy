# SkinBuddy System Architecture Diagram

```mermaid
flowchart LR
  subgraph mobileApp [FlutterMobileApp]
    captureUI[CaptureScreen]
    captureController[CaptureController]
    inferenceService[InferenceServiceTFLite]
    triageLogic[TriageLogic]
    resultUI[ResultScreen]
    recordService[TriageRecordService]
  end

  subgraph onDeviceML [OnDeviceML]
  end

  subgraph firebaseBackend [FirebaseBackend]
    auth[FirebaseAuthAnonymous]
    firestore["Firestore users_uid_triage_records"]
    storage[FirebaseStorageOptional]
  end

  subgraph mlPipeline [PythonMLPipeline]
    dataset[SkinImageDataset]
    trainer["train.py MobileNetV2"]
    converter["convert_to_tflite.py"]
    artifacts[SavedModelAndTFLiteArtifacts]
  end

  user[User] -->|CaptureOrUploadImage| captureUI
  captureUI --> captureController
  captureController --> inferenceService
  inferenceService --> tfliteModel
  inferenceService --> labelsTxt
  inferenceService -->|PredictionAndConfidence| triageLogic
  triageLogic -->|UrgentOrNonUrgent| resultUI
  captureController -->|PersistTriageMetadata| recordService
  recordService --> auth
  recordService --> firestore
  recordService -->|OnlyIfConsent| storage

  dataset --> trainer
  trainer --> artifacts
  artifacts --> converter
  converter --> tfliteModel
```

## Notes
- Inference runs on device by default for privacy and offline support.
- Firestore stores triage metadata, not diagnosis.
- Image storage is optional and should require explicit consent.
- Low-confidence outputs should escalate to urgent by triage policy.
