"""
Generate the RAVI System onboarding PDF for new IC students.

Run:
    /tmp/pdfvenv/bin/python build_docs.py

Produces: docs/RAVI_System_Documentation.pdf
"""

import os
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import cm
from reportlab.platypus import (
    BaseDocTemplate, PageTemplate, Frame,
    Paragraph, Spacer, PageBreak, Table, TableStyle,
    KeepTogether, ListFlowable, ListItem, HRFlowable,
)
from reportlab.lib.enums import TA_LEFT, TA_JUSTIFY

BASE = os.path.dirname(os.path.abspath(__file__))
OUT_DIR = os.path.join(BASE, "docs")
os.makedirs(OUT_DIR, exist_ok=True)
OUT_PATH = os.path.join(OUT_DIR, "RAVI_System_Documentation.pdf")

# ── Color palette (matches the app) ────────────────────────────────────────
CYAN     = colors.HexColor("#00BCD4")
DARK     = colors.HexColor("#0A0E21")
INK      = colors.HexColor("#1F2937")
SUBTLE   = colors.HexColor("#6B7280")
ACCENT   = colors.HexColor("#FF6D00")
CODE_BG  = colors.HexColor("#F3F4F6")
RULE     = colors.HexColor("#E5E7EB")

# ── Styles ─────────────────────────────────────────────────────────────────
styles = getSampleStyleSheet()
title_style = ParagraphStyle(
    "TitleX", parent=styles["Title"],
    fontName="Helvetica-Bold", fontSize=28, leading=32,
    textColor=CYAN, spaceAfter=8,
)
subtitle_style = ParagraphStyle(
    "Subtitle", parent=styles["Normal"],
    fontSize=12, textColor=SUBTLE, leading=16,
)
h1 = ParagraphStyle(
    "H1", parent=styles["Heading1"],
    fontName="Helvetica-Bold", fontSize=20, leading=24,
    textColor=CYAN, spaceBefore=18, spaceAfter=10,
)
h2 = ParagraphStyle(
    "H2", parent=styles["Heading2"],
    fontName="Helvetica-Bold", fontSize=14, leading=18,
    textColor=INK, spaceBefore=14, spaceAfter=6,
)
h3 = ParagraphStyle(
    "H3", parent=styles["Heading3"],
    fontName="Helvetica-Bold", fontSize=11.5, leading=14,
    textColor=ACCENT, spaceBefore=10, spaceAfter=4,
)
body = ParagraphStyle(
    "Body", parent=styles["BodyText"],
    fontName="Helvetica", fontSize=10.5, leading=15,
    textColor=INK, alignment=TA_JUSTIFY, spaceAfter=6,
)
note = ParagraphStyle(
    "Note", parent=body,
    fontSize=9.5, leading=13, textColor=SUBTLE,
    leftIndent=10, borderPadding=8,
)
inline_code_style = ParagraphStyle(
    "InlineCode", parent=body, fontName="Courier", fontSize=10,
)
code_style = ParagraphStyle(
    "Code", parent=styles["Code"],
    fontName="Courier", fontSize=8.5, leading=11,
    textColor=INK, backColor=CODE_BG,
    borderPadding=(8, 10, 8, 10), leftIndent=0, rightIndent=0,
    spaceAfter=8, spaceBefore=2,
)

def code(text: str):
    """Render a fenced code block."""
    safe = (text.replace("&", "&amp;")
                 .replace("<", "&lt;")
                 .replace(">", "&gt;")
                 .replace("\n", "<br/>")
                 .replace(" ", "&nbsp;"))
    return Paragraph(f'<font face="Courier" size="8.5">{safe}</font>',
                     code_style)

def inline(text: str) -> str:
    return f'<font face="Courier" color="#0F766E">{text}</font>'

def p(text: str):
    return Paragraph(text, body)

def bullet_list(items):
    return ListFlowable(
        [ListItem(p(t), leftIndent=12, value="bullet") for t in items],
        bulletType="bullet", bulletColor=CYAN, leftIndent=18,
    )

def hrule():
    return HRFlowable(width="100%", thickness=0.6, color=RULE,
                      spaceBefore=8, spaceAfter=12)

# ── Header / footer ────────────────────────────────────────────────────────
def on_page(canvas, doc):
    canvas.saveState()
    canvas.setFont("Helvetica", 8.5)
    canvas.setFillColor(SUBTLE)
    # Header
    canvas.drawString(2 * cm, A4[1] - 1.2 * cm, "RAVI System — Documentation")
    canvas.drawRightString(A4[0] - 2 * cm, A4[1] - 1.2 * cm,
                           "Recognition Automated Via Infrared")
    canvas.setStrokeColor(RULE)
    canvas.setLineWidth(0.4)
    canvas.line(2 * cm, A4[1] - 1.4 * cm, A4[0] - 2 * cm, A4[1] - 1.4 * cm)
    # Footer
    canvas.drawCentredString(A4[0] / 2, 1.2 * cm,
                             f"Page {canvas.getPageNumber()}")
    canvas.restoreState()


