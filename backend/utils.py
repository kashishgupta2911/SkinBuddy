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
    "condition_symptoms_itching",
    "condition_symptoms_pain",
]

BODY_COLS = [
    "body_parts_arm",
    "body_parts_leg",
]

TEXTURE_COLS = [
    "textures_flat",
    "textures_raised_or_bumpy",
]


def yn_to_float(v):
    if isinstance(v, str):
        return 1.0 if v.strip().upper() == "YES" else 0.0

    return 0.0


def build_metadata_vector(meta: Dict):
    features = []

    for col in (
        SYMPTOM_COLS
        + BODY_COLS
        + TEXTURE_COLS
    ):
        features.append(
            yn_to_float(meta.get(col, 0))
        )

    return np.array(features, dtype=np.float32)

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
        patches = (patches * (n // len(patches) + 1))[:n]

    return patches


def patches_to_tensor(patches):
    tensors = [tf_patch(p) for p in patches]
    return torch.stack(tensors)