from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse
from inference import predict

from pathlib import Path
import shutil
import json

app = FastAPI()

UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)


@app.api_route("/", methods=["GET", "HEAD"])
def root():
    return JSONResponse(
        {"message": "SkinBuddy API running"}
    )


@app.post("/predict")
async def predict_image(
    file: UploadFile = File(...),
    metadata: str = Form(...)
):

    metadata_dict = json.loads(metadata)

    file_path = UPLOAD_DIR / file.filename

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    result = predict(
        image_path=str(file_path),
        metadata=metadata_dict,
    )

    return result