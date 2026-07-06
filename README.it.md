# Claude Code Free Router

[English README](README.md)

Wrapper locale per avviare Claude Code usando modelli gratuiti OpenRouter e, opzionalmente, modelli NVIDIA NIM via LiteLLM.

Stato attuale: il default non e' piu' Ring. `inclusionai/ring-2.6-1t:free` e' stato rimosso perche' non risulta disponibile nel catalogo OpenRouter usato nei test. Il default e' Laguna XS 2.1.

## Cosa installa

Il setup copia e configura:

```text
~/.claude/.env
~/.claude/litellm_config.yaml
~/.claude/openrouter-empty-mcp.json
~/.claude/commands/models.md
~/.zshrc o ~/.bashrc, con la funzione claude-or
```

La funzione `claude-or` avvia Claude Code con:

```text
--effort low
--mcp-config ~/.claude/openrouter-empty-mcp.json
--strict-mcp-config
```

Questo riduce rumore da MCP non necessari e rende il comportamento piu' prevedibile.

## Provider

OpenRouter free va diretto a OpenRouter:

```text
Claude Code -> OpenRouter Anthropic-compatible API
```

NVIDIA NIM passa da LiteLLM locale:

```text
Claude Code -> LiteLLM localhost:4000 -> NVIDIA NIM
```

LiteLLM resta nel progetto solo per NVIDIA NIM e per compatibilita' con mapping locali. I modelli OpenRouter `:free` non hanno bisogno del proxy LiteLLM nella funzione `claude-or`.

## Installazione macOS / Linux

```bash
git clone https://github.com/Giulio678/claude-code-free-router.git
cd claude-code-free-router
bash setup-linux-mac.sh
source ~/.zshrc
```

Se usi bash:

```bash
source ~/.bashrc
```

## Installazione Windows PowerShell

```powershell
git clone https://github.com/Giulio678/claude-code-free-router.git
cd claude-code-free-router
powershell -ExecutionPolicy Bypass -File setup-windows.ps1
. $PROFILE
```

## API keys

Il setup crea `~/.claude/.env` se non esiste. Inserisci:

```bash
OPENROUTER_API_KEY="sk-or-v1-..."
NVIDIA_API_KEY="nvapi-..."
```

Link utili:

```text
OpenRouter: https://openrouter.ai/keys
NVIDIA NIM: https://build.nvidia.com/
```

## Avvio rapido

Lista modelli:

```bash
claude-or models
```

Avvio default:

```bash
claude-or
```

Default attuale:

```text
poolside/laguna-xs-2.1:free
```

Test non interattivo:

```bash
claude-or -p "Rispondi solo OK" --output-format json
```

Nei test reali `modelUsage` deve mostrare:

```text
poolside/laguna-xs-2.1:free
```

## Modelli OpenRouter configurati

Comandi consigliati:

```bash
claude-or laguna-xs       # poolside/laguna-xs-2.1:free, default coding
claude-or north-code      # cohere/north-mini-code:free, fast coding
claude-or laguna-m        # poolside/laguna-m.1:free, coding large
claude-or nemotron-free   # nvidia/nemotron-3-super-120b-a12b:free, long reasoning
claude-or router          # openrouter/free, router OpenRouter gratuito
```

Legacy ancora disponibili:

```bash
claude-or qwen-coder      # qwen/qwen3-coder:free
claude-or qwen-next       # qwen/qwen3-next-80b-a3b-instruct:free
claude-or gpt-oss-20b     # openai/gpt-oss-20b:free
claude-or gpt-oss-120b    # openai/gpt-oss-120b:free
claude-or hermes-405b     # nousresearch/hermes-3-llama-3.1-405b:free
```

Puoi anche passare uno slug OpenRouter completo:

```bash
claude-or poolside/laguna-xs-2.1:free
claude-or cohere/north-mini-code:free
claude-or poolside/laguna-m.1:free
claude-or nvidia/nemotron-3-super-120b-a12b:free
claude-or openrouter/free
```

Nota: `inclusionai/ring-2.6-1t:free` non va usato.

## Cambiare modello dentro Claude Code

All'avvio OpenRouter la funzione imposta anche gli alias usati da `/model`:

```text
/model sonnet  -> poolside/laguna-xs-2.1:free
/model opus    -> poolside/laguna-m.1:free
/model haiku   -> cohere/north-mini-code:free
```

In piu' imposta:

```text
ANTHROPIC_CUSTOM_MODEL_OPTION=nvidia/nemotron-3-super-120b-a12b:free
CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1
```

