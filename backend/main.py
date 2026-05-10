from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
from inference import predict

from pathlib import Path
import shutil

app = FastAPI()

UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)


@app.api_route("/", methods=["GET", "HEAD"])
def root():
    return JSONResponse(
        {"message": "SkinBuddy API running"}
    )


@app.post("/predict")
async def predict_image(file: UploadFile = File(...)):

    file_path = UPLOAD_DIR / file.filename

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    result = predict(str(file_path))

    return result