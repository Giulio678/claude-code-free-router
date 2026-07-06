# Claude Code Free Router

[Italian README](README.md)

Local wrapper for starting Claude Code with free OpenRouter models and, optionally, NVIDIA NIM models through LiteLLM.

Current status: Ring is no longer the default. `inclusionai/ring-2.6-1t:free` was removed because it is not available in the OpenRouter catalog used during testing. The default is Laguna XS 2.1.

## What It Installs

The setup copies and configures:

```text
~/.claude/.env
~/.claude/litellm_config.yaml
~/.claude/openrouter-empty-mcp.json
~/.claude/commands/models.md
~/.zshrc or ~/.bashrc, with the claude-or function
```

The `claude-or` function starts Claude Code with:

```text
--effort low
--mcp-config ~/.claude/openrouter-empty-mcp.json
--strict-mcp-config
```

This reduces unrelated MCP noise and makes startup behavior more predictable.

## Providers

OpenRouter free models go directly to OpenRouter:

```text
Claude Code -> OpenRouter Anthropic-compatible API
```

NVIDIA NIM goes through local LiteLLM:

```text
Claude Code -> LiteLLM localhost:4000 -> NVIDIA NIM
```

LiteLLM stays in the project only for NVIDIA NIM and local mapping compatibility. OpenRouter `:free` models do not need the LiteLLM proxy in the `claude-or` function.

## macOS / Linux Install

```bash
git clone https://github.com/Giulio678/claude-code-free-router.git
cd claude-code-free-router
bash setup-linux-mac.sh
source ~/.zshrc
```

If you use bash:

```bash
source ~/.bashrc
```

## Windows PowerShell Install

```powershell
git clone https://github.com/Giulio678/claude-code-free-router.git
cd claude-code-free-router
powershell -ExecutionPolicy Bypass -File setup-windows.ps1
. $PROFILE
```

## API Keys

The setup creates `~/.claude/.env` if it does not already exist. Add:

```bash
OPENROUTER_API_KEY="sk-or-v1-..."
NVIDIA_API_KEY="nvapi-..."
```

Useful links:

```text
OpenRouter: https://openrouter.ai/keys
NVIDIA NIM: https://build.nvidia.com/
```

## Quick Start

List models:

```bash
claude-or models
```

Start the default session:

```bash
claude-or
```

Current default:

```text
poolside/laguna-xs-2.1:free
```

Non-interactive test:

```bash
claude-or -p "Reply only OK" --output-format json
```

In real test output, `modelUsage` should show:

```text
poolside/laguna-xs-2.1:free
```

## Configured OpenRouter Models

Recommended commands:

```bash
claude-or laguna-xs       # poolside/laguna-xs-2.1:free, default coding
claude-or north-code      # cohere/north-mini-code:free, fast coding
claude-or laguna-m        # poolside/laguna-m.1:free, large coding
claude-or nemotron-free   # nvidia/nemotron-3-super-120b-a12b:free, long-context reasoning
claude-or router          # openrouter/free, OpenRouter free router
```

Legacy options still available:

```bash
claude-or qwen-coder      # qwen/qwen3-coder:free
claude-or qwen-next       # qwen/qwen3-next-80b-a3b-instruct:free
claude-or gpt-oss-20b     # openai/gpt-oss-20b:free
claude-or gpt-oss-120b    # openai/gpt-oss-120b:free
claude-or hermes-405b     # nousresearch/hermes-3-llama-3.1-405b:free
```

You can also pass a full OpenRouter slug:

```bash
claude-or poolside/laguna-xs-2.1:free
claude-or cohere/north-mini-code:free
claude-or poolside/laguna-m.1:free
claude-or nvidia/nemotron-3-super-120b-a12b:free
claude-or openrouter/free
```

Do not use `inclusionai/ring-2.6-1t:free`.

## Switching Models Inside Claude Code

When starting with OpenRouter, the function also configures the aliases used by `/model`:

