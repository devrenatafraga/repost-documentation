# ADR-0006 — Autenticação e autorização de usuário único

- **Status:** aceito
- **Data:** 2026-09-06
- **Repos:** transversal

## Contexto

No MVP só a autora usa o painel admin. É preciso proteger `/api/v1/admin/**` sem construir um produto de contas. O blog público permanece anônimo. Há um único usuário seedado; signup aberto não faz parte do escopo. A decisão precisa caber no free tier, ser simples de operar sozinha e deixar caminho para multi-usuário depois (a tabela `users` já existe — ADR-0005).

## Decisão

1. **Sem signup público.** Não existe endpoint de registro. O admin é seedado na subida (ou migration) a partir de variáveis de ambiente:
   - `ADMIN_EMAIL`
   - `ADMIN_PASSWORD_HASH` (BCrypt) — preferível a senha em texto claro em produção
2. **Login:** `POST /api/v1/admin/auth/login` com email + senha.
   - Valida contra `users.password_hash` (BCrypt).
   - Em sucesso: devolve **access token JWT** (curto, ~15 min) no corpo JSON e **refresh token** em cookie `httpOnly`, `Secure` (em HTTPS), `SameSite=Strict`, path restrito ao refresh.
3. **Refresh:** `POST /api/v1/admin/auth/refresh` — lê o cookie, rotaciona o refresh se necessário, emite novo access token.
4. **Logout:** `POST /api/v1/admin/auth/logout` — invalida o refresh (revogação server-side ou cookie com max-age 0 + denylist/versão).
5. **Proteção:** todas as rotas `/api/v1/admin/**` (exceto `auth/login` e, se aplicável, health) exigem Bearer JWT válido. Role mínima: `admin`.
6. **Rate limit** no login (e no refresh): por IP + email, com resposta 429 — mitiga brute force no free tier.
7. **Manager (Vite SPA):** guarda o access token em memória (não em `localStorage`); o refresh usa o cookie automaticamente (`credentials: 'include'`). CORS no backend permite a origem do manager com credentials.
8. **Superfície pública** continua sem autenticação de usuário; o role Postgres read-only (ADR-0002/0005) é separado desta decisão.
9. Segredos JWT (`JWT_SECRET` / chaves) e hashes de admin vivem em env/secrets do PaaS — detalhe operacional no ADR de gestão de segredos (#12); aqui só se exige que **não** sejam commitados.

## Alternativas consideradas

- **Session cookie only (sem JWT):** mais simples para SPA same-site; com manager e API em hosts diferentes (admin.dominio vs api.dominio) o JWT no Authorization + refresh em cookie separa bem os tempos de vida.
- **Auth de terceiros (Auth0, Clerk, Supabase Auth):** custo/acoplamento desnecessário para um usuário.
- **API key estática no header:** frágil, sem expiração, ruim para o browser.
- **Signup + convite:** fora do MVP; reabrir quando multi-tenant/multi-usuário for real.

## Consequências

### Positivas

- Admin protegido com modelo padrão (access curto + refresh).
- Sem superfície de abuso de registro.
- Compatível com CORS cross-origin entre manager e API.
- Tabela `users` / role já preparadas para crescimento.

### Negativas / trade-offs

- Operação de bootstrap manual (gerar hash BCrypt, setar env).
- Refresh em cookie exige HTTPS em produção e CORS cuidadoso.
- Revogação imediata de access JWT só no expiry (mitigar com TTL curto).

## Gatilhos de revisão

- Mais de um admin ou papéis (editor, viewer).
- Abertura a multi-tenant com login por blog.
- Necessidade de OAuth/social login.
- Incidentes de força bruta ou vazamento de refresh — endurecer (2FA, device binding).

## Backlog gerado

- [ ] `repost-manager-backend` — Auth admin: login, refresh, logout, JWT, BCrypt, seed via env
- [ ] `repost-manager-backend` — Rate limit em login/refresh + proteção Bearer em `/api/v1/admin/**`
- [ ] `repost-manager-frontend` — Tela de login e sessão (access em memória, refresh via cookie)
- [ ] `repost-documentation` — Atualizar OpenAPI contract nos frontends após endpoints de auth (`gen:api`)
