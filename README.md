<img src="assets/appicon.png" width="112" align="right" alt="ícone">

# dd-claudeusage

Um app de **barra de menu** pra macOS que mostra o quanto você já usou do **Claude Code** — a janela de **5h** (atual) e a de **7d** (semana) — sempre à vista, sem precisar rodar `/usage`.

Inspirado no [Pookify](https://github.com/eyadhammouda/pookify), mas na menu bar e focado em **uso/cota** em vez de status de sessão.

```
✳ 49·13%                       ← barra de menu (5h · 7d)
┌──────────────────────────────┐
│ Plano (oficial · /usage)       │
│ ──────────────────────────     │
│ 5h (atual):  ████░░░░  49%     │
│      reseta em 2h31m           │
│ 7d (semana): █░░░░░░░  13%     │
│ ──────────────────────────     │
│ Atualizar agora                │
│ Sair                           │
└──────────────────────────────┘
```

## Instalação

```bash
git clone https://github.com/dougzeu/dd-claudeusage.git
cd dd-claudeusage
./install.sh
```

O `install.sh` faz tudo: venv + dependências, o app da barra de menu (`~/Applications/dd-claudeusage.app`, que o Spotlight acha pelo nome) e o LaunchAgent pra abrir no login.

Depois, pro **% oficial do plano** (o mesmo do `/usage`), gere seu token do Claude Code:

```bash
claude setup-token          # gera um token OAuth (sk-ant-oat01-...)
pbpaste > .token            # cola a saída no arquivo .token
```

Sem token, o app roda mesmo assim no **modo ccusage** (custo estimado em $).

## Abrir / fechar / reabrir

- **Abre sozinho no login** (o `install.sh` já configurou o LaunchAgent).
- **Reabrir sem terminal:** Spotlight (Cmd+Espaço) → digite `dd-claudeusage` → Enter.
- **Fechar:** clique no `✳` na barra → **Sair**.
- Se **crashar**, ele relança sozinho; se você clicar **Sair**, fica fechado (respeita você).

| Também dá pra… | Comando |
|---|---|
| Reabrir pelo terminal | `launchctl start com.dd-claudeusage` |
| Desligar de vez (não abrir no login) | `launchctl unload ~/Library/LaunchAgents/com.dd-claudeusage.plist` |
| Religar | `launchctl load -w ~/Library/LaunchAgents/com.dd-claudeusage.plist` |

## Como funciona

Duas fontes, nesta ordem:

1. **Plano (oficial).** Faz um probe minúsculo na Messages API da Anthropic e lê os headers `anthropic-ratelimit-unified-5h/7d-utilization` — **o mesmo número que o `/usage` mostra**. Precisa do token.
2. **ccusage (fallback).** Sem token, cai pro [`ccusage`](https://github.com/ryoppippi/ccusage), que lê os logs locais em `~/.claude/projects/` e mostra **custo estimado em $** da janela de 5h e da semana.

> O probe usa `claude-haiku-4-5`, `max_tokens: 1` — consome uma fração ínfima da sua cota, a cada 2 min (configurável). Nada sai da sua máquina além dessa chamada à própria API da Anthropic.

**Onde ele procura o token:** env `CLAUDE_CODE_TOKEN` → arquivo `.token` → (fallback pessoal do autor, ignore). Cada pessoa usa o **próprio** token — fica só na sua máquina e **nunca** vai pro git (`.token` está no `.gitignore`).

## Requisitos

- macOS (barra de menu via `rumps`/AppKit) · Python 3
- Token do Claude Code — pro % oficial (recomendado)
- `node`/`bun` no PATH — só pro modo ccusage (fallback)

## Configuração

No topo do `dd_claudeusage.py`:

| Constante | O que é |
|---|---|
| `REFRESH_SECONDS` | intervalo de atualização (padrão 120s) |
| `WEEKLY_LIMIT_USD` | teto em $ usado **só** no modo ccusage, pra virar barra de % |
| `ICON` | o glifo `✳` que aparece como texto na barra de menu |

Verificar as fontes sem abrir a GUI:

```bash
.venv/bin/python dd_claudeusage.py --check
```

O ícone do app é gerado por `make_icon.py` (requer Pillow) → `assets/appicon.png`; o `.icns` é montado com `sips` + `iconutil`.

## Créditos

- Probe de rate limit: reaproveitado de um projeto meu de hardware (medidor de cota num display ESP8266).
- Ideia da "ilha" de status: [Pookify](https://github.com/eyadhammouda/pookify).
- Fallback de custo: [ccusage](https://github.com/ryoppippi/ccusage).

## Aviso

A API de rate limit **não é documentada** — nomes de header e versão do beta podem mudar sem aviso. Se parar, o app cai pro ccusage sozinho; é só atualizar os nomes dos headers no código.

MIT. Sem garantias, sem coleta de dados.
