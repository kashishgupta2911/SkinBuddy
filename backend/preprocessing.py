# preprocessing.py

import ast
import random
from pathlib import Path

import numpy as np
import pandas as pd
from PIL import Image

import torch
import torchvision.transforms as transforms

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder


# ============================================================
# CONFIG
# ============================================================

IMG_SIZE = 224
PATCH_SIZE = 32
N_PATCHES = 16


# ============================================================
# LABEL MAPS
# ============================================================

CONDITION_TO_GROUP_PAPER4 = {
    "Eczema": "Eczema",
    "Atopic Dermatitis": "Eczema",
    "Contact Dermatitis": "Eczema",

    "Acne": "Acne",
    "Acne Vulgaris": "Acne",

    "Psoriasis": "Psoriasis",

    "Melanoma": "Melanoma",
    "Melanoma In Situ": "Melanoma",
}

CONDITION_TO_BINARY = {
    **{k: "Diseased" for k in CONDITION_TO_GROUP_PAPER4},
    "Normal Skin": "Healthy",
    "Healthy": "Healthy",
}


# ============================================================
# IMAGE TRANSFORMS
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
# METADATA FEATURES
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


# ============================================================
# PARSING HELPERS
# ============================================================

def parse_dict_str(x):

    if pd.isna(x):
        return {}

    try:
        value = ast.literal_eval(x) if isinstance(x, str) else x
        return value if isinstance(value, dict) else {}

    except Exception:
        return {}


def parse_list_str(x):

    if pd.isna(x):
        return []

    try:
        value = ast.literal_eval(x) if isinstance(x, str) else x
        return value if isinstance(value, list) else []

    except Exception:
        return []


# ============================================================
# LOAD DATA
# ============================================================

def load_scin_data(cases_csv, labels_csv):

    cases = pd.read_csv(
        cases_csv,
        dtype={"case_id": str},
    )

    labels = pd.read_csv(
        labels_csv,
        dtype={"case_id": str},
    )

    return pd.merge(cases, labels, on="case_id")


# ============================================================
# LABEL CREATION
# ============================================================

def create_labels(df, mode="paper4"):

    df = df.copy()

    df["_wt_dict"] = df[
        "weighted_skin_condition_label"
    ].apply(parse_dict_str)

    df["primary_condition"] = df["_wt_dict"].apply(
        lambda d: max(d, key=d.get) if d else None
    )

    mapping = (
        CONDITION_TO_GROUP_PAPER4
        if mode == "paper4"
        else CONDITION_TO_BINARY
    )

    df["target_label"] = df[
        "primary_condition"
    ].map(mapping)

    return df[df["target_label"].notna()].copy()


# ============================================================
# IMAGE LEVEL EXPANSION
# ============================================================

def build_image_level_df(df):

    rows = []

    image_cols = [
        "image_1_path",
        "image_2_path",
        "image_3_path",
    ]

    for _, row in df.iterrows():

        for col in image_cols:

            image_path = row.get(col)

            if pd.notna(image_path):

                r = row.to_dict()
                r["image_path"] = image_path

                rows.append(r)

    df_img = pd.DataFrame(rows)

    return df_img.drop_duplicates(
        subset=["image_path"]
    )


# ============================================================
# CLASS BALANCING
# ============================================================

def cap_classes(
    df,
    max_per_class=120,
    random_state=42,
):

    balanced = pd.concat([

        grp.sample(
            n=min(len(grp), max_per_class),
            random_state=random_state,
        )

        for _, grp in df.groupby("target_label")

    ])

    return balanced.reset_index(drop=True)


# ============================================================
# METADATA BUILDING
# ============================================================

def yn_to_float(v):

    if isinstance(v, str):
        return 1.0 if v.strip().upper() == "YES" else 0.0

    return 0.0


def build_metadata_row(row):

    features = []

    for col in (
        SYMPTOM_COLS
        + BODY_COLS
        + TEXTURE_COLS
    ):

        features.append(
            yn_to_float(row.get(col, 0))
        )

    return np.array(
        features,
        dtype=np.float32,
    )


def build_metadata_matrix(df):

    rows = [
        build_metadata_row(r)
        for _, r in df.iterrows()
    ]

    return np.vstack(rows)


# ============================================================
# PATCH EXTRACTION
# ============================================================

def extract_patches(
    img: Image.Image,
    n=N_PATCHES,
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


# ============================================================
# LABEL ENCODING
# ============================================================

def encode_labels(df):

    le = LabelEncoder()

    y = le.fit_transform(df["target_label"])

    return le, y


# ============================================================
# SPLITS
# ============================================================

def split_dataset(
    df,
    y,
    test_size=0.15,
    val_size=0.15,
    random_state=42,
):

    idx = np.arange(len(df))

    idx_trainval, idx_test = train_test_split(
        idx,
        test_size=test_size,
        stratify=y,
        random_state=random_state,
    )

    idx_train, idx_val = train_test_split(
        idx_trainval,
        test_size=val_size / (1 - test_size),
        stratify=y[idx_trainval],
        random_state=random_state,
    )

    return idx_train, idx_val, idx_test


# ============================================================
# IMAGE VALIDATION
# ============================================================

def validate_image_paths(
    df,
    images_dir=None,
):

    valid_rows = []

    for _, row in df.iterrows():

        path = row["image_path"]

        full_path = (
            Path(images_dir) / path
            if images_dir
            else Path(path)
        )

        if full_path.exists():
            valid_rows.append(row)

    return pd.DataFrame(valid_rows)