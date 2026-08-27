# ADR-0004 — Seleção de stack

- **Status:** aceito
- **Data:** 2026-08-26
- **Repos:** transversal

## Contexto

Preferências explícitas: backend em Kotlin, frontends em TypeScript/React, hospedagem em PaaS com free tier, blog com SEO forte, manager como SPA de uso pessoal. A stack precisa caber em ~512 MB de RAM no backend e ser produtiva para uma pessoa.

## Decisão

| Camada | Escolha |
| --- | --- |
| Backend | Kotlin + **Ktor** + **Exposed** + **Flyway** + Postgres |
| Blog público | **Next.js** (App Router, Server Components, ISR) |
| Manager | **Vite** + React + TypeScript (SPA) |
| Estilo (frontends) | Tailwind; shadcn/ui no manager |
| Serialização API | kotlinx.serialization + OpenAPI (ADR-0003) |
| Banco | PostgreSQL (provedor concreto em ADR futuro de hospedagem) |

Detalhes de bibliotecas de UI do manager (TanStack Router/Query, CodeMirror, etc.) podem ser refinados em ADRs locais sem reabrir esta decisão de plataforma.

## Alternativas consideradas

- **Spring Boot:** ecossistema maior, porém mais pesado em memória/cold start no free tier.
- **Next.js nos dois frontends:** consistência de tooling, mas o manager não precisa de SSR e ganha complexidade à toa.
- **Vite SPA nos dois:** SEO do blog fica pior sem SSR/ISR.
- **FastAPI / NestJS:** foge da preferência por Kotlin no backend.

## Consequências

### Positivas

- SEO e cache do blog alinhados com Next.js ISR.
- Manager leve e desacoplado do ciclo de render do blog.
- Ktor mais enxuto que Spring para JVM em free tier.

### Negativas / trade-offs

- Duas toolchains front (Vite e Next) para manter.
- JVM ainda exige cuidado com flags e Dockerfile (detalhe no ADR de hospedagem).

## Gatilhos de revisão

- Cold start ou memória do Ktor inviabilizar o free tier → avaliar GraalVM native image ou outro runtime.
- Manager precisar de preview SSR autenticado complexo → reconsiderar Next no manager.
- Mudança de preferência de linguagem no backend.

## Backlog gerado

- [ ] `repost-manager-backend` — CI Gradle (build + test)
- [ ] `repost-manager-frontend` — CI Node (lint + typecheck + build)
- [ ] `repost-frontend` — CI Node (lint + typecheck + build)
- [ ] `repost-documentation` — ADR type:issue — estratégia de testes (próxima onda)
