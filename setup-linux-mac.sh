#!/usr/bin/env bash
set -euo pipefail

echo "========================================"
echo "Claude Code Free Router setup"
echo "========================================"
echo ""

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BEGIN_MARKER="# >>> claude-code-free-router >>>"
END_MARKER="# <<< claude-code-free-router <<<"

install_litellm() {
  if command -v litellm >/dev/null 2>&1; then
    echo "OK: LiteLLM already installed: $(command -v litellm)"
    return
  fi

  echo "Installing LiteLLM..."
  if command -v python3 >/dev/null 2>&1; then
    python3 -m pip install --user litellm
  else
    pip install --user litellm
  fi
}

install_block() {
  local profile="$1"
  mkdir -p "$(dirname "$profile")"
  touch "$profile"

  local tmp
  tmp="$(mktemp)"
  awk -v begin="$BEGIN_MARKER" -v end="$END_MARKER" '
    $0 == begin {skip=1; next}
    $0 == end {skip=0; next}
    skip != 1 {print}
  ' "$profile" > "$tmp"
  cat "$tmp" > "$profile"
  rm -f "$tmp"

  cat >> "$profile" <<'SHELL_BLOCK'

# >>> claude-code-free-router >>>
# Claude Code Free Router
# --- LLM API keys ---
if [ -f "$HOME/.claude/.env" ]; then
  set -a
  source "$HOME/.claude/.env"
  set +a
fi

# --- Claude Code con selezione modello a inizio sessione ---
function claude-or() {
  if [ -z "$OPENROUTER_API_KEY" ]; then
    echo "Errore: OPENROUTER_API_KEY non impostata. Controlla $HOME/.claude/.env"
    return 1
  fi

  local requested_model="${1:-laguna-xs}"
  local has_requested_model_arg=0
  [[ $# -gt 0 ]] && has_requested_model_arg=1
  local model
  local provider="openrouter"
  local or_sonnet_model="poolside/laguna-xs-2.1:free"
  local or_opus_model="poolside/laguna-m.1:free"
  local or_haiku_model="cohere/north-mini-code:free"
  local or_custom_model="nvidia/nemotron-3-super-120b-a12b:free"

  case "$requested_model" in
    models|model|list|--models|-m)
      echo "Comandi disponibili:"
      echo ""
      echo "OpenRouter free:"
      echo "  claude-or laguna-xs         # poolside/laguna-xs-2.1:free (default)"
      echo "  claude-or north-code        # cohere/north-mini-code:free"
      echo "  claude-or laguna-m          # poolside/laguna-m.1:free"
      echo "  claude-or nemotron-free     # nvidia/nemotron-3-super-120b-a12b:free"
      echo "  claude-or router            # openrouter/free"
      echo ""
      echo "Legacy OpenRouter free:"
      echo "  claude-or qwen-coder        # qwen/qwen3-coder:free"
      echo "  claude-or qwen-next         # qwen/qwen3-next-80b-a3b-instruct:free"
      echo "  claude-or gpt-oss-20b       # openai/gpt-oss-20b:free"
      echo "  claude-or gpt-oss-120b      # openai/gpt-oss-120b:free"
      echo "  claude-or hermes-405b       # nousresearch/hermes-3-llama-3.1-405b:free"
      echo ""
      echo "NVIDIA NIM:"
      echo "  claude-or kimi-k2.6         # moonshotai/kimi-k2.6"
      echo "  claude-or mistral-medium    # mistralai/mistral-medium-3.5-128b"
      echo "  claude-or nvidia-nano       # nvidia/nemotron-3-nano-30b-a3b"
      echo "  claude-or nvidia-omni       # nvidia/nemotron-3-nano-omni-30b-a3b-reasoning"
      echo "  claude-or nemotron-120b     # nvidia/nemotron-3-super-120b-a12b"
      echo "  claude-or qwen-coder-nvidia # qwen/qwen3-coder-480b-a35b-instruct"
      echo "  claude-or qwen-next-nvidia  # qwen/qwen3-next-80b-a3b-instruct"
      echo "  claude-or qwen3.5-122b      # qwen/qwen3.5-122b-a10b"
      echo ""
      echo "Puoi anche passare un model ID completo:"
      echo "  claude-or poolside/laguna-xs-2.1:free"
      echo "  claude-or moonshotai/kimi-k2.6"
      return 0
      ;;
    laguna-xs|laguna-xs-2.1|poolside-xs|poolside-laguna-xs|coding|default)
      model="poolside/laguna-xs-2.1:free"
      (( has_requested_model_arg )) && shift
      ;;
    north-code|north-mini-code|cohere-code|fast)
      model="cohere/north-mini-code:free"
      (( has_requested_model_arg )) && shift
      ;;
    laguna-m|laguna-m.1|poolside-m|poolside-laguna-m|large|hard)
      model="poolside/laguna-m.1:free"
      (( has_requested_model_arg )) && shift
      ;;
    router|openrouter-router|openrouter-free|free)
      model="openrouter/free"
      (( has_requested_model_arg )) && shift
      ;;
    qwen-coder|qwen-coder-480b|nvidia-coder)
      model="qwen/qwen3-coder:free"
      (( has_requested_model_arg )) && shift
      ;;
    cobuddy)
      echo "Errore: cobuddy e disabilitato: con Claude Code puo dare API 400."
      echo "Usa laguna-xs, north-code, laguna-m o nemotron-free."
      return 1
      ;;
    qwen-next|qwen3-next|qwen3-122b|balanced)
      model="qwen/qwen3-next-80b-a3b-instruct:free"
      (( has_requested_model_arg )) && shift
      ;;
    nvidia-nano|nemotron-nano)
      provider="nvidia"
      model="nvidia-nano"
      (( has_requested_model_arg )) && shift
      ;;
    nvidia-omni|nemotron-omni)
      provider="nvidia"
      model="nvidia-omni"
      (( has_requested_model_arg )) && shift
      ;;
    nemotron-120b|nvidia-super)
      provider="nvidia"
      model="nemotron-120b"
      (( has_requested_model_arg )) && shift
      ;;
    gpt-oss-20b)
      model="openai/gpt-oss-20b:free"
      (( has_requested_model_arg )) && shift
      ;;
    gpt-oss-120b)
      model="openai/gpt-oss-120b:free"
      (( has_requested_model_arg )) && shift
      ;;
    llama-3.2-3b|llama-fast)
      model="meta-llama/llama-3.2-3b-instruct:free"
      (( has_requested_model_arg )) && shift
      ;;
    hermes-405b)
      model="nousresearch/hermes-3-llama-3.1-405b:free"
      (( has_requested_model_arg )) && shift
      ;;
    nemotron-free|nemotron-120b-free|nvidia-super-free|nemotron-super|long|reasoning)
      model="nvidia/nemotron-3-super-120b-a12b:free"
      (( has_requested_model_arg )) && shift
      ;;
    kimi|kimi-k2.6|moonshot|moonshot-kimi)
      provider="nvidia"
      model="kimi-k2.6"
      (( has_requested_model_arg )) && shift
      ;;
    mistral|mistral-medium|mistral-medium-3.5|mistral-medium-3-5|mistral-medium-3.5-128b)
      provider="nvidia"
      model="mistral-medium"
      (( has_requested_model_arg )) && shift
      ;;
    qwen-coder-nvidia)
      provider="nvidia"
      model="qwen-coder-nvidia"
      (( has_requested_model_arg )) && shift
      ;;
    qwen-next-nvidia)
      provider="nvidia"
      model="qwen-next-nvidia"
      (( has_requested_model_arg )) && shift
      ;;
    qwen3.5-122b|qwen3-122b-nvidia)
      provider="nvidia"
      model="qwen3.5-122b-nvidia"
      (( has_requested_model_arg )) && shift
      ;;
    deepseek-v4-pro|deepseek-flash|gemma-4b|gemma-12b)
      echo "Errore: '$requested_model' non risulta disponibile come modello OpenRouter :free diretto."
      echo "Usa: claude-or models"
      return 1
      ;;
    -*)
      model="$or_sonnet_model"
      ;;
    */*)
      case "$requested_model" in
        *:free|openrouter/*)
          model="$requested_model"
          ;;
        *)
          provider="nvidia"
          model="$requested_model"
          ;;
      esac
      (( has_requested_model_arg )) && shift
      ;;
    *)
      echo "Errore: modello o alias non riconosciuto: $requested_model"
      echo "Usa: claude-or models"
      return 1
      ;;
  esac

  if [ "$provider" = "openrouter" ]; then
    echo "OpenRouter: $model"
    ANTHROPIC_BASE_URL="https://openrouter.ai/api" \
    ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY" \
    ANTHROPIC_API_KEY="" \
    ANTHROPIC_MODEL="$model" \
    ANTHROPIC_DEFAULT_OPUS_MODEL="$or_opus_model" \
    ANTHROPIC_DEFAULT_OPUS_MODEL_NAME="Laguna M.1" \
    ANTHROPIC_DEFAULT_OPUS_MODEL_DESCRIPTION="Poolside Laguna M.1 free, coding large" \
    ANTHROPIC_DEFAULT_SONNET_MODEL="$or_sonnet_model" \
    ANTHROPIC_DEFAULT_SONNET_MODEL_NAME="Laguna XS 2.1" \
    ANTHROPIC_DEFAULT_SONNET_MODEL_DESCRIPTION="Poolside Laguna XS 2.1 free, default coding model" \
    ANTHROPIC_DEFAULT_HAIKU_MODEL="$or_haiku_model" \
    ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME="North Mini Code" \
    ANTHROPIC_DEFAULT_HAIKU_MODEL_DESCRIPTION="Cohere North Mini Code free, fast coding model" \
    ANTHROPIC_CUSTOM_MODEL_OPTION="$or_custom_model" \
    ANTHROPIC_CUSTOM_MODEL_OPTION_NAME="Nemotron 3 Super" \
    ANTHROPIC_CUSTOM_MODEL_OPTION_DESCRIPTION="NVIDIA Nemotron 3 Super free, long-context reasoning" \
    CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1 \
    CLAUDE_CODE_SUBAGENT_MODEL="$or_haiku_model" \
    DISABLE_INTERLEAVED_THINKING=1 \
    CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 \
    claude --model "$model" --effort low --mcp-config "$HOME/.claude/openrouter-empty-mcp.json" --strict-mcp-config "$@"
  else
    if [ -z "$NVIDIA_API_KEY" ]; then
      echo "Errore: NVIDIA_API_KEY non impostata. Controlla $HOME/.claude/.env"
      return 1
    fi
    if ! curl -sf http://127.0.0.1:4000/health >/dev/null 2>&1; then
      echo "Avvio proxy LiteLLM solo per NVIDIA..."
      pkill -f "litellm --config $HOME/.claude/litellm_config.yaml" 2>/dev/null
      litellm --config "$HOME/.claude/litellm_config.yaml" --port 4000 >/tmp/litellm-nvidia.log 2>&1 &
      disown
      local i=0
      while ! curl -sf http://127.0.0.1:4000/health >/dev/null 2>&1; do
        sleep 1
        i=$((i+1))
        if [ "$i" -ge 20 ]; then
          echo "Errore: LiteLLM non risponde dopo 20s. Log: /tmp/litellm-nvidia.log"
          return 1
        fi
      done
    fi
    echo "NVIDIA NIM: $model"
    ANTHROPIC_BASE_URL="http://127.0.0.1:4000" \
    ANTHROPIC_AUTH_TOKEN="sk-litellm-proxy" \
    ANTHROPIC_API_KEY="" \
    ANTHROPIC_MODEL="$model" \
    ANTHROPIC_DEFAULT_OPUS_MODEL="$model" \
    ANTHROPIC_DEFAULT_SONNET_MODEL="$model" \
    ANTHROPIC_DEFAULT_HAIKU_MODEL="qwen-coder-nvidia" \
    CLAUDE_CODE_SUBAGENT_MODEL="qwen-coder-nvidia" \
    DISABLE_INTERLEAVED_THINKING=1 \
    CLAUDE_CODE_DISABLE_AUTO_MEMORY=1 \
    claude --model "$model" --effort low --mcp-config "$HOME/.claude/openrouter-empty-mcp.json" --strict-mcp-config "$@"
  fi
}
# <<< claude-code-free-router <<<
SHELL_BLOCK
}

echo "[1/4] Installing LiteLLM if needed"
install_litellm

echo "[2/4] Installing config files"
mkdir -p "$CLAUDE_DIR/commands"
cp "$ROOT_DIR/litellm_config.yaml" "$CLAUDE_DIR/litellm_config.yaml"
cp "$ROOT_DIR/openrouter-empty-mcp.json" "$CLAUDE_DIR/openrouter-empty-mcp.json"
cp "$ROOT_DIR/commands/models.md" "$CLAUDE_DIR/commands/models.md"
if [ ! -f "$CLAUDE_DIR/.env" ]; then
  cp "$ROOT_DIR/.env.template" "$CLAUDE_DIR/.env"
  echo "Created $CLAUDE_DIR/.env. Add your API keys there."
fi

echo "[3/4] Installing claude-or shell function"
install_block "$HOME/.zshrc"
if [ -f "$HOME/.bashrc" ] || [ ! -f "$HOME/.zshrc" ]; then
  install_block "$HOME/.bashrc"
fi

echo "[4/4] Done"
echo ""
echo "Next:"
echo "  1. Edit $CLAUDE_DIR/.env and add OPENROUTER_API_KEY and NVIDIA_API_KEY"
echo "  2. Reload your shell: source ~/.zshrc"
echo "  3. List commands: claude-or models"
echo "  4. Start default Laguna session: claude-or"