# ── Document ───────────────────────────────────────────────────────────────
doc = BaseDocTemplate(
    OUT_PATH, pagesize=A4,
    leftMargin=2 * cm, rightMargin=2 * cm,
    topMargin=2 * cm, bottomMargin=2 * cm,
    title="RAVI System — Onboarding Documentation",
    author="Daniel Martins",
)
frame = Frame(doc.leftMargin, doc.bottomMargin,
              doc.width, doc.height, id="main")
doc.addPageTemplates([
    PageTemplate(id="standard", frames=[frame], onPage=on_page),
])

story = []

# ── Cover ──────────────────────────────────────────────────────────────────
story += [
    Spacer(1, 4 * cm),
    Paragraph("RAVI System", title_style),
    Paragraph("Recognition Automated Via Infrared", subtitle_style),
    Spacer(1, 0.4 * cm),
    Paragraph(
        "Onboarding documentation for the FTIR microplastic identification "
        "platform — covering the Flutter client, the Python MLP inference "
        "server, and the Firebase realtime database schema.",
        ParagraphStyle("Cover", parent=body, fontSize=11, leading=16,
                       textColor=SUBTLE),
    ),
    Spacer(1, 1.2 * cm),
    Table(
        [
            ["Project", "RAVI — Microplastic Identification by FTIR"],
            ["Author", "Daniel Martins (PhD)"],
            ["Audience", "Undergraduate research student (IC)"],
            ["Components", "Flutter app · FastAPI server · Firebase RTDB"],
            ["Repository", "/home/danielma/Documents/Doutorado/Sistema"],
        ],
        colWidths=[3.5 * cm, 12 * cm],
        style=TableStyle([
            ("FONT", (0, 0), (-1, -1), "Helvetica", 10),
            ("FONT", (0, 0), (0, -1), "Helvetica-Bold", 10),
            ("TEXTCOLOR", (0, 0), (0, -1), CYAN),
            ("TEXTCOLOR", (1, 0), (1, -1), INK),
            ("LINEBELOW", (0, 0), (-1, -2), 0.4, RULE),
            ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ("LEFTPADDING", (0, 0), (-1, -1), 0),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
            ("TOPPADDING", (0, 0), (-1, -1), 8),
        ]),
    ),
    PageBreak(),
]

# ── Table of contents (manual, since we know the structure) ────────────────
story += [
    Paragraph("Table of Contents", h1),
    hrule(),
    Table(
        [
            ["1.", "System overview"],
            ["2.", "Architecture and component map"],
            ["3.", "Repository layout"],
            ["4.", "Setup and running locally"],
            ["5.", "MLP inference server (mlp_server.py)"],
            ["6.", "Spectral storage (CSV files)"],
            ["7.", "Firebase database schema (multi-tenant)"],
            ["8.", "Flutter client architecture"],
            ["9.", "User flows"],
            ["10.", "Internationalisation (i18n)"],
            ["11.", "Common tasks (how-to)"],
            ["12.", "Troubleshooting"],
            ["13.", "Roadmap and known limitations"],
            ["A.", "Glossary"],
        ],
        colWidths=[1 * cm, 14 * cm],
        style=TableStyle([
            ("FONT", (0, 0), (-1, -1), "Helvetica", 10.5),
            ("TEXTCOLOR", (0, 0), (0, -1), CYAN),
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ]),
    ),
    PageBreak(),
]

# ── 1. System overview ─────────────────────────────────────────────────────
story += [
    Paragraph("1. System overview", h1),
    hrule(),
    p(
        "RAVI is a desktop and web application that supports microplastic "
        "research workflows: cataloguing field collections, registering "
        "individual samples, importing FTIR spectral data, running automatic "
        "polymer identification through a multilayer perceptron (MLP) model, "
        "and visualising the spectrum together with the model attention map."
    ),
    p(
        "The system is " + inline("multi-tenant") + ": each institution / "
        "laboratory has its own isolated namespace inside Firebase. Users "
        "of one institution cannot see or modify data from another. Only "
        "administrators can register new institutions, which prevents "
        "accidental tenant pollution during early adoption."
    ),
    Paragraph("What it solves", h2),
    bullet_list([
        "Centralises FTIR collections across collaborators in a single "
        "structured database, replacing scattered spreadsheets.",
        "Automates polymer identification (PE, PP, PS, PA, EVA, cellulose) "
        "by reusing the trained MLP from the BRACIS 2026 paper pipeline.",
        "Stores the spectral signal and the model's saliency map together, "
        "so reviewers can visually justify each identification.",
        "Provides traceable random sample IDs that do not leak collection "
        "order or operator-chosen names from the original CSV.",
    ]),
    Paragraph("Out of scope (for now)", h2),
    bullet_list([
        "Production-grade authentication: passwords are obfuscated with a "
        "salted base64 hash, not bcrypt/argon2. Plan: migrate to Firebase "
        "Auth before any external rollout.",
        "Granular per-collection permissions: every user inside an "
        "institution sees every collection of that institution.",
        "Automated retraining loop: verified samples are stored, but the "
        "training script is run manually outside the app.",
    ]),
    PageBreak(),
]

