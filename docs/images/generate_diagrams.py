"""Regenerates the PNG diagrams in docs/images. Run: python docs/images/generate_diagrams.py"""
from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

OUT = Path(__file__).parent
NAVY, BLUE, TEAL, GREEN, ORANGE, RED, PURPLE, GREY = "#0B3D5C", "#0078D4", "#008575", "#107C10", "#D83B01", "#A4262C", "#5C2D91", "#605E5C"
plt.rcParams["font.family"] = "DejaVu Sans"


def box(ax, x, y, w, h, title, sub="", color=BLUE, fill=None, tsize=10.5, ssize=8.5, alpha=1):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.02,rounding_size=0.12",
                                fc=fill or "white", ec=color, lw=1.8, alpha=alpha))
    ty = y + h / 2 + (0.13 if sub else 0)
    ax.text(x + w / 2, ty, title, ha="center", va="center", fontsize=tsize, weight="bold", color=color)
    if sub:
        ax.text(x + w / 2, y + h / 2 - 0.2, sub, ha="center", va="center", fontsize=ssize, color=GREY)


def zone(ax, x, y, w, h, label, color, fill):
    ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.02,rounding_size=0.2",
                                fc=fill, ec=color, lw=1.5, ls="--"))
    ax.text(x + 0.15, y + h - 0.25, label, fontsize=10, weight="bold", color=color, va="center")


def arrow(ax, x1, y1, x2, y2, label="", color=NAVY, ls="-", rad=0.0, lpos=None):
    ax.add_patch(FancyArrowPatch((x1, y1), (x2, y2), arrowstyle="-|>", mutation_scale=14,
                                 color=color, lw=1.6, ls=ls, connectionstyle=f"arc3,rad={rad}"))
    if label:
        lx, ly = lpos or ((x1 + x2) / 2, (y1 + y2) / 2 + 0.14)
        ax.text(lx, ly, label, fontsize=8, color=color, ha="center",
                bbox=dict(fc="white", ec="none", pad=1))


def canvas(w, h, title, subtitle):
    fig, ax = plt.subplots(figsize=(w, h), dpi=150)
    ax.set_xlim(0, w); ax.set_ylim(0, h); ax.axis("off")
    fig.patch.set_facecolor("white")
    ax.text(0.3, h - 0.4, title, fontsize=17, weight="bold", color=NAVY, va="center")
    ax.text(0.3, h - 0.8, subtitle, fontsize=10, color=GREY, va="center")
    return fig, ax


