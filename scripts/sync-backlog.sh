#!/usr/bin/env bash
# Sync backlog YAML entries into GitHub issues (idempotent by title search).
# Requires: gh, python3, PyYAML (pip install pyyaml) OR uses a minimal parser for our subset.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OWNER="${GITHUB_OWNER:-devrenatafraga}"
WAVE_FILE="${1:-$ROOT/backlog/wave-1.yaml}"

if [[ ! -f "$WAVE_FILE" ]]; then
  echo "Arquivo não encontrado: $WAVE_FILE" >&2
  exit 1
fi

if ! command -v gh >/dev/null; then
  echo "gh CLI não encontrado" >&2
  exit 1
fi

python3 - "$WAVE_FILE" "$OWNER" <<'PY'
import json, subprocess, sys, re

wave_path, owner = sys.argv[1], sys.argv[2]

try:
    import yaml
except ImportError:
    print("Instale PyYAML: pip3 install pyyaml", file=sys.stderr)
    sys.exit(1)

with open(wave_path, encoding="utf-8") as f:
    data = yaml.safe_load(f)

issues = data.get("issues") or []
created = skipped = 0

for item in issues:
    repo = item["repo"]
    title = item["title"]
    body = item.get("body") or ""
    labels = item.get("labels") or []
    milestone = item.get("milestone")
    adr = item.get("adr")

    full = f"{owner}/{repo}"

    # Idempotency: search open+closed issues with exact title
    search = subprocess.run(
        ["gh", "issue", "list", "-R", full, "--state", "all", "--search", f'in:title "{title}"', "--json", "number,title"],
        capture_output=True, text=True, check=True,
    )
    existing = json.loads(search.stdout or "[]")
    if any(i.get("title") == title for i in existing):
        print(f"SKIP  {full}: {title}")
        skipped += 1
        continue

    if adr and f"ADR-{adr}" not in body and f"adr:{adr}" not in body.lower():
        body = f"**ADR:** ADR-{adr}\n\n{body}"

    cmd = ["gh", "issue", "create", "-R", full, "--title", title, "--body", body]
    for label in labels:
        cmd.extend(["--label", label])
    if milestone:
        cmd.extend(["--milestone", milestone])

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"FAIL  {full}: {title}\n{result.stderr}", file=sys.stderr)
        sys.exit(1)
    print(f"CREATE {result.stdout.strip()} — {title}")
    created += 1

print(f"\nDone. created={created} skipped={skipped} total={len(issues)}")
PY