# ── 2. Architecture ────────────────────────────────────────────────────────
arch_text = """\
                +----------------------------------+
                |   Flutter app (web/desktop)      |
                |  ── lib/screens, services, l10n  |
                +-----------------+----------------+
                                  |
                  HTTPS REST      |       HTTP REST
                  (Firebase RTDB) |     (FastAPI MLP)
                                  v
        +-------------------------+--------------------------+
        |                                                    |
        v                                                    v
+-----------------+                               +-----------------------+
|  Firebase RTDB  |                               |  Python MLP server    |
|  /institutions/ |                               |  mlp_server.py        |
|    /<slug>/     |                               |  ── /predict          |
|      info       |                               |  ── /predict_csv      |
|      users      |                               |  ── /spectra/<inst>/  |
|      datasets   |                               |        <ds>/<sample>  |
|      samples    |                               +-----------+-----------+
+-----------------+                                           |
                                                              v
                                                +-----------------------------+
                                                | spectra_data/<inst>/<ds>.csv|
                                                | (per-tenant, per-dataset)   |
                                                +-----------------------------+
"""

story += [
    Paragraph("2. Architecture and component map", h1),
    hrule(),
    p(
        "Three independent processes cooperate. The Flutter client is the "
        "only thing the end user sees. It talks to two backends over HTTP: "
        "Firebase Realtime Database (metadata) and the local FastAPI server "
        "(model inference + bulky spectral data)."
    ),
    code(arch_text),
    Paragraph("Why two backends?", h3),
    p(
        "Metadata (sample names, polymer labels, attention summaries) lives "
        "in Firebase: small, indexed, multi-user. The raw spectrum (~1763 "
        "intensities per sample) would bloat each Firebase node, so it is "
        "stored as plain CSV on the inference server, keyed by sample ID. "
        "When the detail screen opens, the client fetches metadata from "
        "Firebase and the spectrum from the server, then renders both in "
        "the same chart."
    ),
    Paragraph("Network endpoints by default", h3),
    Table(
        [
            ["Service", "URL", "Notes"],
            ["Flutter dev server", "http://localhost:<flutter port>",
             "Served by `flutter run`"],
            ["MLP server", "http://localhost:8000",
             "Started by `python mlp_server.py`"],
            ["Firebase RTDB",
             "https://deepmicroplastics-default-rtdb.firebaseio.com",
             "Hardcoded in firebase_service.dart"],
        ],
        colWidths=[3.6 * cm, 7.6 * cm, 5.4 * cm],
        style=TableStyle([
            ("FONT", (0, 0), (-1, 0), "Helvetica-Bold", 9.5),
            ("FONT", (0, 1), (-1, -1), "Helvetica", 9.5),
            ("BACKGROUND", (0, 0), (-1, 0), CYAN),
            ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
            ("LINEBELOW", (0, 0), (-1, -1), 0.3, RULE),
            ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ("LEFTPADDING", (0, 0), (-1, -1), 6),
            ("RIGHTPADDING", (0, 0), (-1, -1), 6),
            ("TOPPADDING", (0, 0), (-1, -1), 5),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ]),
    ),
    PageBreak(),
]

# ── 3. Repository layout ───────────────────────────────────────────────────
tree_text = """\
Sistema/
├── mlp_server.py            # FastAPI inference + spectra storage
├── extract_scaler.py        # Builds scaler_params.json from training data
├── MLP_best_model.h5        # Trained Keras model (FTIR → polymer)
├── scaler_params.json       # MinMaxScaler params used by the server
├── DB_10cl_100sp.csv        # Sample CSV used during development
├── TDB.csv                  # Test database
├── spectra_data/            # Created at runtime (per-institution CSVs)
│   └── <institution_slug>/<dataset_id>.csv
├── docs/                    # Output directory for this PDF
└── deepmicroplastic/        # Flutter project root
    ├── lib/
    │   ├── main.dart                 # App entry, locale wiring
    │   ├── l10n/                     # Generated localisations + ARB
    │   │   ├── app_en.arb            # English source
    │   │   ├── app_pt.arb            # Portuguese source
    │   │   └── app_localizations*.dart   (gen-l10n output)
    │   ├── models/                   # Plain Dart data classes
    │   │   ├── institution_model.dart
    │   │   ├── user_model.dart
    │   │   └── spectrum_model.dart
    │   ├── services/                 # IO, no UI
    │   │   ├── firebase_service.dart    # Raw RTDB REST wrapper
    │   │   ├── institution_service.dart
    │   │   ├── auth_service.dart
    │   │   ├── dataset_service.dart
    │   │   ├── sample_service.dart
    │   │   ├── spectral_storage_service.dart
    │   │   ├── csv_import_service.dart
    │   │   ├── mlp_service.dart
    │   │   └── locale_service.dart
    │   ├── screens/                  # One screen = one .dart
    │   │   ├── login_screen.dart
    │   │   ├── new_institution_screen.dart
    │   │   ├── ftir_overview_screen.dart      (home)
    │   │   ├── add_dataset_screen.dart
    │   │   ├── dataset_detail_screen.dart
    │   │   ├── add_sample_screen.dart
    │   │   ├── sample_detail_screen.dart
    │   │   ├── import_csv_screen.dart
    │   │   ├── manage_users_screen.dart
    │   │   ├── manage_institutions_screen.dart
    │   │   └── user_form_screen.dart
    │   ├── utils/
    │   │   └── id_generator.dart           # Random traceable IDs
    │   └── widgets/
    │       ├── ftir_chart.dart             # Custom-painted FTIR chart
    │       └── language_menu.dart
    ├── assets/login_bg.jpg                  # Login background image
    ├── pubspec.yaml
    └── l10n.yaml
"""

