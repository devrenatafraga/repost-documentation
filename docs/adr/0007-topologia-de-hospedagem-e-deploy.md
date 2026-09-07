# ADR-0007 — Topologia de hospedagem e deploy

- **Status:** aceito
- **Data:** 2026-09-07
- **Repos:** transversal

## Contexto

O código do MVP (API, manager, blog, Postgres) já existe localmente. Falta decidir **onde** cada peça roda no free tier, como se conectam (URLs, CORS, cookies) e o que fica fora do escopo até mídia/tema. A decisão precisa caber em operação solo, alinhar com ADR-0002 (um único JVM) e ADR-0006 (JWT + refresh cookie cross-origin).

Restrições observadas em 2026:

- Free tier JVM tipicamente **512 MB / ~0,1 vCPU**, com **scale-to-zero** e cold start.
- Postgres gratuito viável com **scale-to-zero** e wake rápido (Neon).
- Frontends Next/Vite encaixam bem em PaaS de edge/static (Vercel Hobby).
- Object storage barato para mídia futura (Cloudflare R2 — sem egress fee típico).

## Decisão

1. **Postgres:** [Neon](https://neon.tech) (plano Free). Um projeto `repost`; connection string JDBC/URI em secrets do backend. Scale-to-zero aceito; cold start do DB é aceitável no MVP.
2. **Backend Ktor:** **Koyeb** como provedor principal (1 free instance ~512 MB). Alternativa operacional: **Northflank** Developer Sandbox se Koyeb deixar de servir. Um único serviço; health em `GET /health`.
3. **Memória JVM:** flags alinhadas a 512 MB, por exemplo `-Xmx256m -XX:MaxMetaspaceSize=96m` (ajustar no deploy se necessário). Preferir imagem JVM slim / JRE 25; GraalVM nativo **não** é requisito do MVP.
4. **Frontends:** **Vercel** (Hobby):
   - `repost-manager-frontend` — SPA Vite (build estático)
   - `repost-frontend` — Next.js App Router (ISR quando o blog consumir a API pública)
5. **Mídia (futuro):** **Cloudflare R2** — só provisionar quando o ADR de armazenamento de mídia for aceito; não bloqueia o primeiro deploy de texto.
6. **Domínios (alvo):**
   - API: `api.<dominio>` → Koyeb
   - Manager: `admin.<dominio>` → Vercel
   - Blog: apex/`www` → Vercel  
   Até ter domínio próprio, usar URLs `*.koyeb.app` / `*.vercel.app` e configurar `CORS_ORIGINS`, `API_BASE_URL`, `VITE_API_BASE_URL`, `COOKIE_SECURE=true` em HTTPS.
7. **Segredos:** vivem só nos painéis do PaaS (Neon, Koyeb, Vercel). Lista mínima do backend: `DATABASE_URL` (ou JDBC + user/password), `JWT_SECRET`, `ADMIN_EMAIL`, `ADMIN_PASSWORD_HASH`, `CORS_ORIGINS`, `API_BASE_URL`, `COOKIE_SECURE`. Detalhe de rotação/gestão → ADR de gestão de segredos (issue #12).
8. **CI:** continua em GitHub Actions (build/test). Deploy inicial pode ser **manual** (push da imagem / connect Git no PaaS); CD automático é melhoria posterior, não bloqueia o ADR.

## Alternativas consideradas

- **Render free:** Postgres free expira; web free dorme com cold start JVM doloroso — descartado para o DB; backend só se Koyeb/Northflank falharem.
- **Fly.io:** free tier efetivo reduziu/ desapareceu para o perfil do projeto.
- **Supabase Postgres:** free pausa por inatividade com wake pior que Neon para este uso.
- **Railway / always-on pago:** fora do objetivo custo-zero do MVP.
- **Tudo na Vercel (serverless Kotlin):** não cabe no modelo Ktor atual; exigiria reescrever a API.

## Consequências

### Positivas

- Caminho concreto para o primeiro deploy sem cartão (ou com cartão só se o PaaS exigir verificação).
- Um JVM + Neon + dois fronts espelha ADR-0002.
- CORS/cookies de auth têm hosts explícitos.

### Negativas / trade-offs

- Cold start do Koyeb (após ~1 h idle) e do Neon (após ~5 min) — login/admin e revalidate ocasional sentem latência.
- 512 MB exige disciplina de heap e dependências.
- Três consoles (Neon, Koyeb, Vercel) + secrets manuais até o ADR de segredos/CD.

## Gatilhos de revisão

- Free instance Koyeb/Northflank removida ou insuficiente.
- Tráfego/ISR exigindo backend always-on ou read path na edge.
- Domínio custom + necessidade de WAF/CDN aparte.
- Custo Neon (CU-hours / storage) estourando free.

## Backlog gerado

- [ ] `repost-manager-backend` — Dockerfile + deploy Koyeb (health, JVM flags, env)
- [ ] `repost-manager-backend` — Projeto Neon + migrations em produção + checklist de secrets
- [ ] `repost-manager-frontend` — Projeto Vercel + `VITE_API_BASE_URL` / CORS alinhado
- [ ] `repost-frontend` — Projeto Vercel + consumo de `GET /api/v1/public/posts` (lista/detalhe)
- [ ] `repost-documentation` — ADR type:issue — gestão de segredos (já no backlog como #12)