def architecture():
    fig, ax = canvas(16, 10, "SecureBank Platform - Azure Architecture",
                     "UK South | Hub-and-spoke | Zero-trust networking | PCI DSS-aligned controls")
    box(ax, 0.4, 7.0, 1.8, 1.0, "Customers", "Web / Mobile", NAVY)
    box(ax, 0.4, 4.6, 1.8, 1.0, "GitHub Actions", "OIDC - no secrets", PURPLE)
    box(ax, 0.4, 2.3, 1.8, 1.0, "Engineers", "Entra ID + PIM", NAVY)

    zone(ax, 2.7, 0.4, 13.0, 8.4, "Azure Subscription - rg-securebank-<env>-uks", BLUE, "#F3F9FD")
    zone(ax, 3.0, 5.3, 3.4, 3.0, "Hub VNet 10.x0.0.0/16", TEAL, "#EEF8F6")
    box(ax, 3.3, 6.6, 2.8, 1.0, "App Gateway WAF v2", "OWASP DRS 2.1 + Bot + rate limit", TEAL, ssize=7.5)
    box(ax, 3.3, 5.5, 2.8, 0.8, "Azure Bastion", "", TEAL)

    zone(ax, 6.8, 0.7, 6.0, 7.6, "Spoke VNet 10.x1.0.0/16", GREEN, "#F1F8F1")
    zone(ax, 7.0, 4.4, 5.6, 3.5, "AKS (Azure CNI Overlay + Cilium)", BLUE, "white")
    box(ax, 7.2, 6.5, 1.7, 0.9, "web-frontend", "nginx", BLUE, tsize=9)
    box(ax, 9.0, 6.5, 1.7, 0.9, "accounts", "FastAPI", BLUE, tsize=9)
    box(ax, 10.8, 6.5, 1.7, 0.9, "transactions", "FastAPI", BLUE, tsize=9)
    ax.text(9.8, 5.9, "HPA | PDB | NetworkPolicy | Workload Identity", ha="center", fontsize=8.5, color=GREY)
    ax.text(9.8, 5.5, "Pod Security: restricted | Gatekeeper: ACR-only", ha="center", fontsize=8.5, color=GREY)
    ax.text(9.8, 5.1, "System pool + Apps pool across 3 zones", ha="center", fontsize=8.5, color=GREY)
    ax.text(9.8, 4.7, "Defender for Containers", ha="center", fontsize=8.5, color=GREY)

    zone(ax, 7.0, 0.9, 5.6, 3.1, "Private endpoints (no public access)", ORANGE, "#FFF6F1")
    box(ax, 7.2, 2.4, 2.6, 1.1, "PostgreSQL Flex", "Zone-redundant HA | TLS", ORANGE, ssize=7.5)
    box(ax, 9.9, 2.4, 2.5, 1.1, "Key Vault Premium", "HSM | RBAC | purge prot.", ORANGE, ssize=7.5)
    box(ax, 7.2, 1.1, 5.2, 1.0, "Azure Container Registry Premium", "Private Link | content trust | Trivy-scanned images", ORANGE, ssize=7.5)

    zone(ax, 13.1, 0.7, 2.4, 7.6, "Observability", PURPLE, "#F6F2FA")
    box(ax, 13.25, 6.4, 2.1, 1.0, "Log Analytics", "365d in prod", PURPLE, tsize=9.5)
    box(ax, 13.25, 5.0, 2.1, 1.0, "App Insights", "traces", PURPLE, tsize=9.5)
    box(ax, 13.25, 3.6, 2.1, 1.0, "Azure Monitor", "alerts", PURPLE, tsize=9.5)
    box(ax, 13.25, 2.2, 2.1, 1.0, "Defender", "for Cloud", PURPLE, tsize=9.5)
    box(ax, 13.25, 0.9, 2.1, 0.9, "Budgets", "FinOps", PURPLE, tsize=9.5)

    arrow(ax, 2.2, 7.5, 3.3, 7.1, "HTTPS")
    arrow(ax, 6.1, 7.1, 7.2, 7.0, "AGIC", TEAL)
    arrow(ax, 8.9, 6.95, 9.0, 6.95)
    arrow(ax, 10.7, 6.95, 10.8, 6.95)
    arrow(ax, 8.5, 4.4, 8.5, 3.5, "TLS 5432", ORANGE, lpos=(9.15, 4.17))
    arrow(ax, 11.15, 4.4, 11.15, 3.5, "CSI secrets", ORANGE, lpos=(11.9, 4.17))
    arrow(ax, 2.2, 5.1, 7.2, 1.6, "push image", PURPLE, rad=0.15)
    arrow(ax, 2.2, 5.0, 7.0, 4.9, "helm deploy", PURPLE)
    arrow(ax, 2.2, 2.8, 3.3, 5.8, "", NAVY, ls="--")
    arrow(ax, 12.6, 6.2, 13.25, 6.8, "", PURPLE, ls="--")
    fig.savefig(OUT / "architecture.png", bbox_inches="tight", facecolor="white")
    plt.close(fig)


def pipeline():
    fig, ax = canvas(16, 6.4, "CI/CD Pipeline - GitHub Actions + OIDC",
                     "Every change is tested, scanned and promoted dev -> staging -> prod with approval gates")
    stages = [
        ("Commit / PR", "pre-commit\ngitleaks", GREY),
        ("Static checks", "terraform fmt\ntflint | checkov", PURPLE),
        ("Test", "pytest\nunit tests", BLUE),
        ("Build & scan", "docker build\nTrivy HIGH/CRIT", ORANGE),
        ("Plan", "terraform plan\nPR comment", TEAL),
        ("Push", "ACR via OIDC\nimmutable SHA tag", BLUE),
    ]
    x = 0.3
    for i, (t, s, c) in enumerate(stages):
        box(ax, x, 2.9, 2.2, 1.5, t, "", c, tsize=10.5)
        ax.text(x + 1.1, 3.35, s, ha="center", va="center", fontsize=8.3, color=GREY)
        if i < len(stages) - 1:
            arrow(ax, x + 2.2, 3.65, x + 2.45, 3.65)
        x += 2.45
    envs = [("DEV", "auto-deploy", GREEN, 2.3), ("STAGING", "1 reviewer", ORANGE, 6.7), ("PROD", "2 reviewers + change ticket", RED, 11.1)]
    for name, sub, c, ex in envs:
        box(ax, ex, 0.5, 3.4, 1.4, f"Deploy {name}", sub, c, fill="white")
        ax.text(ex + 1.7, 0.75, "helm --atomic | smoke test", ha="center", fontsize=8, color=GREY)
    arrow(ax, 14.0, 2.9, 3.9, 1.95, "merge to main", NAVY, rad=-0.15, lpos=(9.0, 2.35))
    arrow(ax, 5.7, 1.2, 6.7, 1.2, "approve", ORANGE)
    arrow(ax, 10.1, 1.2, 11.1, 1.2, "approve", RED)
    ax.text(14.7, 1.2, "Auto-rollback\non failure", fontsize=8.5, color=RED, ha="left", va="center")
    fig.savefig(OUT / "cicd-pipeline.png", bbox_inches="tight", facecolor="white")
    plt.close(fig)