story += [
    Paragraph("3. Repository layout", h1),
    hrule(),
    code(tree_text),
    p(
        "Two directories deserve attention. " + inline("lib/services/") +
        " is where every external IO call lives — never hit Firebase or "
        "the MLP server directly from a screen. " + inline("lib/l10n/") +
        " holds the source-of-truth ARB files; the corresponding "
        "Dart files are generated by " + inline("flutter gen-l10n") +
        " and should not be edited by hand."
    ),
    PageBreak(),
]

# ── 4. Setup ───────────────────────────────────────────────────────────────
setup_steps = """\
# 1. Python environment for the MLP server
cd /home/danielma/Documents/Doutorado/Sistema
python3 -m venv .venv
source .venv/bin/activate
pip install fastapi uvicorn tensorflow pandas numpy pydantic

# 2. Start the MLP server (in its own terminal)
python mlp_server.py
# → "Loading model from MLP_best_model.h5 ..."
# → Uvicorn running on http://0.0.0.0:8000

# 3. Flutter project
cd /home/danielma/Documents/Doutorado/Sistema/deepmicroplastic
flutter pub get
flutter gen-l10n          # Only after editing app_*.arb
flutter run -d chrome     # or -d linux / -d macos / -d windows
"""

story += [
    Paragraph("4. Setup and running locally", h1),
    hrule(),
    Paragraph("Prerequisites", h2),
    bullet_list([
        "Python 3.13+ with: tensorflow, fastapi, uvicorn, pandas, numpy, "
        "pydantic.",
        "Flutter 3.11+ (channel stable). Verify with " + inline("flutter --version") + ".",
        "A Firebase Realtime Database. The default URL is hardcoded in "
        + inline("lib/services/firebase_service.dart") + " — change it "
        "before deploying outside the lab.",
    ]),
    Paragraph("Quick start", h2),
    code(setup_steps),
    Paragraph("First-run experience", h2),
    p(
        "If the Firebase database has no " + inline("/institutions") + " node, "
        "the login screen automatically opens the institution-creation flow. "
        "The user fills in the institution name, an admin username and "
        "password — and after saving, the app boots straight into the home "
        "screen as that admin. From there, additional institutions can be "
        "added through " + inline("Menu → Manage Institutions") + "."
    ),
    PageBreak(),
]

# ── 5. MLP server ──────────────────────────────────────────────────────────
endpoints_table = [
    ["Method", "Path", "Body / params", "Purpose"],
    ["GET", "/health", "—", "Returns scaler mode + class list"],
    ["POST", "/predict",
     "{wavenumbers, intensities}",
     "Single-sample inference"],
    ["POST", "/predict_csv",
     "multipart file",
     "Batch inference; one CSV row per sample"],
    ["POST", "/spectra/{inst}/{dataset}",
     "{sample_id, wavenumbers, intensities}",
     "Persist a sample spectrum to disk"],
    ["GET", "/spectra/{inst}/{dataset}/{sample_id}",
     "—",
     "Reload that spectrum"],
    ["DELETE", "/spectra/{inst}/{dataset}/{sample_id}",
     "—",
     "Remove a single row from the dataset CSV"],
]

