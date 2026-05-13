# Claude Code Free Router

Use Claude Code with free OpenRouter models and NVIDIA NIM models from one startup command.

The setup is intentionally split by provider:

- OpenRouter `:free` models go directly to OpenRouter's Anthropic-compatible API.
- NVIDIA NIM models use LiteLLM only as a local Anthropic-compatible adapter.
- Model selection happens at session start with `claude-or <model>`.
- `ring` is the default model.

## Why LiteLLM Is Still Here

Claude Code speaks the Anthropic Messages API. OpenRouter can expose `:free` models through an Anthropic-compatible endpoint, so those can be used directly.

NVIDIA NIM exposes an OpenAI-compatible API. LiteLLM is used only when you choose an NVIDIA model, translating:

```text
Claude Code -> LiteLLM local proxy -> NVIDIA NIM
```

OpenRouter free models do not use LiteLLM in the generated `claude-or` function.

## Install

### macOS / Linux

```bash
git clone https://github.com/Giulio678/claude-code-free-router.git
cd claude-code-free-router
bash setup-linux-mac.sh
```

Reload your shell:

```bash
source ~/.zshrc
```

### Windows PowerShell

```powershell
git clone https://github.com/Giulio678/claude-code-free-router.git
cd claude-code-free-router
powershell -ExecutionPolicy Bypass -File setup-windows.ps1
```

Reload your PowerShell profile:

```powershell
. $PROFILE
```

## API Keys

The installer creates:

```text
~/.claude/.env
```

Add:

```bash
OPENROUTER_API_KEY="sk-or-v1-..."
NVIDIA_API_KEY="nvapi-..."
```

Get keys from:

- OpenRouter: https://openrouter.ai/keys
- NVIDIA NIM: https://build.nvidia.com/

## Commands

List available startup commands:

```bash
claude-or models
```

Start the default session:

```bash
claude-or
```

Default:

```text
inclusionai/ring-2.6-1t:free
```

## OpenRouter Free Models

These use OpenRouter directly:

```bash
claude-or qwen-coder        # qwen/qwen3-coder:free
claude-or qwen-next         # qwen/qwen3-next-80b-a3b-instruct:free
claude-or ring              # inclusionai/ring-2.6-1t:free
claude-or nemotron-free     # nvidia/nemotron-3-super-120b-a12b:free
claude-or gpt-oss-20b       # openai/gpt-oss-20b:free
claude-or gpt-oss-120b      # openai/gpt-oss-120b:free
claude-or hermes-405b       # nousresearch/hermes-3-llama-3.1-405b:free
```

Full IDs also work:

```bash
claude-or qwen/qwen3-coder:free
claude-or qwen/qwen3-next-80b-a3b-instruct:free
claude-or inclusionai/ring-2.6-1t:free
claude-or nvidia/nemotron-3-super-120b-a12b:free
```

## NVIDIA NIM Models

These use NVIDIA NIM through LiteLLM:

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

Full IDs also work for NVIDIA models:

```bash
claude-or moonshotai/kimi-k2.6
claude-or mistralai/mistral-medium-3.5-128b
```

## Slash Command

The installer copies:

```text
~/.claude/commands/models.md
```

Inside Claude Code, run:

```text
/models
```

It shows the same startup command list. Provider switching is intentionally done by starting a new session with `claude-or <model>`.

## Files Installed

```text
~/.claude/litellm_config.yaml
~/.claude/openrouter-empty-mcp.json
~/.claude/commands/models.md
~/.claude/.env
```

## How `claude-or` Works

For OpenRouter free models:

```text
Claude Code -> OpenRouter Anthropic-compatible endpoint
```

For NVIDIA models:

```text
Claude Code -> LiteLLM on localhost:4000 -> NVIDIA NIM
```

The shell function sets:

```text
--effort low
--mcp-config ~/.claude/openrouter-empty-mcp.json
--strict-mcp-config
```

That keeps startup faster and avoids unrelated MCP timeouts.

## Troubleshooting

### List models

```bash
claude-or models
```

### OpenRouter free model is slow or rate-limited

Free models can be rate-limited upstream. Try another free alias:

```bash
claude-or ring
claude-or qwen-coder
claude-or nemotron-free
```

### NVIDIA model does not start

Check the proxy:

```bash
curl http://127.0.0.1:4000/health
curl http://127.0.0.1:4000/v1/models
```

Restart it:

```bash
pkill -f "litellm --config"
claude-or kimi-k2.6
```

Logs:

```text
/tmp/litellm-nvidia.log
```

### API key missing

Edit:

```text
~/.claude/.env
```

and add both keys.

## Repository Name

Suggested GitHub repository name:

```text
claude-code-free-router
```
