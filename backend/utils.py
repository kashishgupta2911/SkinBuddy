# utils.py

import random
from typing import Dict, List

import numpy as np
import torch
import torchvision.transforms as transforms
from PIL import Image

from config import (
    IMG_SIZE,
    PATCH_SIZE,
    N_PATCHES,
)

# ============================================================
# TRANSFORMS
# ============================================================

tf_img = transforms.Compose([
    transforms.Resize((IMG_SIZE, IMG_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(
        [0.485, 0.456, 0.406],
        [0.229, 0.224, 0.225],
    ),
])

tf_patch = transforms.Compose([
    transforms.Resize((PATCH_SIZE, PATCH_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(
        [0.485, 0.456, 0.406],
        [0.229, 0.224, 0.225],
    ),
])

# ============================================================
# TRAINING FEATURE ORDER
# MUST MATCH TRAINING SCRIPT EXACTLY
# ============================================================

SYMPTOM_COLS = [
    "condition_symptoms_bothersome_appearance",
    "condition_symptoms_bleeding",
    "condition_symptoms_increasing_size",
    "condition_symptoms_darkening",
    "condition_symptoms_itching",
    "condition_symptoms_burning",
    "condition_symptoms_pain",
    "condition_symptoms_no_relevant_experience",
]

OTHER_COLS = [
    "other_symptoms_fever",
    "other_symptoms_chills",
    "other_symptoms_fatigue",
    "other_symptoms_joint_pain",
    "other_symptoms_mouth_sores",
    "other_symptoms_shortness_of_breath",
    "other_symptoms_no_relevant_symptoms",
]

BODY_COLS = [
    "body_parts_head_or_neck",
    "body_parts_arm",
    "body_parts_palm",
    "body_parts_back_of_hand",
    "body_parts_torso_front",
    "body_parts_torso_back",
    "body_parts_genitalia_or_groin",
    "body_parts_buttocks",
    "body_parts_leg",
    "body_parts_foot_top_or_side",
    "body_parts_foot_sole",
    "body_parts_other",
]

TEXTURE_COLS = [
    "textures_raised_or_bumpy",
    "textures_flat",
    "textures_rough_or_flaky",
    "textures_fluid_filled",
]

DURATION_CATS = [
    "ONE_DAY",
    "LESS_THAN_ONE_WEEK",
    "ONE_TO_FOUR_WEEKS",
    "ONE_TO_THREE_MONTHS",
    "THREE_TO_TWELVE_MONTHS",
    "MORE_THAN_ONE_YEAR",
    "MORE_THAN_FIVE_YEARS",
    "SINCE_CHILDHOOD",
    "UNKNOWN",
]

AGE_GROUPS = [
    "18-29",
    "30-39",
    "40-49",
    "50-59",
    "60-69",
    "70-79",
    "80 or above",
]

RELATED_CATEGORIES = [
    "ACNE",
    "GROWTH_OR_MOLE",
    "HAIR_LOSS",
    "OTHER_HAIR_PROBLEM",
    "NAIL_PROBLEM",
    "PIGMENTARY_PROBLEM",
    "RASH",
    "LOOKS_HEALTHY",
    "OTHER_ISSUE_DESCRIPTION",
]

# ============================================================
# USER INPUT → TRAINING FEATURE MAPPINGS
# ============================================================

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

    "None of these":
        "condition_symptoms_no_relevant_experience",
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

    "None of these":
        "other_symptoms_no_relevant_symptoms",
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

    "Torso Front":
        "body_parts_torso_front",

    "Torso Back":
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

    "Fluid filled":
        "textures_fluid_filled",
}

DURATION_MAP = {
    "One day":
        "ONE_DAY",

    "Less than one week":
        "LESS_THAN_ONE_WEEK",

    "One to four weeks":
        "ONE_TO_FOUR_WEEKS",

    "One to three months":
        "ONE_TO_THREE_MONTHS",

    "Three to twelve months":
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

# ============================================================
# METADATA VECTOR
# ============================================================

def build_metadata_vector(meta: Dict):

    features = []

    symptom_set = set(
        meta.get("condition_symptoms", [])
    )

    other_symptom_set = set(
        meta.get("other_symptoms", [])
    )

    body_area_set = set(
        meta.get("body_area", [])
    )

    texture_value = meta.get(
        "texture",
        None,
    )

    # ========================================================
    # Symptoms
    # ========================================================

    for col in SYMPTOM_COLS:

        active = any(
            SYMPTOM_MAP.get(v) == col
            for v in symptom_set
        )

        features.append(float(active))

    # ========================================================
    # Other symptoms
    # ========================================================

    for col in OTHER_COLS:

        active = any(
            OTHER_SYMPTOM_MAP.get(v) == col
            for v in other_symptom_set
        )

        features.append(float(active))

    # ========================================================
    # Body areas
    # ========================================================

    for col in BODY_COLS:

        active = any(
            BODY_AREA_MAP.get(v) == col
            for v in body_area_set
        )

        features.append(float(active))

    # ========================================================
    # Texture
    # ========================================================

    texture_col = TEXTURE_MAP.get(texture_value)

    for col in TEXTURE_COLS:
        features.append(
            float(col == texture_col)
        )

    # ========================================================
    # Duration
    # ========================================================

    duration = DURATION_MAP.get(
        meta.get("duration"),
        "UNKNOWN",
    )

    for cat in DURATION_CATS:
        features.append(
            float(cat == duration)
        )

    # ========================================================
    # Age group
    # ========================================================

    age_group = meta.get(
        "age_range",
        None,
    )

    for a in AGE_GROUPS:
        features.append(
            float(a == age_group)
        )

    # ========================================================
    # Related category
    # ========================================================

    related_category = RELATED_CATEGORY_MAP.get(
        meta.get("related_category"),
        None,
    )

    for cat in RELATED_CATEGORIES:
        features.append(
            float(cat == related_category)
        )

    return np.array(
        features,
        dtype=np.float32,
    )

# ============================================================
# PATCH EXTRACTION
# ============================================================

def extract_patches(
    img: Image.Image,
    n: int = N_PATCHES,
):
    w, h = img.size

    patches = []

    step_x = max(
        1,
        w // int(n ** 0.5),
    )

    step_y = max(
        1,
        h // int(n ** 0.5),
    )

    ps = min(PATCH_SIZE, w, h)

    for i in range(
        0,
        h - ps + 1,
        step_y,
    ):
        for j in range(
            0,
            w - ps + 1,
            step_x,
        ):
            crop = img.crop(
                (j, i, j + ps, i + ps)
            )

            patches.append(crop)

    if len(patches) >= n:
        patches = random.sample(
            patches,
            n,
        )
    else:
        patches = (
            patches
            * (n // len(patches) + 1)
        )[:n]

    return patches


def patches_to_tensor(patches):
    tensors = [tf_patch(p) for p in patches]

    return torch.stack(tensors)