story += [
    Paragraph("5. MLP inference server (mlp_server.py)", h1),
    hrule(),
    p(
        "FastAPI process loaded once at startup. It owns the trained model "
        "(" + inline("MLP_best_model.h5") + "), the optional scaler "
        "(" + inline("scaler_params.json") + "), and the on-disk CSVs that "
        "store raw spectra per dataset. CORS is wide-open — fine for the "
        "lab network, tighten before any public deployment."
    ),
    Paragraph("Endpoints", h2),
    Table(
        endpoints_table,
        colWidths=[1.6 * cm, 4.6 * cm, 4.5 * cm, 5.9 * cm],
        style=TableStyle([
            ("FONT", (0, 0), (-1, 0), "Helvetica-Bold", 9),
            ("FONT", (0, 1), (-1, -1), "Helvetica", 8.5),
            ("FONT", (1, 1), (1, -1), "Courier", 8.2),
            ("FONT", (2, 1), (2, -1), "Courier", 8.2),
            ("BACKGROUND", (0, 0), (-1, 0), CYAN),
            ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
            ("LINEBELOW", (0, 0), (-1, -1), 0.3, RULE),
            ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ("LEFTPADDING", (0, 0), (-1, -1), 5),
            ("RIGHTPADDING", (0, 0), (-1, -1), 5),
            ("TOPPADDING", (0, 0), (-1, -1), 5),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ]),
    ),
    Spacer(1, 0.4 * cm),
    Paragraph("Inference pipeline", h2),
    p(
        "For each sample the server: (1) interpolates the user's "
        "(wavenumber, intensity) pairs onto the model's fixed grid of 1763 "
        "points from 3998 to 600 cm⁻¹; (2) applies the MinMaxScaler if "
        "" + inline("scaler_params.json") + " is present, otherwise falls "
        "back to per-sample normalisation; (3) runs the Keras model and "
        "computes the saliency by " + inline("|grad × x|") + ", normalised "
        "to [0, 1]. The response carries the predicted class, the "
        "confidence, the wavenumbers/intensities and the saliency vector "
        "aligned with the wavenumber grid."
    ),
    Paragraph("Polymer classes", h2),
    p(
        "The trained model recognises six classes: "
        + inline("EVA, PA, PE, PP, PS, cellulose_like") + ". The Flutter "
        "client maps these to its " + inline("PolymerType") + " enum and "
        "renders them with consistent colours and full names "
        "(see " + inline("lib/models/spectrum_model.dart") + ")."
    ),
    PageBreak(),
]

# ── 6. Spectral storage ────────────────────────────────────────────────────
csv_example = """\
sample_id,3998.0,3995.7,3993.4, ... ,602.4,600.0
smp-x9p7k2qa3jvw,0.0123,0.0119,0.0115, ... ,0.0341,0.0322
smp-3kk2pqahjabc,0.0421,0.0414,0.0407, ... ,0.0091,0.0088
"""

story += [
    Paragraph("6. Spectral storage (CSV files)", h1),
    hrule(),
    p(
        "Each dataset has its own CSV file under "
        + inline("spectra_data/<institution_slug>/<dataset_id>.csv") + ". "
        "Columns: the first holds the random sample ID, the rest are the "
        "intensities indexed by the wavenumbers (CSV header). When the "
        "detail screen opens, the Flutter client requests the row by ID "
        "and rebuilds the spectrum on the fly."
    ),
    code(csv_example),
    Paragraph("Why a CSV per dataset?", h2),
    bullet_list([
        "Firebase RTDB has practical limits on node size — embedding 1763 "
        "floats per sample would slow every list query.",
        "Plain CSV is exportable for retraining without ETL: each file "
        "is already a valid input for the training pipeline.",
        "Tenant separation is enforced at the filesystem level: the "
        "directory layout makes it impossible to read another institution's "
        "spectrum by accident.",
    ]),
    Paragraph("Re-aligning headers", h2),
    p(
        "If a sample comes from a CSV with a slightly different wavenumber "
        "grid (e.g. 1700 columns instead of 1763), "
        + inline("save_spectrum") + " interpolates the new intensities onto "
        "the dataset's existing header before appending. This guarantees "
        "the file stays rectangular and importable into pandas."
    ),
    PageBreak(),
]

# ── 7. Firebase schema ─────────────────────────────────────────────────────
schema = """\
/institutions
   /<slug>                              # e.g. "usp-iag" (lowercase, ASCII)
       /info
           name:        "USP — IAG"
           createdBy:   "admin"
           createdAt:   1714588800000
       /users
           /<username>                  # e.g. "jsilva"
               name:         "João Silva"
               email:        "jsilva@usp.br"
               department:   "Lab. Oceanografia"
               role:         "admin" | "researcher"
               passwordHash: "<base64('raviDeepMp_' + password)>"
               createdAt:    1714588800000
       /datasets
           /<datasetId>                 # e.g. "ds-1714588900000"
               name:            "Praia do Futuro — Apr/2024"
               description:     "Surface sediment, 5 points"
               location:        "Fortaleza, CE"
               createdAt:       1714588900000
               createdBy:       "jsilva"
               microscopeMode:  "atr" | "transmission" | "reflection"
               microscopeModel: "Bruker Vertex 70 + Hyperion 3000"
               resolution:      4.0
               numScans:        64
               detectorType:    "MCT"
               crystalType:     "Diamante"
               dataType:        "absorbance" | "transmittance"
       /samples
           /<sampleId>                  # random, e.g. "smp-x9p7k2qa3jvw"
               datasetId:       "ds-1714588900000"
               name:            "PF-K7XN3F"          (display name, random)
               collectionSite:  "Point 4 — North Shore"
               collectionDate:  1714588800000
               dataType:        "absorbance"
               notes:            "..."
               isVerified:       true
               verifiedBy:       "jsilva"
               createdAt:        1714588950000
               createdBy:        "jsilva"
               result:                                # optional, set after MLP
                   polymer:              "pe"
                   confidence:           0.97
                   decisionWavenumber:   2919.0
                   reasoning:            "..."
                   keyPeaks:             ["2919 cm⁻¹ — ...", ...]
                   attentionMap:
                       - { wn: 3998.0, att: 0.001 }
                       - { wn: 3995.7, att: 0.003 }
                       ...
"""