def network():
    fig, ax = canvas(14, 7.5, "Network Topology & Isolation", "Per-environment address spaces never overlap - ready for future peering / ExpressRoute")
    rows = [("dev", "10.10.0.0/16", "10.11.0.0/16", GREEN), ("staging", "10.20.0.0/16", "10.21.0.0/16", ORANGE), ("prod", "10.30.0.0/16", "10.31.0.0/16", RED)]
    y = 4.9
    for env, hub, spoke, c in rows:
        ax.text(0.4, y + 0.55, env.upper(), fontsize=13, weight="bold", color=c, va="center")
        box(ax, 1.9, y, 4.0, 1.1, f"Hub {hub}", "snet-appgw /24 | AzureBastionSubnet /26", TEAL, ssize=8)
        box(ax, 7.4, y, 6.2, 1.1, f"Spoke {spoke}", "snet-aks /20 | snet-pe /24 (NSG) | snet-postgres /24 (delegated)", GREEN, ssize=8)
        arrow(ax, 5.9, y + 0.7, 7.4, y + 0.7, "peering", NAVY)
        arrow(ax, 7.4, y + 0.4, 5.9, y + 0.4, "", NAVY)
        y -= 1.7
    ax.text(0.4, 0.45, "NSG on snet-pe: allow only snet-aks -> 443/5432, deny all else  |  Private DNS: vaultcore, azurecr, postgres",
            fontsize=9, color=GREY)
    fig.savefig(OUT / "network-topology.png", bbox_inches="tight", facecolor="white")
    plt.close(fig)


def banner():
    fig = plt.figure(figsize=(12, 6.27), dpi=150)  # ~1200x627 LinkedIn link-share ratio
    ax = fig.add_axes([0, 0, 1, 1])
    ax.set_xlim(0, 12); ax.set_ylim(0, 6.27); ax.axis("off")
    fig.patch.set_facecolor(NAVY)
    ax.add_patch(plt.Rectangle((0, 0), 12, 6.27, color=NAVY))
    ax.add_patch(plt.Rectangle((0, 0), 0.25, 6.27, color=BLUE))
    ax.text(0.8, 5.0, "SecureBank Platform", fontsize=34, weight="bold", color="white")
    ax.text(0.8, 4.25, "Production-grade banking infrastructure on Azure", fontsize=16, color="#BFE3FF")
    tags = ["Terraform", "AKS", "GitHub Actions OIDC", "Helm", "WAF v2", "Key Vault HSM", "PostgreSQL HA", "PCI DSS v4.0"]
    x, y = 0.8, 3.1
    for t in tags:
        w = 0.14 * len(t) + 0.5
        if x + w > 11.4:
            x, y = 0.8, y - 0.75
        ax.add_patch(FancyBboxPatch((x, y), w, 0.5, boxstyle="round,pad=0.02,rounding_size=0.2", fc=BLUE, ec="none"))
        ax.text(x + w / 2, y + 0.25, t, ha="center", va="center", fontsize=11, color="white", weight="bold")
        x += w + 0.25
    ax.text(0.8, 1.15, "John Surender  |  Azure Cloud & DevOps Engineer", fontsize=14, color="white", weight="bold")
    ax.text(0.8, 0.6, "github.com/JohnSurender/azure-securebank-platform", fontsize=12, color="#BFE3FF")
    fig.savefig(OUT / "linkedin-banner.png", facecolor=NAVY)
    plt.close(fig)


if __name__ == "__main__":
    architecture(); pipeline(); network(); banner()
    print("Diagrams written to", OUT)
