#!/usr/bin/env bash
set -euo pipefail
OWNER="${GITHUB_OWNER:-devrenatafraga}"
REPO="$1"
FULL="$OWNER/$REPO"

labels=(
  "area:backend|#0E8A16|Backend API"
  "area:manager|#1D76DB|Manager frontend"
  "area:blog|#5319E7|Public blog"
  "area:docs|#BFDADC|Documentation"
  "type:feat|#A2EEEF|Feature"
  "type:chore|#FEF2C0|Chore"
  "type:docs|#0075CA|Docs"
  "type:adr|#D4C5F9|Architecture decision"
  "type:test|#BFD4F2|Tests"
  "type:bug|#D73A4A|Bug"
  "adr:0001|#EDEDED|From ADR-0001"
  "adr:0002|#EDEDED|From ADR-0002"
  "adr:0003|#EDEDED|From ADR-0003"
  "adr:0004|#EDEDED|From ADR-0004"
  "adr:0005|#EDEDED|From ADR-0005"
  "P1|#B60205|Priority 1"
  "P2|#FBCA04|Priority 2"
  "P3|#0E8A16|Priority 3"
)

for entry in "${labels[@]}"; do
  IFS='|' read -r name color desc <<<"$entry"
  gh label create "$name" -R "$FULL" --color "${color#\#}" --description "$desc" 2>/dev/null \
    || gh label edit "$name" -R "$FULL" --color "${color#\#}" --description "$desc" 2>/dev/null \
    || true
done

milestones=(
  "M1 Fundacao|Fundação: ADRs, scaffolds, CI, contrato, migration"
  "M2 Nucleo de conteudo|Auth, CRUD de posts, núcleo do manager"
  "M3 Blog publico|Blog Next.js, SEO, ISR, revalidate"
  "M4 Tema e widgets|Design tokens e widgets ponta a ponta"
  "M5 Midia e agendamento|R2, agendamento, operação"
)

for entry in "${milestones[@]}"; do
  IFS='|' read -r title desc <<<"$entry"
  # create if missing
  if ! gh api "repos/$FULL/milestones" --jq '.[].title' | grep -Fxq "$title"; then
    gh api "repos/$FULL/milestones" -f title="$title" -f description="$desc" >/dev/null
  fi
done

echo "Meta OK: $FULL"
