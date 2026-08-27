# Template de ADR (MADR-lite)

Copie este arquivo para `docs/adr/NNNN-titulo-em-kebab-case.md`.

```markdown
# ADR-NNNN — Título curto da decisão

- **Status:** proposto | aceito | substituido por NNNN
- **Data:** YYYY-MM-DD
- **Repos:** transversal | local (`repost-manager-backend` | `repost-manager-frontend` | `repost-frontend`)

## Contexto

O problema ou força que exige uma decisão. Inclua restrições (custo, free tier, time de uma pessoa, SEO, etc.).

## Decisão

O que foi decidido, em linguagem operacional (o que fazer e o que não fazer).

## Alternativas consideradas

- **Opção A:** descrição curta — por que foi descartada
- **Opção B:** …

## Consequências

### Positivas
- …

### Negativas / trade-offs
- …

## Gatilhos de revisão

Sinais concretos que justificam reabrir esta decisão (métricas, custo, mudança de escopo).

## Backlog gerado

Issues que este ADR originou (preencher ao aceitar):

- [ ] `repo` — título da issue
```
