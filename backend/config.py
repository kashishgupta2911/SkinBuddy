import torch

IMG_SIZE = 224
PATCH_SIZE = 32
N_PATCHES = 16
EMBED_DIM = 256

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

# Clinical triage-oriented classes used by the trained hybrid model
CLINICAL8_CLASSES = [
    "Acneiform",
    "Bacterial_Follicular",
    "Drug_Vasculitic_Purpuric",
    "Eczematous_Dermatitis",
    "Fungal",
    "Papulosquamous_Lichenoid",
    "Urticarial_Hypersensitivity",
    "Viral",
]

BINARY_CLASSES = [
    "Diseased",
    "Healthy",
]