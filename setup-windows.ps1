# Setup script per Windows (PowerShell)
# Esegui: powershell -ExecutionPolicy Bypass -File setup-windows.ps1

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Setup Claude Code con LiteLLM Proxy" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Installa LiteLLM
Write-Host "[1/5] Installazione di LiteLLM..." -ForegroundColor Yellow
pip install litellm
if ($LASTEXITCODE -ne 0) {
    Write-Host "Errore: pip install fallito. Assicurati di avere Python e pip installati." -ForegroundColor Red
    exit 1
}
Write-Host "OK: LiteLLM installato." -ForegroundColor Green
Write-Host ""

# 2. Crea directory di configurazione
Write-Host "[2/5] Creazione directory di configurazione..." -ForegroundColor Yellow
$claudeDir = "$env:USERPROFILE\.claude"
if (!(Test-Path $claudeDir)) {
    New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null
}
Write-Host "OK: Directory $claudeDir pronta." -ForegroundColor Green
Write-Host ""

# 3. Copia il file di configurazione
Write-Host "[3/5] Copia del file litellm_config.yaml..." -ForegroundColor Yellow
Copy-Item -Path "litellm_config.yaml" -Destination "$claudeDir\litellm_config.yaml" -Force
Write-Host "OK: Config copiata in $claudeDir\litellm_config.yaml" -ForegroundColor Green
Write-Host ""

# 4. Istruzioni per le API key
Write-Host "[4/5] Configurazione delle API key..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Apri il file .env.template e inserisci le tue API key:" -ForegroundColor White
Write-Host "  - OpenRouter: https://openrouter.ai/keys" -ForegroundColor White
Write-Host "  - NVIDIA: https://build.nvidia.com/" -ForegroundColor White
Write-Host ""
Write-Host "Poi aggiungi queste variabili d'ambiente (Metodo consigliato):" -ForegroundColor White
Write-Host ""
Write-Host "  1. Premi Win + X e seleziona 'System'" -ForegroundColor White
Write-Host "  2. Clicca su 'Advanced system settings'" -ForegroundColor White
Write-Host "  3. Clicca su 'Environment Variables'" -ForegroundColor White
Write-Host "  4. Aggiungi nuove variabili:" -ForegroundColor White
Write-Host ""
Write-Host "     OPENROUTER_API_KEY = la_tua_openrouter_key" -ForegroundColor Cyan
Write-Host "     NVIDIA_API_KEY = la_tua_nvidia_key" -ForegroundColor Cyan
Write-Host ""
Write-Host "Oppure aggiungi al tuo profilo PowerShell:" -ForegroundColor White
Write-Host ""
Write-Host "  Add-Content -Path `$env:USERPROFILE\.powershell_profile -Value `"`n# LiteLLM Proxy`n`$env:OPENROUTER_API_KEY='la_tua_key'`n`$env:NVIDIA_API_KEY='la_tua_key'`"" -ForegroundColor Cyan
Write-Host ""

# 5. Aggiungi la function claude-or al profilo PowerShell
Write-Host "[5/5] Aggiunta della function claude-or al profilo PowerShell..." -ForegroundColor Yellow

$powerShellProfile = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if (!(Test-Path $powerShellProfile)) {
    New-Item -ItemType File -Path $powerShellProfile -Force | Out-Null
}

$functionCode = @"

# --- LLM API keys (per LiteLLM proxy) ---
# Assicurati di aver impostato queste variabili prima di usare claude-or
# `$env:OPENROUTER_API_KEY = "la_tua_key"
# `$env:NVIDIA_API_KEY = "la_tua_key"

# --- Claude Code con modelli free (OpenRouter + NVIDIA NIM) ---
function claude-or {
    $proxyUrl = "http://127.0.0.1:4000/health"

    try {
        $response = Invoke-WebRequest -Uri $proxyUrl -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Host "Avvio proxy LiteLLM..." -ForegroundColor Yellow

        # Ferma eventuali proxy esistenti
        Get-Process | Where-Object { $_.ProcessName -like "*litellm*" } | Stop-Process -Force -ErrorAction SilentlyContinue

        # Avvia il proxy
        Start-Process -FilePath "litellm" -ArgumentList "--config", "$env:USERPROFILE\.claude\litellm_config.yaml", "--port", "4000" -NoNewWindow -RedirectStandardOutput "C:\tmp\litellm-proxy.log"

        # Attendi che il proxy sia pronto
        $timeout = 30
        $elapsed = 0
        while ($elapsed -lt $timeout) {
            Start-Sleep -Seconds 1
            $elapsed++
            try {
                $response = Invoke-WebRequest -Uri $proxyUrl -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop
                break
            } catch {
                continue
            }
        }

        if ($elapsed -ge $timeout) {
            Write-Host "Errore: proxy non risponde dopo ${timeout}s - vedi C:\tmp\litellm-proxy.log" -ForegroundColor Red
            return
        }

        Write-Host "Proxy pronto." -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "Modelli disponibili (usa /model <nome>):" -ForegroundColor Cyan
    Write-Host "  [NVIDIA NIM - default]" -ForegroundColor White
    Write-Host "    qwen3-122b      → Qwen 3.5 122B (generale)" -ForegroundColor Gray
    Write-Host "    qwen-coder-480b → Qwen 3 Coder 480B (heavy coding, 256K ctx)" -ForegroundColor Gray
    Write-Host "    nemotron-120b   → Nemotron Super 120B (agents, 262K ctx)" -ForegroundColor Gray
    Write-Host "    nvidia-coder    → Qwen 2.5 Coder 32B (leggero)" -ForegroundColor Gray
    Write-Host "  [OpenRouter]" -ForegroundColor White
    Write-Host "    deepseek-v4-pro → DeepSeek V4 Pro (1.6T params)" -ForegroundColor Gray
    Write-Host "    deepseek-flash  → DeepSeek V4 Flash (veloce)" -ForegroundColor Gray
    Write-Host "    hermes-405b     → Hermes 405B" -ForegroundColor Gray
    Write-Host "    gemma-12b       → Gemma 2 12B" -ForegroundColor Gray
    Write-Host "    gemma-4b        → Gemma 2 4B" -ForegroundColor Gray
    Write-Host ""

    $env:ANTHROPIC_BASE_URL = "http://127.0.0.1:4000"
    claude --model qwen3-122b $args
}
"@

Add-Content -Path $powerShellProfile -Value $functionCode

Write-Host "OK: Function claude-or aggiunta al profilo PowerShell." -ForegroundColor Green
Write-Host ""

# Conclusione
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Setup completato!" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Prossimi passi:" -ForegroundColor Yellow
Write-Host "1. Riavvia PowerShell o esegui: . $powerShellProfile" -ForegroundColor White
Write-Host "2. Ottieni le API key:" -ForegroundColor White
Write-Host "   - OpenRouter: https://openrouter.ai/keys" -ForegroundColor Cyan
Write-Host "   - NVIDIA: https://build.nvidia.com/" -ForegroundColor Cyan
Write-Host "3. Aggiungi le API key come variabili d'ambiente o al profilo PowerShell" -ForegroundColor White
Write-Host "4. Avvia con: claude-or" -ForegroundColor Green
Write-Host ""
Write-Host "Per cambiare modello durante una sessione, usa: /model <nome>" -ForegroundColor White
Write-Host ""
Write-Host "Log del proxy: C:\tmp\litellm-proxy.log" -ForegroundColor White
Write-Host "Verifica proxy: curl http://127.0.0.1:4000/health" -ForegroundColor White
Write-Host ""