story += [
    Paragraph("7. Firebase database schema (multi-tenant)", h1),
    hrule(),
    p(
        "Every entity lives under " + inline("/institutions/<slug>") + ", "
        "so removing a tenant is a single recursive delete. The Flutter "
        "services already enforce this layout — no screen ever builds a "
        "raw Firebase path."
    ),
    code(schema),
    Paragraph("Where this is implemented", h2),
    Table(
        [
            ["Path prefix", "Service file"],
            ["/institutions", "lib/services/institution_service.dart"],
            ["/institutions/<slug>/users",
             "lib/services/auth_service.dart"],
            ["/institutions/<slug>/datasets",
             "lib/services/dataset_service.dart"],
            ["/institutions/<slug>/samples",
             "lib/services/sample_service.dart"],
        ],
        colWidths=[6 * cm, 10.6 * cm],
        style=TableStyle([
            ("FONT", (0, 0), (-1, 0), "Helvetica-Bold", 9.5),
            ("FONT", (0, 1), (-1, -1), "Courier", 9),
            ("BACKGROUND", (0, 0), (-1, 0), CYAN),
            ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
            ("LINEBELOW", (0, 0), (-1, -1), 0.3, RULE),
            ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ("LEFTPADDING", (0, 0), (-1, -1), 6),
            ("TOPPADDING", (0, 0), (-1, -1), 5),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
        ]),
    ),
    Paragraph("Identifier conventions", h2),
    bullet_list([
        inline("slug") + ": ASCII lowercase, hyphen-separated. Generated "
        "automatically by " + inline("InstitutionModel.slugify(name)") + ".",
        inline("datasetId") + ": " + inline("ds-<timestamp>") + ", "
        "generated by " + inline("DatasetService.save") + ".",
        inline("sampleId") + ": " + inline("smp-<12 random chars>") + ", "
        "generated by " + inline("SampleIdGenerator.generateInternalId()") + ".",
        inline("sample.name") + ": " + inline("<prefix>-<6 random chars>")
        + ", e.g. " + inline("PF-K7XN3F") + ". The prefix comes from the "
        "dataset name (first letters of the first significant words).",
    ]),
    PageBreak(),
]

# ── 8. Flutter architecture ────────────────────────────────────────────────
story += [
    Paragraph("8. Flutter client architecture", h1),
    hrule(),
    p(
        "There is no third-party state-management library: the app relies "
        "on " + inline("StatefulWidget") + " plus a single global "
        + inline("ChangeNotifier") + " for the locale. Each screen owns "
        "its own state and calls services directly. This keeps the "
        "navigation predictable and easy to reason about."
    ),
    Paragraph("Layered structure", h2),
    bullet_list([
        inline("models/") + " — plain data classes with "
        + inline("toMap") + " / " + inline("fromMap") + " converters. No "
        "framework imports.",
        inline("services/") + " — every HTTP call lives here. Returns "
        "models or null/booleans on failure. UI never imports "
        + inline("http") + " directly.",
        inline("screens/") + " — one widget per screen. Reads from services "
        "in " + inline("initState") + ", refreshes on " + inline("pop") + ".",
        inline("widgets/") + " — reusable visual components ("
        + inline("FtirChart") + ", " + inline("LanguageMenu") + ").",
        inline("utils/") + " — pure functions (id generator).",
    ]),
    Paragraph("Why no Provider / Riverpod / Bloc?", h3),
    p(
        "The app does not yet have a workflow that needs cross-screen "
        "reactive state. Every navigation is push/pop; data is reloaded "
        "from Firebase on return so the UI never goes stale. If the user "
        "base grows, switching to Riverpod is the cleanest upgrade path."
    ),
    Paragraph("Custom-painted spectrum chart", h2),
    p(
        inline("lib/widgets/ftir_chart.dart") + " draws the FTIR plot using "
        + inline("CustomPainter") + ". It overlays three layers: the "
        "intensity curve, the model's attention heatmap, and the "
        "decision-point dashed line. A toggle lets the user switch between "
        "absorbance and transmittance — derived on the fly via the "
        + inline("SpectrumSample.asTransmittance") + " / "
        + inline("asAbsorbance") + " getters."
    ),
    PageBreak(),
]

# ── 9. User flows ──────────────────────────────────────────────────────────
flow_first = """\
Cold start (empty database):
  Login screen detects no institutions → "Create first admin" banner
  → New Institution screen
  → User fills institution name + admin credentials
  → Returns to login pre-filled with the slug
  → Sign in
"""

flow_login = """\
Returning user:
  Login screen → enter institution slug
  → Continue → if found, ask username+password
  → Sign in → home (FtirOverviewScreen)
"""

flow_sample = """\
Creating samples (from a collection):
  Home → tap a collection → DatasetDetailScreen
  → "+" New Sample
      Tab "Individual": fill site/date, optionally attach a single-row CSV
                        → save → goes through MLP if attached
      Tab "Batch":      type quantity → save N empty samples,
                        OR click "Import batch from CSV"
                        → ImportCsvScreen with shared site/notes inherited
                        → bulk MLP inference, then mass save
"""

