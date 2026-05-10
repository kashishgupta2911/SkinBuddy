import torch

IMG_SIZE = 224
PATCH_SIZE = 32
N_PATCHES = 16
EMBED_DIM = 256

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

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