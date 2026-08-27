# repost-documentation

Documentação de arquitetura do **Repost**, plataforma de blog própria.

Este repositório é a fonte da verdade para decisões transversais: ADRs, backlog versionado, convenções de contribuição e templates compartilhados. Não contém código de aplicação.

## Repositórios do projeto

| Repositório | Papel |
| --- | --- |
| [repost-documentation](https://github.com/devrenatafraga/repost-documentation) | ADRs transversais, backlog, convenções |
| [repost-manager-backend](https://github.com/devrenatafraga/repost-manager-backend) | API Ktor (admin + public) |
| [repost-manager-frontend](https://github.com/devrenatafraga/repost-manager-frontend) | Painel admin (Vite SPA) |
| [repost-frontend](https://github.com/devrenatafraga/repost-frontend) | Blog público (Next.js) |

## Como trabalhamos

```
ADR aceito → backlog/wave-N.yaml → issues (gh) → PR → aprendizado → ADR novo ou supersede
```

1. Decisões de arquitetura são registradas em [docs/adr/](docs/adr/).
2. Cada ADR aceito gera entradas em [backlog/](backlog/).
3. O script [scripts/sync-backlog.sh](scripts/sync-backlog.sh) cria as issues nos repos corretos.
4. Cada issue vira um PR rastreável (`Closes #N` + label `adr:NNNN`).

Leia [CONTRIBUTING.md](CONTRIBUTING.md) antes de abrir PRs.

## Índice de ADRs

Ver [docs/adr/index.md](docs/adr/index.md).

## Licença

MIT — ver [LICENSE](LICENSE).


## Project board

Backlog unificado: [Repost Roadmap](https://github.com/users/devrenatafraga/projects/1)

## Onda 1

Os ADRs 0001–0005 estão aceitos. As issues geradas estão em `backlog/wave-1.yaml` e foram sincronizadas nos quatro repositórios via `scripts/sync-backlog.sh`.
