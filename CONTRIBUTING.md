# Contribuindo para o Repost

## Idioma

| Artefato | Idioma |
| --- | --- |
| ADRs, títulos e corpos de issue, descrições de PR | Português |
| Títulos de commit, títulos de PR, nomes de branch, labels, identificadores de código | Inglês |

## Fluxo ADR → issue → PR

1. Decisão de arquitetura nasce como ADR com status `proposto`.
2. Após revisão, o ADR passa a `aceito` e lista issues na seção **Backlog gerado**.
3. As issues são criadas (ou sincronizadas) via `scripts/sync-backlog.sh` a partir de `backlog/wave-N.yaml`.
4. Desenvolvimento ocorre em branch ligada à issue; o PR referencia `Closes #N` e o ADR de origem.
5. Aprendizado que muda arquitetura gera ADR novo ou marca o anterior como `substituido por NNNN`.

PR que altera arquitetura sem ADR correspondente é recusado.

## Políticas dos repositórios (GitHub)

Nos quatro repos, **somente colaboradores** (write access) podem:

- abrir pull requests (`pullRequestCreationPolicy: collaborators_only`)
- criar issues (`issueCreationPolicy: collaborators_only`)

O backend já estava assim; os demais foram alinhados. Para reaplicar após criar um repo novo:

```bash
./scripts/apply-repo-contribution-policies.sh
```

Configuração manual: Settings → General → Features → Issues / Pull requests → **Collaborators only**.

## Onde escrever o ADR

| Tipo | Local |
| --- | --- |
| Transversal (contrato entre repos, operação, forma de trabalhar) | `repost-documentation/docs/adr/` |
| Local (router, state, organização de pacotes) | `docs/adr/` do repo afetado |

## Branches

Padrão: `<tipo>/<issue>-<slug>`

Exemplos:

- `feat/123-post-crud`
- `chore/45-ci-gradle`
- `docs/12-adr-0006-auth`

## Commits

[Conventional Commits](https://www.conventionalcommits.org/) em inglês, com escopo quando fizer sentido:

```
feat(posts): add draft autosave
fix(auth): refresh cookie SameSite
docs(adr): accept ADR-0003
chore(ci): add openapi drift check
```

## Pull requests

- Um PR por issue.
- Corpo com `Closes #<n>` e link do ADR (`adr:NNNN` / caminho do arquivo).
- Squash merge.
- `main` protegida: exige CI verde e revisão (quando houver mais de um contribuidor).

## Labels

Padronizadas nos quatro repos:

- Área: `area:backend`, `area:manager`, `area:blog`, `area:docs`
- Tipo: `type:feat`, `type:chore`, `type:docs`, `type:adr`, `type:test`, `type:bug`
- ADR: `adr:0001` … `adr:NNNN`
- Prioridade: `P1`, `P2`, `P3`

## Milestones

- `M1 Fundacao`
- `M2 Nucleo de conteudo`
- `M3 Blog publico`
- `M4 Tema e widgets`
- `M5 Midia e agendamento`