flow_identify = """\
Running identification later:
  Sample detail → biotech icon (top-right)
  → POST /predict to mlp_server
  → Saves polymer + attentionMap to Firebase
  → Spectrum chart updates with attention heatmap
"""

story += [
    Paragraph("9. User flows", h1),
    hrule(),
    Paragraph("First execution (database empty)", h3),
    code(flow_first),
    Paragraph("Returning user", h3),
    code(flow_login),
    Paragraph("Adding samples (three ways)", h3),
    code(flow_sample),
    Paragraph("Running identification", h3),
    code(flow_identify),
    PageBreak(),
]

# ── 10. i18n ───────────────────────────────────────────────────────────────
i18n_steps = """\
# 1. Add the new key to BOTH ARB files
#    (lib/l10n/app_en.arb and lib/l10n/app_pt.arb)
"helloUser": "Hello, {name}",
"@helloUser": { "placeholders": { "name": {} } }

# 2. Regenerate Dart files
flutter gen-l10n

# 3. Use it in any widget
final l = AppLocalizations.of(context);
Text(l.helloUser('Daniel'))
"""

story += [
    Paragraph("10. Internationalisation (i18n)", h1),
    hrule(),
    p(
        "The app starts in English. Users can switch to Portuguese from "
        "the language menu, available both on the login screen and inside "
        "the home menu. The choice is persisted in "
        + inline("SharedPreferences") + " by "
        + inline("LocaleService") + ", which exposes a "
        + inline("ChangeNotifier") + " that " + inline("RaviApp") + " "
        "listens to — switching the locale rebuilds the entire widget tree "
        "without restarting."
    ),
    Paragraph("Adding a new translatable string", h2),
    code(i18n_steps),
    Paragraph("ARB conventions", h3),
    bullet_list([
        "Keys use camelCase, grouped by screen/feature ("
        + inline("homeKpiTotalSamples") + ", " + inline("addSampleSiteHint") + ").",
        "Always edit both " + inline("app_en.arb") + " and "
        + inline("app_pt.arb") + " — missing keys throw at runtime.",
        "Use " + inline("@key") + " metadata for placeholders, e.g. "
        + inline('"@datasetSamples": { "placeholders": { "n": { "type": "int" } } }') + ".",
        "Generated files (" + inline("app_localizations*.dart") + ") "
        "are committed for editor support but are regenerated on every "
        + inline("flutter gen-l10n") + " — never edit them by hand.",
    ]),
    Paragraph("RAVI acronym", h2),
    p(
        "The acronym " + inline("RAVI") + " is fixed across locales. Only "
        "the expansion changes: in English it stands for "
        + inline("Recognition Automated Via Infrared") + ", in Portuguese "
        + inline("Reconhecimento Automatizado Via Infravermelho") + "."
    ),
    PageBreak(),
]

# ── 11. Common tasks ───────────────────────────────────────────────────────
new_screen = """\
// 1. Create lib/screens/my_screen.dart
class MyScreen extends StatelessWidget { ... }

// 2. Add localisations (both ARB) and run flutter gen-l10n.

// 3. Navigate from wherever:
Navigator.push(context, MaterialPageRoute(
    builder: (_) => MyScreen(loggedUser: widget.loggedUser),
));
"""

new_endpoint = """\
# 1. Add the route in mlp_server.py
@app.post("/something/{institution_slug}")
def my_route(institution_slug: str, req: MyRequest):
    ...

# 2. Add the Dart wrapper in services/
class SomethingService {
  static Future<...> call({...}) async {
    final res = await http.post(...);
    ...
  }
}

# 3. Restart the Python server (Uvicorn auto-reload is OFF by default).
"""

new_polymer = """\
# 1. Retrain MLP_best_model.h5 with the extra class.
# 2. Update CLASS_NAMES in mlp_server.py.
# 3. Add the matching enum value in lib/models/spectrum_model.dart
#    (PolymerType, label, fullName, color).
# 4. Update _mapPolymer() in csv_import_service.dart and mlp_service.dart.
# 5. Optionally: add diagnostic peaks in the same files.
"""

story += [
    Paragraph("11. Common tasks (how-to)", h1),
    hrule(),
    Paragraph("Add a new screen", h2),
    code(new_screen),
    Paragraph("Add a new server endpoint", h2),
    code(new_endpoint),
    Paragraph("Add a new polymer class", h2),
    code(new_polymer),
    Paragraph("Change the Firebase database URL", h2),
    p(
        "Edit the constant " + inline("_base") + " in "
        + inline("lib/services/firebase_service.dart") + ". This is the "
        "single point of change — every other service derives its path "
        "from there."
    ),
    Paragraph("Change the MLP server URL", h2),
    p(
        "There are three references to " + inline("http://localhost:8000")
        + ": " + inline("MlpService") + ", " + inline("CsvImportService")
        + " and " + inline("SpectralStorageService") + ". When deploying "
        "outside the dev box, extract these into a shared constant."
    ),
    PageBreak(),
]

