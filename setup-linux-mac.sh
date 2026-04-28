#!/bin/bash
# Setup script per Linux e macOS
# Esegui: bash setup-linux-mac.sh

echo "=========================================="
echo "Setup Claude Code con LiteLLM Proxy"
echo "=========================================="
echo ""

# 1. Installa LiteLLM
echo "[1/5] Installazione di LiteLLM..."
pip install litellm
if [ $? -ne 0 ]; then
    echo "Errore: pip install fallito. Assicurati di avere Python e pip installati."
    exit 1
fi
echo "OK: LiteLLM installato."
echo ""

# 2. Crea directory di configurazione
echo "[2/5] Creazione directory di configurazione..."
mkdir -p ~/.claude
echo "OK: Directory ~/.claude pronta."
echo ""

# 3. Copia il file di configurazione
echo "[3/5] Copia del file litellm_config.yaml..."
cp litellm_config.yaml ~/.claude/litellm_config.yaml
echo "OK: Config copiata in ~/.claude/litellm_config.yaml"
echo ""

# 4. Configura le API key
echo "[4/5] Configurazione delle API key..."
echo ""
echo "Apri il file .env.template e inserisci le tue API key:"
echo "  - OpenRouter: https://openrouter.ai/keys"
echo "  - NVIDIA: https://build.nvidia.com/"
echo ""
echo "Poi aggiungi queste righe al tuo ~/.zshrc o ~/.bashrc:"
echo ""
echo "  export OPENROUTER_API_KEY=\"la_tua_openrouter_key\""
echo "  export NVIDIA_API_KEY=\"la_tua_nvidia_key\""
echo ""
echo "Oppure crea un file ~/.claude/.env con le stesse variabili."
echo ""

# 5. Aggiungi la function claude-or
echo "[5/5] Aggiunta della function claude-or allo shell..."
cat >> ~/.zshrc << 'SHELL_FUNC'

# --- LLM API keys (per LiteLLM proxy) ---
# Assicurati di aver impostato queste variabili prima di usare claude-or
# export OPENROUTER_API_KEY="la_tua_key"
# export NVIDIA_API_KEY="la_tua_key"

# --- Claude Code con modelli free (OpenRouter + NVIDIA NIM) ---
function claude-or() {
    if ! curl -sf http://127.0.0.1:4000/health &>/dev/null; then
        echo "Avvio proxy LiteLLM..."
        pkill -f "litellm --config" 2>/dev/null
        litellm --config ~/.claude/litellm_config.yaml --port 4000 &>/tmp/litellm-proxy.log &
        disown
        local i=0
        while ! curl -sf http://127.0.0.1:4000/health &>/dev/null; do
            sleep 1
            i=$((i+1))
            [[ $i -ge 30 ]] && echo "Errore: proxy non risponde dopo 30s - vedi /tmp/litellm-proxy.log" && return 1
        done
        echo "Proxy pronto."
    fi
    echo ""
    echo "Modelli disponibili (usa /model <nome>):"
    echo "  [NVIDIA NIM - default]"
    echo "    qwen3-122b      → Qwen 3.5 122B (generale)"
    echo "    qwen-coder-480b → Qwen 3 Coder 480B (heavy coding, 256K ctx)"
    echo "    nemotron-120b   → Nemotron Super 120B (agents, 262K ctx)"
    echo "    nvidia-coder    → Qwen 2.5 Coder 32B (leggero)"
    echo "  [OpenRouter]"
    echo "    deepseek-v4-pro → DeepSeek V4 Pro (1.6T params)"
    echo "    deepseek-flash  → DeepSeek V4 Flash (veloce)"
    echo "    hermes-405b     → Hermes 405B"
    echo "    gemma-12b       → Gemma 2 12B"
    echo "    gemma-4b        → Gemma 2 4B"
    echo ""
    ANTHROPIC_BASE_URL=http://127.0.0.1:4000 claude --model qwen3-122b "$@"
}
SHELL_FUNC

# Aggiungi anche per bash
cat >> ~/.bashrc << 'SHELL_FUNC' 2>/dev/null || true

# --- LLM API keys (per LiteLLM proxy) ---
# export OPENROUTER_API_KEY="la_tua_key"
# export NVIDIA_API_KEY="la_tua_key"

# --- Claude Code con modelli free (OpenRouter + NVIDIA NIM) ---
function claude-or() {
    if ! curl -sf http://127.0.0.1:4000/health &>/dev/null; then
        echo "Avvio proxy LiteLLM..."
        pkill -f "litellm --config" 2>/dev/null
        litellm --config ~/.claude/litellm_config.yaml --port 4000 &>/tmp/litellm-proxy.log &
        disown
        local i=0
        while ! curl -sf http://127.0.0.1:4000/health &>/dev/null; do
            sleep 1
            i=$((i+1))
            [[ $i -ge 30 ]] && echo "Errore: proxy non risponde dopo 30s - vedi /tmp/litellm-proxy.log" && return 1
        done
        echo "Proxy pronto."
    fi
    echo ""
    echo "Modelli disponibili (usa /model <nome>):"
    echo "  [NVIDIA NIM - default]"
    echo "    qwen3-122b      → Qwen 3.5 122B (generale)"
    echo "    qwen-coder-480b → Qwen 3 Coder 480B (heavy coding, 256K ctx)"
    echo "    nemotron-120b   → Nemotron Super 120B (agents, 262K ctx)"
    echo "    nvidia-coder    → Qwen 2.5 Coder 32B (leggero)"
    echo "  [OpenRouter]"
    echo "    deepseek-v4-pro → DeepSeek V4 Pro (1.6T params)"
    echo "    deepseek-flash  → DeepSeek V4 Flash (veloce)"
    echo "    hermes-405b     → Hermes 405B"
    echo "    gemma-12b       → Gemma 2 12B"
    echo "    gemma-4b        → Gemma 2 4B"
    echo ""
    ANTHROPIC_BASE_URL=http://127.0.0.1:4000 claude --model qwen3-122b "$@"
}
SHELL_FUNC

echo "OK: Function claude-or aggiunta."
echo ""

# Conclusione
echo "=========================================="
echo "Setup completato!"
echo "=========================================="
echo ""
echo "Prossimi passi:"
echo "1. Riavvia lo shell o esegui: source ~/.zshrc (o source ~/.bashrc)"
echo "2. Ottieni le API key:"
echo "   - OpenRouter: https://openrouter.ai/keys"
echo "   - NVIDIA: https://build.nvidia.com/"
echo "3. Aggiungi le API key al tuo ~/.zshrc/~/.bashrc o crea ~/.claude/.env"
echo "4. Avvia con: claude-or"
echo ""
echo "Per cambiare modello durante una sessione, usa: /model <nome>"
echo ""
echo "Log del proxy: /tmp/litellm-proxy.log"
echo "Verifica proxy: curl http://127.0.0.1:4000/health"
echo ""
