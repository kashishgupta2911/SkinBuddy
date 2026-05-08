"""
inference.py
============

Inference script for the trained SCIN Hybrid Model.

Supports:
- Single image prediction
- Optional metadata fusion
- Top-k predictions with probabilities
- CPU/GPU auto-detection
- Uses the SAME architecture + preprocessing as training

EXAMPLE USAGE
-------------

# Basic inference
python inference.py \
    --image path/to/image.jpg \
    --model results/hybrid_model.pt

# With metadata JSON
python inference.py \
    --image path/to/image.jpg \
    --model results/hybrid_model.pt \
    --metadata metadata.json

# Example metadata.json
{
  "condition_symptoms_itching": "YES",
  "textures_raised_or_bumpy": "YES",
  "age_group": "18-29",
  "sex_at_birth": "FEMALE",
  "condition_duration": "ONE_TO_FOUR_WEEKS"
}
"""

import argparse
import json
import random
from pathlib import Path
from typing import Dict, List

import numpy as np
from PIL import Image

import torch
import torch.nn as nn
import torchvision.models as models
import torchvision.transforms as transforms


# ─────────────────────────────────────────────────────────────
# CONFIG
# ─────────────────────────────────────────────────────────────

IMG_SIZE = 224
PATCH_SIZE = 32
N_PATCHES = 16
EMBED_DIM = 256

DEVICE = torch.device("cuda" if torch.cuda.is_available() else "cpu")


# ─────────────────────────────────────────────────────────────
# CLASS LABELS
# MUST MATCH TRAINING
# ─────────────────────────────────────────────────────────────

PAPER4_CLASSES = [
    "Acne",
    "Eczema",
    "Melanoma",
    "Psoriasis",
]

BINARY_CLASSES = [
    "Diseased",
    "Healthy",
]


# ─────────────────────────────────────────────────────────────
# METADATA CONFIG
# ─────────────────────────────────────────────────────────────

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


# ─────────────────────────────────────────────────────────────
# TRANSFORMS
# ─────────────────────────────────────────────────────────────