# ── 12. Troubleshooting ────────────────────────────────────────────────────
trouble = [
    ["Symptom", "Likely cause", "Fix"],
    ["“Could not reach the MLP server”",
     "mlp_server.py not running, or wrong host",
     "Run python mlp_server.py; verify /health returns 200"],
    ["Login: Institution not found",
     "Database empty or wrong slug",
     "Use first-run flow, or check /institutions in Firebase"],
    ["FTIR chart blank after restart",
     "Spectrum CSV missing on the server",
     "Check spectra_data/<inst>/<dataset>.csv exists"],
    ["CSV import fails 400",
     "CSV without numeric column headers",
     "Make sure column names are wavenumbers (e.g. 600.0)"],
    ["UI still in Portuguese after change",
     "SharedPreferences cached or hot reload skipped",
     "Restart the app; LocaleService re-reads on boot"],
    ["flutter gen-l10n complains",
     "Missing key in one of the ARBs",
     "Diff app_en.arb and app_pt.arb — every key must exist in both"],
]

story += [
    Paragraph("12. Troubleshooting", h1),
    hrule(),
    Table(
        trouble,
        colWidths=[5 * cm, 5.5 * cm, 6.6 * cm],
        style=TableStyle([
            ("FONT", (0, 0), (-1, 0), "Helvetica-Bold", 9),
            ("FONT", (0, 1), (-1, -1), "Helvetica", 8.5),
            ("BACKGROUND", (0, 0), (-1, 0), CYAN),
            ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
            ("LINEBELOW", (0, 0), (-1, -1), 0.3, RULE),
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("LEFTPADDING", (0, 0), (-1, -1), 6),
            ("RIGHTPADDING", (0, 0), (-1, -1), 6),
            ("TOPPADDING", (0, 0), (-1, -1), 6),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ]),
    ),
    PageBreak(),
]

# ── 13. Roadmap ────────────────────────────────────────────────────────────
story += [
    Paragraph("13. Roadmap and known limitations", h1),
    hrule(),
    Paragraph("Short term", h2),
    bullet_list([
        "Migrate authentication from the current base64 hash to Firebase "
        "Authentication. The Dart layer already isolates auth in "
        + inline("AuthService") + ", so the swap is local.",
        "Replace the hardcoded " + inline("http://localhost:8000") + " in "
        "the three services with a build-time configurable constant.",
        "Add per-collection ACLs so a researcher only sees collections "
        "they participate in.",
    ]),
    Paragraph("Medium term", h2),
    bullet_list([
        "Hook a retraining pipeline to the verified samples: every time "
        "an admin marks a batch as " + inline("isVerified") + ", append "
        "those rows to the training set.",
        "Migrate the dataset / sample listings to Firestore (paginated "
        "queries) once the per-tenant data grows past a few thousand rows.",
        "Move FTIR chart rendering to GPU (Skia paint primitives) for "
        "smoother scrolling on long spectra.",
    ]),
    Paragraph("Open questions", h2),
    bullet_list([
        "Should institutions support sub-tenants (departments)? Today "
        "all users of a slug share everything.",
        "Storage strategy for very large CSVs (>10 MB) — keep on disk or "
        "move to object storage?",
        "Whether to expose a RAVI public API (e.g. for other research "
        "groups to submit spectra for blind testing).",
    ]),
    PageBreak(),
]

# ── A. Glossary ────────────────────────────────────────────────────────────
glossary = [
    ["Term", "Meaning"],
    ["FTIR", "Fourier-Transform InfraRed spectroscopy — the technique used "
             "to record the absorbance/transmittance signal."],
    ["MLP", "Multilayer Perceptron — feed-forward neural network used here "
            "to classify the polymer."],
    ["Saliency / attention", "Per-wavenumber importance derived from the "
            "model gradient, |grad × x|. Visualised as the orange heatmap."],
    ["Tenant / institution",
     "An isolated namespace in the database. Identified by a slug."],
    ["Slug", "ASCII-only, lowercase, hyphenated identifier derived from "
             "the institution name."],
    ["ARB", "Application Resource Bundle — JSON-based file format used by "
            "Flutter for translations."],
    ["Decision wavenumber",
     "The single wavenumber that the model uses as the strongest evidence "
     "for the predicted polymer class. Drawn as a yellow dashed line."],
]

story += [
    Paragraph("Appendix A. Glossary", h1),
    hrule(),
    Table(
        glossary,
        colWidths=[4 * cm, 13 * cm],
        style=TableStyle([
            ("FONT", (0, 0), (-1, 0), "Helvetica-Bold", 9.5),
            ("FONT", (0, 1), (-1, -1), "Helvetica", 9),
            ("BACKGROUND", (0, 0), (-1, 0), CYAN),
            ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
            ("LINEBELOW", (0, 0), (-1, -1), 0.3, RULE),
            ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ("LEFTPADDING", (0, 0), (-1, -1), 6),
            ("RIGHTPADDING", (0, 0), (-1, -1), 6),
            ("TOPPADDING", (0, 0), (-1, -1), 6),
            ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
        ]),
    ),
]

doc.build(story)
print(f"Wrote {OUT_PATH}")
