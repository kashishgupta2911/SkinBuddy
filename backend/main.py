from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse
from inference import predict

from pathlib import Path
import shutil
import json

app = FastAPI()

UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

RELATED_CATEGORY_MAP = {
    "Acne": "ACNE",
    "Growth or Mole": "GROWTH_OR_MOLE",
    "Hair Loss": "HAIR_LOSS",
    "Other Hair Problem": "OTHER_HAIR_PROBLEM",
    "Nail Problem": "NAIL_PROBLEM",
    "Pigmentary Problem": "PIGMENTARY_PROBLEM",
    "Rash": "RASH",
    "Looks Healthy": "LOOKS_HEALTHY",
    "Other": "OTHER_ISSUE_DESCRIPTION",
}

SYMPTOM_MAP = {
    "Bleeding": "condition_symptoms_bleeding",
    "Increasing size": "condition_symptoms_increasing_size",
    "Darkening": "condition_symptoms_darkening",
    "Itching": "condition_symptoms_itching",
    "Burning": "condition_symptoms_burning",
    "Pain": "condition_symptoms_pain",
    "Bothersome appearance":
        "condition_symptoms_bothersome_appearance",
}

OTHER_SYMPTOM_MAP = {
    "Fever": "other_symptoms_fever",
    "Chills": "other_symptoms_chills",
    "Fatigue": "other_symptoms_fatigue",
    "Joint pain": "other_symptoms_joint_pain",
    "Mouth sores": "other_symptoms_mouth_sores",
    "Shortness of breath":
        "other_symptoms_shortness_of_breath",
}

BODY_AREA_MAP = {
    "Head or Neck":
        "body_parts_head_or_neck",

    "Arm":
        "body_parts_arm",

    "Palm":
        "body_parts_palm",

    "Back of Hand":
        "body_parts_back_of_hand",

    "Torso (Front)":
        "body_parts_torso_front",

    "Torso (Back)":
        "body_parts_torso_back",

    "Genitalia or Groin":
        "body_parts_genitalia_or_groin",

    "Buttocks":
        "body_parts_buttocks",

    "Leg":
        "body_parts_leg",

    "Foot Top or Side":
        "body_parts_foot_top_or_side",

    "Foot Sole":
        "body_parts_foot_sole",

    "Other":
        "body_parts_other",
}

TEXTURE_MAP = {
    "Raised or Bumpy":
        "textures_raised_or_bumpy",

    "Flat":
        "textures_flat",

    "Rough or Flaky":
        "textures_rough_or_flaky",

    "Fluid Filled":
        "textures_fluid_filled",
}

DURATION_MAP = {
    "1 day": "ONE_DAY",
    "Less than 1 week":
        "LESS_THAN_ONE_WEEK",

    "1–4 weeks":
        "ONE_TO_FOUR_WEEKS",

    "1–3 months":
        "ONE_TO_THREE_MONTHS",

    "3–12 months":
        "THREE_TO_TWELVE_MONTHS",

    "More than 1 year":
        "MORE_THAN_ONE_YEAR",

    "More than 5 years":
        "MORE_THAN_FIVE_YEARS",

    "Since childhood":
        "SINCE_CHILDHOOD",
}


def convert_metadata(frontend_meta):

    converted = {}

    converted["age_group"] = (
        frontend_meta.get("age_range")
    )

    duration = frontend_meta.get("duration")

    converted["condition_duration"] = (
        DURATION_MAP.get(duration, "UNKNOWN")
    )

    for symptom in frontend_meta.get(
        "condition_symptoms",
        [],
    ):

        mapped = SYMPTOM_MAP.get(symptom)

        if mapped:
            converted[mapped] = "YES"

    for symptom in frontend_meta.get(
        "other_symptoms",
        [],
    ):

        mapped = OTHER_SYMPTOM_MAP.get(symptom)

        if mapped:
            converted[mapped] = "YES"

    for area in frontend_meta.get(
        "body_area",
        [],
    ):

        mapped = BODY_AREA_MAP.get(area)

        if mapped:
            converted[mapped] = "YES"

    texture = frontend_meta.get("texture")

    mapped_texture = TEXTURE_MAP.get(texture)

    if mapped_texture:
        converted[mapped_texture] = "YES"

    return converted


# routes
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

    frontend_metadata = json.loads(metadata)

    model_metadata = convert_metadata(
        frontend_metadata
    )

    file_path = UPLOAD_DIR / file.filename

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    result = predict(
        image_path=str(file_path),
        metadata=model_metadata,
    )

    return result