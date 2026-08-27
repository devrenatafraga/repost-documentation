# ADR-0003 — Contrato de API e versionamento

- **Status:** aceito
- **Data:** 2026-08-26
- **Repos:** transversal

## Contexto

Com três repositórios de código, o contrato entre backend e frontends é o principal risco de dessincronia. Sem fonte única da verdade, tipos TypeScript e DTOs Kotlin divergem e bugs aparecem só em runtime. Não queremos publicar um pacote npm compartilhado só para tipos no MVP.

## Decisão

1. O Ktor publica OpenAPI em `/openapi.json` como **fonte da verdade** do contrato.
2. Prefixo versionado: `/api/v1/...`. Breaking changes exigem `/api/v2` ou ADR de migração.
3. Cada frontend gera tipos com `openapi-typescript` via `npm run gen:api`.
4. Os tipos gerados **são commitados**; a CI falha se estiverem dessincronizados do spec (drift check).
5. Sem pacote npm compartilhado no MVP; sem interfaces duplicadas à mão.
6. Superfícies documentadas no mesmo spec, agrupadas por tag (`admin`, `public`).

## Alternativas consideradas

- **Pacote npm `@repost/api-types`:** exige registry/publish e cicla releases só por tipos.
- **Tipos escritos à mão nos frontends:** barato no dia 1, caro depois; fonte da verdade some.
- **tRPC / GraphQL:** amarra stack e não combina bem com backend Kotlin separado.
- **Contrato só em Markdown:** não gera tipos nem falha na CI.

## Consequências

### Positivas

- Backend e frontends podem avançar em paralelo após o spec inicial.
- Breaking change fica visível no PR do frontend (drift) ou no PR do backend (review do OpenAPI).
- Clientes futuros (mobile, scripts) reutilizam o mesmo contrato.

### Negativas / trade-offs

- Exige disciplina de regenerar tipos após mudanças de API.
- OpenAPI gerado pelo Ktor precisa estar no pipeline de CI do backend.

## Gatilhos de revisão

- Necessidade de múltiplos consumidores com versionamento semântico de pacote.
- Mudança para BFF no Next.js que reduza o consumo direto do OpenAPI.
- Ferramenta de contract testing (Pact etc.) tornar-se necessária.

## Backlog gerado

- [ ] `repost-manager-backend` — Publicar `/openapi.json` e validar na CI
- [ ] `repost-manager-frontend` — Script `gen:api` + tipos commitados + job de drift
- [ ] `repost-frontend` — Script `gen:api` + tipos commitados + job de drift
