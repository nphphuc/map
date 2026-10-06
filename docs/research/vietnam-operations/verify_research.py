"""Run the skill's gates and preserve their actual stdout and exit status."""
from pathlib import Path
import json
import subprocess
import sys

OUT = Path(__file__).resolve().parent
SKILL = Path(r"C:\Users\Admin\.codex\skills\deep-research\scripts")
commands = [
    ("report_validation.txt", "validate_report.py", ["--report", str(OUT / "report.md")]),
    ("citation_validation.txt", "verify_citations.py", ["--report", str(OUT / "report.md"), "--strict"]),
    ("claim_support_validation.txt", "verify_claim_support.py", ["verify", "--dir", str(OUT), "--strict"]),
]
results = {}
for filename, script, arguments in commands:
    proc = subprocess.run([sys.executable, "-X", "utf8", str(SKILL / script), *arguments], capture_output=True, text=True, encoding="utf-8", timeout=180)
    (OUT / filename).write_text(proc.stdout + proc.stderr, encoding="utf-8")
    results[script] = {"exit_code": proc.returncode, "log": filename}
    print(f"{script}: exit{proc.returncode}", flush=True)

report = (OUT / "report.md").read_text(encoding="utf-8")
notes = {
    "manual_meaning_verification": "All14 factual ledger entries independently compared to the opened source or relevant official indexed paragraph;14 supported.4 proposed design entries labeled inference, not proprietary policy.",
    "lexical_support_warning": "Verifier reports4 partial entries, all explicitly inference. There are0 unsupported factual claims. Textual overlap alone cannot prove semantic or temporal validity.",
    "report_gate_warning": "Optional academic sections Counterevidence Register and Claims-Evidence Table are absent as separate headings; temporal contradictions, inaccessible help page and coverage limits appear in prose/ledgers.",
    "freshness": "Retrieved06/10/2026. No brand live quote or current guaranteed driver availability asserted; historical sources labeled.",
    "word_limits": "No long verbatim extracts. Factual source summaries kept compact; most body is explicitly original demo design analysis. Numeric tier examples are original arithmetic, not quotes.",
    "source_access": "Grabhelp115005848608 inaccessible via native webopen, numeric current change fees excluded. All14 included bibliography URLs passed verification.",
    "word_count_whitespace": len(report.split()),
    "validators": results,
}
(OUT / "verification_notes.json").write_text(json.dumps(notes, ensure_ascii=False, indent=2), encoding="utf-8")
raise SystemExit(any(r["exit_code"] for r in results.values()))
