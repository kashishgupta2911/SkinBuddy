import json
from typing import Dict

import torch
from PIL import Image

from model import HybridModel
from config import (
    DEVICE,
    PAPER4_CLASSES,
    BINARY_CLASSES,
)
from utils import (
    build_metadata_vector,
    extract_patches,
    patches_to_tensor,
    tf_img,
)

# Load model once globally
MODEL_PATH = "results/hybrid_model.pt"
MODE = "paper4"

# Classes
CLASS_NAMES = (
    PAPER4_CLASSES
    if MODE == "paper4"
    else BINARY_CLASSES
)

# Metadata dimension
meta_dim = len(build_metadata_vector({}))

# Build model
model = HybridModel(
    num_classes=len(CLASS_NAMES),
    meta_dim=meta_dim,
).to(DEVICE)

# Load weights
state_dict = torch.load(
    MODEL_PATH,
    map_location=DEVICE,
)

model.load_state_dict(state_dict)
model.eval()


@torch.no_grad()
def predict(
    image_path: str,
    metadata: Dict = {},
    top_k: int = 3,
):
    image = Image.open(image_path).convert("RGB")

    # Full image
    t_img = tf_img(image).unsqueeze(0).to(DEVICE)

    # Patch branch
    patches = extract_patches(image)

    t_patch = (
        patches_to_tensor(patches)
        .mean(0, keepdim=True)
        .to(DEVICE)
    )

    # Metadata
    meta_vec = build_metadata_vector(metadata)

    t_meta = (
        torch.from_numpy(meta_vec)
        .unsqueeze(0)
        .to(DEVICE)
    )

    # Inference
    logits = model(t_img, t_patch, t_meta)

    probs = torch.softmax(logits, dim=1)[0]

    top_probs, top_idxs = torch.topk(
        probs,
        k=min(top_k, len(CLASS_NAMES)),
    )

    predictions = []

    for prob, idx in zip(top_probs, top_idxs):
        predictions.append({
            "name": CLASS_NAMES[idx.item()],
            "confidence": round(float(prob.item()), 4),
        })

    return {
        "prediction": predictions[0]["name"],
        "confidence": predictions[0]["confidence"],
        "predictions": predictions,
    }