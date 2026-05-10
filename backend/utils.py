# utils.py

import random
from typing import Dict

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
# METADATA
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


def yn_to_float(v):
    if isinstance(v, bool):
        return float(v)

    if isinstance(v, str):
        return 1.0 if v.strip().upper() == "YES" else 0.0

    return 0.0


def build_metadata_vector(meta: Dict):

    features = []

    # Binary features
    for col in (
        SYMPTOM_COLS
        + OTHER_COLS
        + BODY_COLS
        + TEXTURE_COLS
    ):
        features.append(
            yn_to_float(meta.get(col, 0))
        )

    # Duration one-hot
    duration = meta.get("condition_duration", None)

    for cat in DURATION_CATS:
        features.append(
            1.0 if duration == cat else 0.0
        )

    # Age group one-hot
    age_group = meta.get("age_group", None)

    for a in AGE_GROUPS:
        features.append(
            1.0 if age_group == a else 0.0
        )

    # Sex one-hot
    sex = str(
        meta.get("sex_at_birth", "")
    ).strip().lower()

    features.append(
        1.0 if sex in ("female", "f") else 0.0
    )

    features.append(
        1.0 if sex in ("male", "m") else 0.0
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

    step_x = max(1, w // int(n ** 0.5))
    step_y = max(1, h // int(n ** 0.5))

    ps = min(PATCH_SIZE, w, h)

    for i in range(0, h - ps + 1, step_y):
        for j in range(0, w - ps + 1, step_x):
            crop = img.crop((j, i, j + ps, i + ps))
            patches.append(crop)

    if len(patches) >= n:
        patches = random.sample(patches, n)
    else:
        patches = (
            patches * (n // len(patches) + 1)
        )[:n]

    return patches


def patches_to_tensor(patches):
    tensors = [tf_patch(p) for p in patches]
    return torch.stack(tensors)