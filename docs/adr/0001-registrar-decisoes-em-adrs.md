# ADR-0001 — Registrar decisões de arquitetura em ADRs

- **Status:** aceito
- **Data:** 2026-08-26
- **Repos:** transversal

## Contexto

O Repost nasce com quatro repositórios e decisões que atravessam backend, manager e blog público. Sem um registro explícito, o “porquê” se perde e PRs passam a discutir arquitetura de novo a cada mudança. O projeto é mantido por uma pessoa, então o processo precisa ser leve o bastante para não virar burocracia, e rígido o bastante para manter rastreabilidade.

## Decisão

1. Toda decisão de arquitetura relevante é registrada como ADR no formato MADR-lite (ver `0000-template.md`).
2. Numeração com quatro dígitos (`0001`, `0002`, …). Status: `proposto` → `aceito` → `substituido por NNNN`.
3. ADRs **transversais** ficam em `repost-documentation/docs/adr/`. ADRs **locais** ficam em `docs/adr/` do repo afetado.
4. Critério de fronteira: se a decisão muda o contrato entre repos, o custo de operação ou a forma de trabalhar, é transversal; caso contrário, é local.
5. Fluxo oficial: **ADR aceito → issue(s) no backlog → PR**. Toda issue carrega label `adr:NNNN` e link do ADR; todo ADR aceito lista as issues na seção **Backlog gerado**.
6. ADR aceito não é editado no conteúdo decisório; mudanças geram ADR novo que o substitui.
7. PR que altera arquitetura sem ADR correspondente é recusado.

## Alternativas consideradas

- **Só issues/discussions no GitHub:** perde versionamento e o histórico fica solto entre repos.
- **Wiki:** frágil, sem review por PR e sem ligação clara ao código.
- **ADR só depois do código:** documenta o passado; não direciona o backlog.

## Consequências

### Positivas

- Decisões revisáveis em PR, versionadas e linkáveis.
- Backlog nasce do “porquê”, não de uma lista solta de tarefas.
- Facilita reabrir decisões com gatilhos explícitos.

### Negativas / trade-offs

- Overhead inicial de escrever ADRs antes de codar.
- Exige disciplina para não editar ADRs aceitos “no lugar”.

## Gatilhos de revisão

- O fluxo ADR → issue → PR estiver gerando mais atrito do que clareza.
- Surgir necessidade de ferramenta dedicada (ex.: ADR tooling) ou de ADRs em outro formato.

## Backlog gerado

- [ ] `repost-documentation` — Scaffold do repositório de documentação (README, LICENSE, CONTRIBUTING, template ADR, índice)
- [ ] `repost-documentation` — Templates de issue e PR canônicos
- [ ] `repost-documentation` — Script de sync do backlog (`scripts/sync-backlog.sh`)
