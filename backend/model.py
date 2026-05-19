import torch
import torch.nn as nn
import torchvision.models as models

EMBED_DIM = 256


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
        backbone_name: str = "efficientnet_v2_s",
    ):
        super().__init__()

        # ========================================================
        # Image backbone
        # ========================================================

        if backbone_name == "efficientnet_v2_s":
            try:
                backbone = models.efficientnet_v2_s(
                    weights=models.EfficientNet_V2_S_Weights.DEFAULT
                )

            except Exception:
                backbone = models.efficientnet_v2_s(
                    weights=None
                )

            in_features = backbone.classifier[-1].in_features

            backbone.classifier[-1] = nn.Linear(
                in_features,
                embed_dim,
            )

        elif backbone_name == "efficientnet_b2":
            try:
                backbone = models.efficientnet_b2(
                    weights=models.EfficientNet_B2_Weights.DEFAULT
                )

            except Exception:
                backbone = models.efficientnet_b2(
                    weights=None
                )

            in_features = backbone.classifier[-1].in_features

            backbone.classifier[-1] = nn.Linear(
                in_features,
                embed_dim,
            )

        else:
            raise ValueError(
                f"Unsupported backbone: {backbone_name}"
            )

        self.backbone = backbone

        # ========================================================
        # Patch branch
        # ========================================================

        self.fcrn = FCRN(
            embed_dim=embed_dim // 2
        )

        # ========================================================
        # Fusion classifier
        # ========================================================

        fused_dim = (
            embed_dim +
            embed_dim // 2 +
            meta_dim
        )

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
        # ========================================================
        # Full image branch
        # ========================================================

        img_feat = self.backbone(img)

        # ========================================================
        # Patch branch
        # Supports:
        # (B, N, 3, H, W)
        # OR
        # (B, 3, H, W)
        # ========================================================

        if patch.dim() == 5:
            B, N, C, H, W = patch.shape

            patch = patch.view(
                B * N,
                C,
                H,
                W,
            )

            patch_feat = self.fcrn(patch)

            patch_feat = patch_feat.view(
                B,
                N,
                -1,
            )

            patch_feat = patch_feat.mean(dim=1)

        else:
            patch_feat = self.fcrn(patch)

        # ========================================================
        # Fusion
        # ========================================================

        fused = torch.cat(
            [img_feat, patch_feat, meta],
            dim=1,
        )

        return self.classifier(fused)