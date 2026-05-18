import json
from typing import Dict

import torch
from PIL import Image

from model import HybridModel
from config import (
    DEVICE,
    CLINICAL8_CLASSES,
    BINARY_CLASSES,
)

from utils import (
    build_metadata_vector,
    extract_patches,
    patches_to_tensor,
    tf_img,
)

from pathlib import Path

# ============================================================
# Load model once globally
# ============================================================

BASE_DIR = Path(__file__).resolve().parent

MODEL_PATH = (
    BASE_DIR
    / "model"
    / "hybrid_model.pt"
)

MODE = "clinical8"

# ============================================================
# Classes
# ============================================================

if MODE == "clinical8":
    CLASS_NAMES = CLINICAL8_CLASSES

elif MODE == "binary":
    CLASS_NAMES = BINARY_CLASSES

else:
    raise ValueError(f"Unknown MODE: {MODE}")

# ============================================================
# Metadata dimension
# ============================================================

meta_dim = len(
    build_metadata_vector({})
)

# ============================================================
# Build model
# ============================================================

model = HybridModel(
    num_classes=len(CLASS_NAMES),
    meta_dim=meta_dim,
).to(DEVICE)

print("Starting model load...")
print(f"Model path: {MODEL_PATH}")
print(f"Exists: {MODEL_PATH.exists()}")

# ============================================================
# Load weights
# ============================================================

state_dict = torch.load(
    str(MODEL_PATH),
    map_location=DEVICE,
)

print("Model weights loaded.")

model.load_state_dict(state_dict)

model.eval()

# ============================================================
# Prediction
# ============================================================

@torch.no_grad()
def predict(
    image_path: str,
    metadata: Dict | None = None,
    top_k: int = 3,
):

    metadata = metadata or {}

    image = Image.open(
        image_path
    ).convert("RGB")

    # ========================================================
    # Full image branch
    # ========================================================

    t_img = (
        tf_img(image)
        .unsqueeze(0)
        .to(DEVICE)
    )

    # ========================================================
    # Patch branch
    # Shape:
    # (1, N_PATCHES, 3, PATCH_SIZE, PATCH_SIZE)
    # ========================================================

    patches = extract_patches(image)

    t_patch = (
        patches_to_tensor(patches)
        .unsqueeze(0)
        .to(DEVICE)
    )

    # ========================================================
    # Metadata branch
    # ========================================================

    meta_vec = build_metadata_vector(
        metadata
    )

    t_meta = (
        torch.from_numpy(meta_vec)
        .unsqueeze(0)
        .to(DEVICE)
    )

    # ========================================================
    # Forward pass
    # ========================================================

    logits = model(
        t_img,
        t_patch,
        t_meta,
    )

    probs = torch.softmax(
        logits,
        dim=1,
    )[0]

    top_probs, top_idxs = torch.topk(
        probs,
        k=min(top_k, len(CLASS_NAMES)),
    )

    predicted_groups = []

    for prob, idx in zip(
        top_probs,
        top_idxs,
    ):

        predicted_groups.append({
            "name":
                CLASS_NAMES[idx.item()],

            "confidence":
                round(
                    float(prob.item()),
                    4,
                ),
        })

    return {
        "predicted_groups":
            predicted_groups
    }