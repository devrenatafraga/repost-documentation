# ADR-0005 — Modelo de dados e prontidão para multi-tenant

- **Status:** aceito
- **Data:** 2026-08-26
- **Repos:** transversal

## Contexto

No MVP só existe um blog e um usuário admin. No futuro o Repost pode abrir para outras pessoas criarem blogs. Introduzir `blog_id` depois costuma ser migração dolorosa. Também é preciso definir como armazenar conteúdo (Markdown), tema e widgets sem explodir o schema a cada ajuste.

## Decisão

1. **`blog_id` desde a primeira migration** em todas as tabelas de conteúdo. O comportamento single-tenant resolve-se com um blog padrão seedado.
2. **Markdown** (`content_md`) é a fonte da verdade do conteúdo dos posts/páginas; a renderização HTML ocorre no servidor do blog.
3. **Tema e widgets** usam `jsonb` (`themes.tokens`, `widgets.config`, `settings.data`), com schema validado no código da aplicação — não no banco.
4. Tabelas iniciais:
   - `users`, `blogs`
   - `posts`, `tags`, `post_tags`, `pages`
   - `media`, `themes`, `widgets`, `settings`
5. Status de post: `draft` | `scheduled` | `published`.
6. Slots de widget no MVP: `header`, `sidebar`, `footer`.
7. Role Postgres **somente-leitura** para a superfície `/public` (alinha com ADR-0002).

Campos canônicos (orientação; detalhes finais na migration):

- `users`: id, email, password_hash, role, created_at
- `blogs`: id, owner_id, slug, title, description, locale, timezone
- `posts`: id, blog_id, slug, title, excerpt, content_md, cover_media_id, status, published_at, reading_time, created_at, updated_at
- `pages`: shape semelhante a post, sem feed
- `media`: id, blog_id, url, alt, width, height, mime, size
- `themes`: id, blog_id, name, tokens (jsonb), is_active
- `widgets`: id, blog_id, slot, type, position, config (jsonb), enabled
- `settings`: blog_id, data (jsonb)

## Alternativas consideradas

- **Sem `blog_id` agora:** mais simples no dia 1; migração multi-tenant cara depois.
- **Schema rígido para tokens/widgets:** migration a cada novo campo de tema.
- **HTML/WYSIWYG como fonte:** pior para diff/portabilidade; adiado (editor Markdown no MVP).
- **Um banco por blog:** overkill e incompatível com free tier de um único Postgres.

## Consequências

### Positivas

- Caminho para multi-tenant sem redesign do schema.
- Tema/widgets evoluem sem migration a cada tweak.
- Conteúdo versionável e portable (Markdown).

### Negativas / trade-offs

- Queries sempre filtram por `blog_id` (disciplina de código / testes).
- Validação de jsonb exige schemas no código e testes.
- Detalhes de auth, mídia e tema ainda dependem de ADRs futuros.

## Gatilhos de revisão

- Abertura real a multi-tenant (billing, isolation, quotas).
- Necessidade de full-text search avançado ou CMS headless.
- Widgets/temas exigindo versionamento formal ou marketplace.

## Backlog gerado

- [ ] `repost-manager-backend` — Migration Flyway inicial + seed do blog padrão + role read-only
- [ ] `repost-documentation` — ADR type:issue — modelo de tema por design tokens
- [ ] `repost-documentation` — ADR type:issue — modelo de widgets
- [ ] `repost-documentation` — ADR type:issue — armazenamento de mídia