```text
/model sonnet  -> poolside/laguna-xs-2.1:free
/model opus    -> poolside/laguna-m.1:free
/model haiku   -> cohere/north-mini-code:free
```

It also sets:

```text
ANTHROPIC_CUSTOM_MODEL_OPTION=nvidia/nemotron-3-super-120b-a12b:free
CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1
```

So the `/model` picker can show Nemotron as a custom option and can query the OpenRouter gateway for other models. If the picker does not show a model, you can still type the full slug:

```text
/model nvidia/nemotron-3-super-120b-a12b:free
/model openrouter/free
```

## NVIDIA NIM Models

These go through the local LiteLLM proxy:

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

When you choose an NVIDIA model, the function:

1. checks `NVIDIA_API_KEY`;
2. checks `http://127.0.0.1:4000/health`;
3. starts LiteLLM with `~/.claude/litellm_config.yaml` if it is not responding;
4. starts Claude Code using `ANTHROPIC_BASE_URL=http://127.0.0.1:4000`.

LiteLLM log:

```text
/tmp/litellm-nvidia.log
```

## Important Files

```text
openrouter-empty-mcp.json
```

Contains:

```json
{"mcpServers": {}}
```

This starts Claude Code without global MCP servers when using `--strict-mcp-config`.

```text
litellm_config.yaml
```

Contains mappings for OpenRouter and NVIDIA NIM. Direct OpenRouter usage does not depend on LiteLLM, but the file remains useful for the NVIDIA proxy and debugging.

```text
commands/models.md
```

Installs the `/models` slash command inside Claude Code.

## How `claude-or` Works

For OpenRouter, it sets:

```text
ANTHROPIC_BASE_URL=https://openrouter.ai/api
ANTHROPIC_AUTH_TOKEN=$OPENROUTER_API_KEY
ANTHROPIC_API_KEY=
ANTHROPIC_MODEL=<selected model>
ANTHROPIC_DEFAULT_SONNET_MODEL=poolside/laguna-xs-2.1:free
ANTHROPIC_DEFAULT_OPUS_MODEL=poolside/laguna-m.1:free
ANTHROPIC_DEFAULT_HAIKU_MODEL=cohere/north-mini-code:free
ANTHROPIC_CUSTOM_MODEL_OPTION=nvidia/nemotron-3-super-120b-a12b:free
CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1
CLAUDE_CODE_SUBAGENT_MODEL=cohere/north-mini-code:free
DISABLE_INTERLEAVED_THINKING=1
CLAUDE_CODE_DISABLE_AUTO_MEMORY=1
```

Then it runs:

```bash
claude --model "$model" --effort low --mcp-config "$HOME/.claude/openrouter-empty-mcp.json" --strict-mcp-config "$@"
```

Both `ANTHROPIC_MODEL` and `--model` are set to prevent Claude Code from reusing an old persisted model.

## Troubleshooting

### I Still See Ring On Startup

Ring was an old saved model choice. Close the open Claude session and restart:

```bash
source ~/.zshrc
claude-or
```

Run a real check:

```bash
claude-or -p "Reply only OK" --output-format json
```

In the JSON, check `modelUsage`: it should be `poolside/laguna-xs-2.1:free`.

### The Shell Still Has The Old Function

Already loaded shell functions do not change until you reload your profile:

```bash
source ~/.zshrc
functions claude-or | grep laguna
```

### OpenRouter Free Is Slow Or Rate-Limited

Free models can be rate-limited or removed. Try:

```bash
claude-or north-code
claude-or laguna-m
claude-or nemotron-free
claude-or router
```

### NVIDIA Does Not Start

Check:

```bash
curl http://127.0.0.1:4000/health
curl http://127.0.0.1:4000/v1/models
```

Restart the proxy:

```bash
pkill -f "litellm --config"
claude-or kimi-k2.6
```

### Missing API Key

Edit:

```text
~/.claude/.env
```

### Updating The Installed Config From This Repo

From the repo:

```bash
bash setup-linux-mac.sh
source ~/.zshrc
claude-or models
```
