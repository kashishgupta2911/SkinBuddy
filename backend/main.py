from fastapi import FastAPI, UploadFile, File, Form
from fastapi.responses import JSONResponse

from inference import predict

from pathlib import Path

import shutil
import json
import uuid

app = FastAPI()

UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

# ============================================================
# FRONTEND → MODEL METADATA
# ============================================================

AGE_MAP = {
    "18-29": "18-29",
    "30-39": "30-39",
    "40-49": "40-49",
    "50-59": "50-59",
    "60-69": "60-69",
    "70-79": "70-79",
    "80+": "80 or above",
}

DURATION_MAP = {
    "One day":
        "ONE_DAY",

    "Less than one week":
        "LESS_THAN_ONE_WEEK",

    "1–4 weeks":
        "ONE_TO_FOUR_WEEKS",

    "1–3 months":
        "ONE_TO_THREE_MONTHS",

    "3–12 months":
        "THREE_TO_TWELVE_MONTHS",

    "More than one year":
        "MORE_THAN_ONE_YEAR",

    "More than five years":
        "MORE_THAN_FIVE_YEARS",

    "Since childhood":
        "SINCE_CHILDHOOD",

    "Unknown":
        "UNKNOWN",
}

TEXTURE_MAP = {
    "Raised or bumpy":
        "textures_raised_or_bumpy",

    "Flat":
        "textures_flat",

    "Rough or flaky":
        "textures_rough_or_flaky",

    "Fluid filled":
        "textures_fluid_filled",
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

    "Foot (Top/Side)":
        "body_parts_foot_top_or_side",

    "Foot (Sole)":
        "body_parts_foot_sole",

    "Other":
        "body_parts_other",
}

SYMPTOM_MAP = {
    "Bothersome appearance":
        "condition_symptoms_bothersome_appearance",

    "Bleeding":
        "condition_symptoms_bleeding",

    "Increasing size":
        "condition_symptoms_increasing_size",

    "Darkening":
        "condition_symptoms_darkening",

    "Itching":
        "condition_symptoms_itching",

    "Burning":
        "condition_symptoms_burning",

    "Pain":
        "condition_symptoms_pain",
}

OTHER_SYMPTOM_MAP = {
    "Fever":
        "other_symptoms_fever",

    "Chills":
        "other_symptoms_chills",

    "Fatigue":
        "other_symptoms_fatigue",

    "Joint pain":
        "other_symptoms_joint_pain",

    "Mouth sores":
        "other_symptoms_mouth_sores",

    "Shortness of breath":
        "other_symptoms_shortness_of_breath",
}

RELATED_CATEGORY_MAP = {
    "Acne":
        "ACNE",

    "Growth or mole":
        "GROWTH_OR_MOLE",

    "Hair loss":
        "HAIR_LOSS",

    "Other hair problem":
        "OTHER_HAIR_PROBLEM",

    "Nail problem":
        "NAIL_PROBLEM",

    "Pigmentary problem":
        "PIGMENTARY_PROBLEM",

    "Rash":
        "RASH",

    "Looks healthy":
        "LOOKS_HEALTHY",

    "Other":
        "OTHER_ISSUE_DESCRIPTION",
}

# ============================================================
# NORMALIZE FRONTEND METADATA
# ============================================================

def normalize_metadata(frontend_meta):

    converted = {}

    # ========================================================
    # Age
    # ========================================================

    age = frontend_meta.get("age_group")

    if age and age != "Under 18":
        converted["age_group"] = AGE_MAP.get(age)

    # ========================================================
    # Duration
    # ========================================================

    duration = frontend_meta.get("duration")

    converted["condition_duration"] = (
        DURATION_MAP.get(duration, "UNKNOWN")
    )

    # ========================================================
    # Related category
    # ========================================================

    related = frontend_meta.get(
        "related_category"
    )

    converted["related_category"] = (
        RELATED_CATEGORY_MAP.get(
            related,
            "OTHER_ISSUE_DESCRIPTION",
        )
    )

    # ========================================================
    # Texture
    # ========================================================

    texture = frontend_meta.get("texture")

    mapped_texture = TEXTURE_MAP.get(texture)

    if mapped_texture:
        converted[mapped_texture] = "YES"

    # ========================================================
    # Symptoms
    # ========================================================

    for symptom in frontend_meta.get(
        "condition_symptoms",
        [],
    ):

        if symptom == "None of these":
            continue

        mapped = SYMPTOM_MAP.get(symptom)

        if mapped:
            converted[mapped] = "YES"

    # ========================================================
    # Other symptoms
    # ========================================================

    for symptom in frontend_meta.get(
        "other_symptoms",
        [],
    ):

        if symptom == "None of these":
            continue

        mapped = OTHER_SYMPTOM_MAP.get(symptom)

        if mapped:
            converted[mapped] = "YES"

    # ========================================================
    # Body areas
    # ========================================================

    for area in frontend_meta.get(
        "body_area",
        [],
    ):

        mapped = BODY_AREA_MAP.get(area)

        if mapped:
            converted[mapped] = "YES"

    return converted

# ============================================================
# ROUTES
# ============================================================

@app.api_route("/", methods=["GET", "HEAD"])
def root():

    return JSONResponse(
        {"message": "SkinBuddy API running"}
    )

@app.get("/health")
def health():

    return {"status": "ok"}

@app.post("/predict")
async def predict_image(
    file: UploadFile = File(...),
    metadata: str = Form(...),
):

    try:
        frontend_metadata = json.loads(
            metadata
        )

    except json.JSONDecodeError:

        return JSONResponse(
            status_code=400,
            content={
                "error":
                    "Invalid metadata JSON"
            },
        )

    normalized_metadata = normalize_metadata(
        frontend_metadata
    )

    file_ext = Path(file.filename).suffix

    file_path = (
        UPLOAD_DIR
        / f"{uuid.uuid4()}{file_ext}"
    )

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(
            file.file,
            buffer,
        )

    try:

        result = predict(
            image_path=str(file_path),
            metadata=normalized_metadata,
        )

        return result

    finally:

        file_path.unlink(
            missing_ok=True
        )