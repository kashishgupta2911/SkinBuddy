# ─────────────────────────────────────────────────────────────
# 4. FCRN-INSPIRED CNN FEATURE EXTRACTOR  (paper §Methods)
# ─────────────────────────────────────────────────────────────

class ResidualBlock(nn.Module):
    """Basic residual block matching the paper's description."""
    def __init__(self, channels: int):
        super().__init__()
        self.conv1 = nn.Conv2d(channels, channels, 3, padding=1, bias=False)
        self.bn1   = nn.BatchNorm2d(channels)
        self.conv2 = nn.Conv2d(channels, channels, 3, padding=1, bias=False)
        self.bn2   = nn.BatchNorm2d(channels)
        self.act   = nn.LeakyReLU(0.1, inplace=True)

    def forward(self, x):
        out = self.act(self.bn1(self.conv1(x)))
        out = self.bn2(self.conv2(out))
        return self.act(out + x)   # skip connection


class FCRN(nn.Module):
    """
    Fully Convolutional Residual Network for patch-level feature extraction.
    Mirrors the paper's architecture (§ Patch-based feature extraction).
    """
    def __init__(self, embed_dim: int = 128):
        super().__init__()
        self.stem  = nn.Sequential(
            nn.Conv2d(3, 64, 3, padding=1, bias=False),
            nn.BatchNorm2d(64),
            nn.LeakyReLU(0.1, inplace=True),
        )
        self.res1  = ResidualBlock(64)
        self.pool  = nn.MaxPool2d(2)
        self.res2  = ResidualBlock(64)
        self.conv3 = nn.Conv2d(64, 128, 3, padding=1, bias=False)
        self.bn3   = nn.BatchNorm2d(128)
        self.act   = nn.LeakyReLU(0.1, inplace=True)
        self.gap   = nn.AdaptiveAvgPool2d(1)
        self.proj  = nn.Conv2d(128, embed_dim, 1)

    def forward(self, x):
        x = self.stem(x)
        x = self.res1(x)
        x = self.pool(x)
        x = self.res2(x)
        x = self.act(self.bn3(self.conv3(x)))
        x = self.gap(x)
        x = self.proj(x)
        return x.flatten(1)          # (B, embed_dim)


class HybridModel(nn.Module):
    """
    Full paper architecture:
      1. ResNet-18 backbone extracts whole-image spatial features.
      2. FCRN extracts patch-level features (disease probability maps).
      3. Clinical metadata vector is fused at the FC layer.
      4. Final softmax classification.
    """
    def __init__(
        self,
        num_classes: int,
        meta_dim: int,
        embed_dim: int = EMBED_DIM,
    ):
        super().__init__()

        # ── Image branch (ResNet-18 backbone) ──────────────────────────────
        try:
            backbone = models.resnet18(weights=models.ResNet18_Weights.DEFAULT)
        except Exception:
            backbone = models.resnet18(weights=None)
        # replace final FC with projection
        backbone.fc = nn.Linear(backbone.fc.in_features, embed_dim)
        self.backbone = backbone

        # ── Patch branch (FCRN) ────────────────────────────────────────────
        self.fcrn = FCRN(embed_dim=embed_dim // 2)

        # ── Fusion + classifier ────────────────────────────────────────────
        fused_dim = embed_dim + embed_dim // 2 + meta_dim
        self.classifier = nn.Sequential(
            nn.Linear(fused_dim, 128),
            nn.LeakyReLU(0.1),
            nn.Dropout(0.1),
            nn.Linear(128, 64),
            nn.LeakyReLU(0.1),
            nn.Linear(64, num_classes),
        )

    def forward(self, img: torch.Tensor, patch: torch.Tensor, meta: torch.Tensor):
        img_feat   = self.backbone(img)                  # (B, embed_dim)
        patch_feat = self.fcrn(patch)                    # (B, embed_dim//2)
        fused      = torch.cat([img_feat, patch_feat, meta], dim=1)
        return self.classifier(fused)                    # (B, num_classes)