Quindi il picker `/model` puo' mostrare Nemotron come voce custom e puo' interrogare il gateway OpenRouter per altri modelli. Se il picker non mostra un modello, puoi sempre scrivere lo slug completo:

```text
/model nvidia/nemotron-3-super-120b-a12b:free
/model openrouter/free
```

## Modelli NVIDIA NIM

Questi passano dal proxy LiteLLM locale:

```bash
claude-or kimi-k2.6         # moonshotai/kimi-k2.6
claude-or mistral-medium    # mistralai/mistral-medium-3.5-128b
claude-or nvidia-nano       # nvidia/nemotron-3-nano-30b-a3b
claude-or nvidia-omni       # nvidia/nemotron-3-nano-omni-30b-a3b-reasoning
claude-or nemotron-120b     # nvidia/nemotron-3-super-120b-a12b
claude-or qwen-coder-nvidia # qwen/qwen3-coder-480b-a35b-instruct
claude-or qwen-next-nvidia  # qwen/qwen3-next-80b-a3b-instruct
claude-or qwen3.5-122b      # qwen/qwen3.5-122b-a10b
```

Quando scegli un modello NVIDIA, la funzione:

1. controlla `NVIDIA_API_KEY`;
2. controlla `http://127.0.0.1:4000/health`;
3. se LiteLLM non risponde, lo avvia con `~/.claude/litellm_config.yaml`;
4. avvia Claude Code usando `ANTHROPIC_BASE_URL=http://127.0.0.1:4000`.

Log LiteLLM:

```text
/tmp/litellm-nvidia.log
```

## File importanti

```text
openrouter-empty-mcp.json
```

Contiene:

```json
{"mcpServers": {}}
```

Serve a partire senza MCP globali quando si usa `--strict-mcp-config`.

```text
litellm_config.yaml
```

Contiene mapping per OpenRouter e NVIDIA NIM. OpenRouter diretto non dipende da LiteLLM, ma il file resta utile per il proxy NVIDIA e per debug.

```text
commands/models.md
```

Installa il comando slash `/models` dentro Claude Code.

## Come funziona `claude-or`

Per OpenRouter imposta:

```text
ANTHROPIC_BASE_URL=https://openrouter.ai/api
ANTHROPIC_AUTH_TOKEN=$OPENROUTER_API_KEY
ANTHROPIC_API_KEY=
ANTHROPIC_MODEL=<modello scelto>
ANTHROPIC_DEFAULT_SONNET_MODEL=poolside/laguna-xs-2.1:free
ANTHROPIC_DEFAULT_OPUS_MODEL=poolside/laguna-m.1:free
ANTHROPIC_DEFAULT_HAIKU_MODEL=cohere/north-mini-code:free
ANTHROPIC_CUSTOM_MODEL_OPTION=nvidia/nemotron-3-super-120b-a12b:free
CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1
CLAUDE_CODE_SUBAGENT_MODEL=cohere/north-mini-code:free
DISABLE_INTERLEAVED_THINKING=1
CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
```

Poi esegue:

```bash
claude --model "$model" --effort low --mcp-config "$HOME/.claude/openrouter-empty-mcp.json" --strict-mcp-config "$@"
```

`ANTHROPIC_MODEL` e `--model` sono entrambi impostati per evitare che Claude Code riprenda un vecchio modello persistito.

## Troubleshooting

### Vedo ancora Ring nella schermata iniziale

Ring era una vecchia scelta salvata. Chiudi la sessione Claude aperta e rilancia:

```bash
source ~/.zshrc
claude-or
```

Verifica reale:

```bash
claude-or -p "Rispondi solo OK" --output-format json
```

Nel JSON controlla `modelUsage`: deve essere `poolside/laguna-xs-2.1:free`.

### La shell ha ancora la funzione vecchia

Le funzioni shell gia' caricate non cambiano finche' non ricarichi il profilo:

```bash
source ~/.zshrc
functions claude-or | grep laguna
```

### OpenRouter free fallisce o e' lento

I modelli free possono essere rate-limited o rimossi. Prova:

```bash
claude-or north-code
claude-or laguna-m
claude-or nemotron-free
claude-or router
```

### NVIDIA non parte

Controlla:

```bash
curl http://127.0.0.1:4000/health
curl http://127.0.0.1:4000/v1/models
```

Riavvia il proxy:

```bash
pkill -f "litellm --config"
claude-or kimi-k2.6
```

### API key mancante

Modifica:

```text
~/.claude/.env
```

### Aggiornare la config installata dalla repo

Dalla repo:

```bash
bash setup-linux-mac.sh
source ~/.zshrc
claude-or models
```
