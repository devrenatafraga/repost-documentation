# ADR-0002 — Topologia de repositórios e de serviços

- **Status:** aceito
- **Data:** 2026-08-26
- **Repos:** transversal

## Contexto

O Repost precisa de painel de gestão, API e blog público. A tentação é criar muitos serviços desde o MVP. O free tier disponível comporta essencialmente **um** serviço JVM gratuito; o blog público precisa de SEO (SSR/ISR); e o time é uma pessoa. Também é preciso decidir se admin e leitura pública exigem backends separados.

## Decisão

1. **Quatro repositórios:**
   - `repost-documentation` — ADRs transversais, backlog, convenções
   - `repost-manager-backend` — API única (Ktor)
   - `repost-manager-frontend` — painel admin (Vite SPA)
   - `repost-frontend` — blog público (Next.js)
2. **Um único serviço de backend**, com duas superfícies de API:
   - `/api/v1/admin/**` — autenticado, escrita, drafts
   - `/api/v1/public/**` — anônimo, só leitura de conteúdo `published`, cacheável
3. **Não** haverá um segundo backend só para o blog no MVP. O Next.js com ISR absorve o read path do leitor; o backend é acordado sobretudo no revalidate e no admin.
4. Para manter a **extração futura barata**:
   - módulos Gradle separados para `admin` e `public`
   - o módulo `public` **não** depende em compilação do `admin`
   - role Postgres somente-leitura para a superfície pública
5. O workspace local é um contêiner dos quatro clones; não há monorepo.

## Alternativas consideradas

- **Monorepo:** simplifica contratos compartilhados, mas foge da preferência explícita por três/quatro repos e complica permissões/CI por produto.
- **Dois backends (admin + public):** dobra deploy JVM, estoura o free tier e duplica operação; a diferença real é de política (auth/cache), não de processo.
- **Manager front+back no mesmo repo:** acopla ciclos de release e stacks (Kotlin vs React) sem ganho claro no MVP.

## Consequências

### Positivas

- Custo operacional alinhado ao free tier.
- Fronteiras claras entre documentação, API, admin e blog.
- Caminho de extração do read path preservado sem pagar o preço agora.

### Negativas / trade-offs

- Contrato entre repos precisa ser explícito (ver ADR-0003).
- Quatro remotes e quatro CIs para manter.
- Cold start único do backend afeta admin e, raramente, revalidação.

## Gatilhos de revisão

- Tráfego público competindo por CPU/memória com o admin.
- Necessidade de read path em edge (latência global).
- Abertura a multi-tenant em que a leitura pública vira hot path.
- Free tier do provedor de backend deixar de comportar a JVM.

## Backlog gerado

- [ ] `repost-manager-backend` — Scaffold Gradle multi-módulo (`admin` / `public`) + esqueleto Ktor + `/health`
- [ ] `repost-manager-frontend` — Scaffold Vite + React + TypeScript
- [ ] `repost-frontend` — Scaffold Next.js App Router
- [ ] `repost-documentation` — ADR type:issue — autenticação de usuário único (próxima onda)
- [x] `repost-documentation` — ADR type:issue — topologia de hospedagem e deploy (próxima onda)