_tf_img = transforms.Compose([
    transforms.Resize((IMG_SIZE, IMG_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(
        [0.485, 0.456, 0.406],
        [0.229, 0.224, 0.225],
    ),
])

_tf_patch = transforms.Compose([
    transforms.Resize((PATCH_SIZE, PATCH_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(
        [0.485, 0.456, 0.406],
        [0.229, 0.224, 0.225],
    ),
])


# ─────────────────────────────────────────────────────────────
# MODEL ARCHITECTURE
# MUST MATCH TRAINING
# ─────────────────────────────────────────────────────────────

class ResidualBlock(nn.Module):
    def __init__(self, channels: int):
        super().__init__()

        self.conv1 = nn.Conv2d(
            channels,
            channels,
            3,
            padding=1,
            bias=False,
        )

        self.bn1 = nn.BatchNorm2d(channels)

        self.conv2 = nn.Conv2d(
            channels,
            channels,
            3,
            padding=1,
            bias=False,
        )

        self.bn2 = nn.BatchNorm2d(channels)

        self.act = nn.LeakyReLU(0.1, inplace=True)

    def forward(self, x):
        out = self.act(self.bn1(self.conv1(x)))
        out = self.bn2(self.conv2(out))
        return self.act(out + x)


class FCRN(nn.Module):
    def __init__(self, embed_dim: int = 128):
        super().__init__()

        self.stem = nn.Sequential(
            nn.Conv2d(3, 64, 3, padding=1, bias=False),
            nn.BatchNorm2d(64),
            nn.LeakyReLU(0.1, inplace=True),
        )

        self.res1 = ResidualBlock(64)

        self.pool = nn.MaxPool2d(2)

        self.res2 = ResidualBlock(64)

        self.conv3 = nn.Conv2d(
            64,
            128,
            3,
            padding=1,
            bias=False,
        )

        self.bn3 = nn.BatchNorm2d(128)

        self.act = nn.LeakyReLU(0.1, inplace=True)

        self.gap = nn.AdaptiveAvgPool2d(1)

        self.proj = nn.Conv2d(128, embed_dim, 1)

    def forward(self, x):
        x = self.stem(x)
        x = self.res1(x)
        x = self.pool(x)
        x = self.res2(x)
        x = self.act(self.bn3(self.conv3(x)))
        x = self.gap(x)
        x = self.proj(x)

        return x.flatten(1)


class HybridModel(nn.Module):
    def __init__(
        self,
        num_classes: int,
        meta_dim: int,
        embed_dim: int = EMBED_DIM,
    ):
        super().__init__()

        try:
            backbone = models.resnet18(
                weights=models.ResNet18_Weights.DEFAULT
            )
        except Exception:
            backbone = models.resnet18(weights=None)

        backbone.fc = nn.Linear(
            backbone.fc.in_features,
            embed_dim,
        )

        self.backbone = backbone

        self.fcrn = FCRN(embed_dim=embed_dim // 2)

        fused_dim = embed_dim + embed_dim // 2 + meta_dim

        self.classifier = nn.Sequential(
            nn.Linear(fused_dim, 128),
            nn.LeakyReLU(0.1),
            nn.Dropout(0.1),

            nn.Linear(128, 64),
            nn.LeakyReLU(0.1),

            nn.Linear(64, num_classes),
        )

    def forward(
        self,
        img: torch.Tensor,
        patch: torch.Tensor,
        meta: torch.Tensor,
    ):
        img_feat = self.backbone(img)

        patch_feat = self.fcrn(patch)

        fused = torch.cat(
            [img_feat, patch_feat, meta],
            dim=1,
        )

        return self.classifier(fused)


# ─────────────────────────────────────────────────────────────
# METADATA
# ─────────────────────────────────────────────────────────────

def _yn(v):
    if isinstance(v, bool):
        return float(v)

    if isinstance(v, str):
        return 1.0 if v.strip().upper() == "YES" else 0.0

    return 0.0


def build_metadata_vector(meta: Dict) -> np.ndarray:
    feats = []

    for c in (
        SYMPTOM_COLS
        + OTHER_COLS
        + BODY_COLS
        + TEXTURE_COLS
    ):
        feats.append(_yn(meta.get(c, 0)))

    duration = meta.get("condition_duration", None)

    for cat in DURATION_CATS:
        feats.append(1.0 if duration == cat else 0.0)

    age_group = meta.get("age_group", None)

    for a in AGE_GROUPS:
        feats.append(1.0 if age_group == a else 0.0)

    sex = str(meta.get("sex_at_birth", "")).strip().lower()

    feats.append(1.0 if sex in ("female", "f") else 0.0)
    feats.append(1.0 if sex in ("male", "m") else 0.0)

    return np.array(feats, dtype=np.float32)


# ─────────────────────────────────────────────────────────────
# PATCH EXTRACTION
# ─────────────────────────────────────────────────────────────

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
    tensors = [_tf_patch(p) for p in patches]
    return torch.stack(tensors)


# ─────────────────────────────────────────────────────────────
# INFERENCE
# ─────────────────────────────────────────────────────────────

@torch.no_grad()
def predict(
    model,
    image_path: str,
    metadata: Dict,
    class_names: List[str],
    top_k: int = 4,
):
    image = Image.open(image_path).convert("RGB")

    t_img = _tf_img(image).unsqueeze(0).to(DEVICE)

    patches = extract_patches(image)

    t_patch = (
        patches_to_tensor(patches)
        .mean(0, keepdim=True)
        .to(DEVICE)
    )

    meta_vec = build_metadata_vector(metadata)

    t_meta = (
        torch.from_numpy(meta_vec)
        .unsqueeze(0)
        .to(DEVICE)
    )

    logits = model(t_img, t_patch, t_meta)

    probs = torch.softmax(logits, dim=1)[0]

    top_probs, top_idxs = torch.topk(
        probs,
        k=min(top_k, len(class_names)),
    )

    results = []

    for prob, idx in zip(top_probs, top_idxs):
        results.append({
            "name": class_names[idx.item()],
            "confidence": round(float(prob.item()), 4),
        })

    return results


# ─────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--image",
        required=True,
        help="Path to image",
    )

    parser.add_argument(
        "--model",
        required=True,
        help="Path to trained .pt model",
    )

    parser.add_argument(
        "--metadata",
        default=None,
        help="Optional metadata JSON file",
    )

    parser.add_argument(
        "--mode",
        default="paper4",
        choices=["paper4", "binary"],
    )

    parser.add_argument(
        "--top_k",
        type=int,
        default=3,
    )

    args = parser.parse_args()

    # Load metadata
    if args.metadata:
        with open(args.metadata, "r") as f:
            metadata = json.load(f)
    else:
        metadata = {}

    # Classes
    if args.mode == "paper4":
        class_names = PAPER4_CLASSES
    else:
        class_names = BINARY_CLASSES

    # Metadata dimension
    meta_dim = len(build_metadata_vector({}))

    # Build model
    model = HybridModel(
        num_classes=len(class_names),
        meta_dim=meta_dim,
    ).to(DEVICE)

    # Load weights
    state_dict = torch.load(
        args.model,
        map_location=DEVICE,
    )

    model.load_state_dict(state_dict)

    model.eval()

    print("=" * 60)
    print("SCIN Inference")
    print("=" * 60)

    print(f"Device : {DEVICE}")
    print(f"Image  : {args.image}")
    print(f"Model  : {args.model}")

    # Predict
    results = predict(
        model=model,
        image_path=args.image,
        metadata=metadata,
        class_names=class_names,
        top_k=args.top_k,
    )

    print("\nPredictions")
    print("-" * 60)

    for i, r in enumerate(results, start=1):
        print(
            f"{i}. {r['class']:12s} "
            f"{r['probability'] * 100:.2f}%"
        )

    print("=" * 60)


if __name__ == "__main__":
    main()