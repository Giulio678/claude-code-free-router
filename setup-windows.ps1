# Claude Code Free Router setup for Windows PowerShell.
# Run: powershell -ExecutionPolicy Bypass -File setup-windows.ps1

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Claude Code Free Router setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = Join-Path $env:USERPROFILE ".claude"
$CommandsDir = Join-Path $ClaudeDir "commands"
$ProfilePath = $PROFILE
$BeginMarker = "# >>> claude-code-free-router >>>"
$EndMarker = "# <<< claude-code-free-router <<<"

function Install-LiteLLM {
    $cmd = Get-Command litellm -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Host "OK: LiteLLM already installed: $($cmd.Source)" -ForegroundColor Green
        return
    }
    Write-Host "Installing LiteLLM..." -ForegroundColor Yellow
    python -m pip install --user litellm
}

function Install-ProfileBlock {
    New-Item -ItemType Directory -Path (Split-Path -Parent $ProfilePath) -Force | Out-Null
    if (!(Test-Path $ProfilePath)) {
        New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
    }

    $existing = Get-Content $ProfilePath -Raw
    $pattern = "(?s)\n?$([regex]::Escape($BeginMarker)).*?$([regex]::Escape($EndMarker))\n?"
    $clean = [regex]::Replace($existing, $pattern, "")
    Set-Content -Path $ProfilePath -Value $clean

    $block = @'

# >>> claude-code-free-router >>>
# Claude Code Free Router
if (Test-Path "$env:USERPROFILE\.claude\.env") {
    Get-Content "$env:USERPROFILE\.claude\.env" | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
            [Environment]::SetEnvironmentVariable($matches[1].Trim(), $matches[2].Trim().Trim('"'), "Process")
        }
    }
}

function claude-or {
    param([string]$Model = "laguna-xs")

    if (-not $env:OPENROUTER_API_KEY) {
        Write-Host "Error: OPENROUTER_API_KEY is missing. Put it in $env:USERPROFILE\.claude\.env" -ForegroundColor Red
        return
    }

    $provider = "openrouter"
    switch ($Model) {
        {$_ -in @("models","model","list","--models","-m")} {
            Write-Host "OpenRouter free:"
            Write-Host "  claude-or laguna-xs         # poolside/laguna-xs-2.1:free (default)"
            Write-Host "  claude-or north-code        # cohere/north-mini-code:free"
            Write-Host "  claude-or laguna-m          # poolside/laguna-m.1:free"
            Write-Host "  claude-or nemotron-free     # nvidia/nemotron-3-super-120b-a12b:free"
            Write-Host "  claude-or router            # openrouter/free"
            Write-Host ""
            Write-Host "Legacy OpenRouter free:"
            Write-Host "  claude-or qwen-coder        # qwen/qwen3-coder:free"
            Write-Host "  claude-or qwen-next         # qwen/qwen3-next-80b-a3b-instruct:free"
            Write-Host "  claude-or gpt-oss-20b       # openai/gpt-oss-20b:free"
            Write-Host "  claude-or gpt-oss-120b      # openai/gpt-oss-120b:free"
            Write-Host "  claude-or hermes-405b       # nousresearch/hermes-3-llama-3.1-405b:free"
            Write-Host ""
            Write-Host "NVIDIA NIM:"
            Write-Host "  claude-or kimi-k2.6"
            Write-Host "  claude-or mistral-medium"
            Write-Host "  claude-or nvidia-nano"
            Write-Host "  claude-or nvidia-omni"
            Write-Host "  claude-or nemotron-120b"
            Write-Host "  claude-or qwen-coder-nvidia"
            Write-Host "  claude-or qwen-next-nvidia"
            Write-Host "  claude-or qwen3.5-122b"
            return
        }
        {$_ -in @("laguna-xs","laguna-xs-2.1","poolside-xs","poolside-laguna-xs","coding","default")} { $target = "poolside/laguna-xs-2.1:free" }
        {$_ -in @("north-code","north-mini-code","cohere-code","fast")} { $target = "cohere/north-mini-code:free" }
        {$_ -in @("laguna-m","laguna-m.1","poolside-m","poolside-laguna-m","large","hard")} { $target = "poolside/laguna-m.1:free" }
        {$_ -in @("router","openrouter-router","openrouter-free","free")} { $target = "openrouter/free" }
        {$_ -in @("qwen-coder","qwen-coder-480b","nvidia-coder")} { $target = "qwen/qwen3-coder:free" }
        {$_ -in @("qwen-next","qwen3-next","qwen3-122b","balanced")} { $target = "qwen/qwen3-next-80b-a3b-instruct:free" }
        {$_ -in @("nemotron-free","nemotron-120b-free","nvidia-super-free")} { $target = "nvidia/nemotron-3-super-120b-a12b:free" }
        "gpt-oss-20b" { $target = "openai/gpt-oss-20b:free" }
        {$_ -in @("gpt-oss-120b")} { $target = "openai/gpt-oss-120b:free" }
        {$_ -in @("hermes-405b")} { $target = "nousresearch/hermes-3-llama-3.1-405b:free" }
        {$_ -in @("kimi","kimi-k2.6","moonshot","moonshot-kimi")} { $provider = "nvidia"; $target = "kimi-k2.6" }
        {$_ -in @("mistral","mistral-medium","mistral-medium-3.5","mistral-medium-3-5","mistral-medium-3.5-128b")} { $provider = "nvidia"; $target = "mistral-medium" }
        {$_ -in @("nvidia-nano","nemotron-nano")} { $provider = "nvidia"; $target = "nvidia-nano" }
        {$_ -in @("nvidia-omni","nemotron-omni")} { $provider = "nvidia"; $target = "nvidia-omni" }
        {$_ -in @("nemotron-120b","nvidia-super")} { $provider = "nvidia"; $target = "nemotron-120b" }
        "qwen-coder-nvidia" { $provider = "nvidia"; $target = "qwen-coder-nvidia" }
        "qwen-next-nvidia" { $provider = "nvidia"; $target = "qwen-next-nvidia" }
        {$_ -in @("qwen3.5-122b","qwen3-122b-nvidia")} { $provider = "nvidia"; $target = "qwen3.5-122b-nvidia" }
        default {
            if ($Model.EndsWith(":free") -or $Model.StartsWith("openrouter/")) { $target = $Model } else { $provider = "nvidia"; $target = $Model }
        }
    }

    if ($provider -eq "openrouter") {
        Write-Host "OpenRouter: $target" -ForegroundColor Cyan
        $env:ANTHROPIC_BASE_URL = "https://openrouter.ai/api"
        $env:ANTHROPIC_AUTH_TOKEN = $env:OPENROUTER_API_KEY
        $env:ANTHROPIC_API_KEY = ""
        $env:ANTHROPIC_MODEL = $target
        $env:ANTHROPIC_DEFAULT_OPUS_MODEL = "poolside/laguna-m.1:free"
        $env:ANTHROPIC_DEFAULT_OPUS_MODEL_NAME = "Laguna M.1"
        $env:ANTHROPIC_DEFAULT_SONNET_MODEL = "poolside/laguna-xs-2.1:free"
        $env:ANTHROPIC_DEFAULT_SONNET_MODEL_NAME = "Laguna XS 2.1"
        $env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "cohere/north-mini-code:free"
        $env:ANTHROPIC_DEFAULT_HAIKU_MODEL_NAME = "North Mini Code"
        $env:ANTHROPIC_CUSTOM_MODEL_OPTION = "nvidia/nemotron-3-super-120b-a12b:free"
        $env:ANTHROPIC_CUSTOM_MODEL_OPTION_NAME = "Nemotron 3 Super"
        $env:CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = "1"
        $env:CLAUDE_CODE_SUBAGENT_MODEL = "cohere/north-mini-code:free"
        $env:DISABLE_INTERLEAVED_THINKING = "1"
        $env:CLAUDE_CODE_DISABLE_AUTO_MEMORY = "1"
        claude --model $target --effort low --mcp-config "$env:USERPROFILE\.claude\openrouter-empty-mcp.json" --strict-mcp-config
    } else {
        if (-not $env:NVIDIA_API_KEY) {
            Write-Host "Error: NVIDIA_API_KEY is missing. Put it in $env:USERPROFILE\.claude\.env" -ForegroundColor Red
            return
        }
        try {
            Invoke-WebRequest -Uri "http://127.0.0.1:4000/health" -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop | Out-Null
        } catch {
            Write-Host "Starting LiteLLM only for NVIDIA..." -ForegroundColor Yellow
            Start-Process -FilePath "litellm" -ArgumentList "--config", "$env:USERPROFILE\.claude\litellm_config.yaml", "--port", "4000" -WindowStyle Hidden
            Start-Sleep -Seconds 4
        }
        Write-Host "NVIDIA NIM: $target" -ForegroundColor Cyan
        $env:ANTHROPIC_BASE_URL = "http://127.0.0.1:4000"
        $env:ANTHROPIC_AUTH_TOKEN = "sk-litellm-proxy"
        $env:ANTHROPIC_API_KEY = ""
        $env:ANTHROPIC_MODEL = $target
        $env:ANTHROPIC_DEFAULT_OPUS_MODEL = $target
        $env:ANTHROPIC_DEFAULT_SONNET_MODEL = $target
        $env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "qwen-coder-nvidia"
        $env:CLAUDE_CODE_SUBAGENT_MODEL = "qwen-coder-nvidia"
        $env:DISABLE_INTERLEAVED_THINKING = "1"
        $env:CLAUDE_CODE_DISABLE_AUTO_MEMORY = "1"
        claude --model $target --effort low --mcp-config "$env:USERPROFILE\.claude\openrouter-empty-mcp.json" --strict-mcp-config
    }
}
# <<< claude-code-free-router <<<
'@

    Add-Content -Path $ProfilePath -Value $block
}

Write-Host "[1/4] Installing LiteLLM if needed" -ForegroundColor Yellow
Install-LiteLLM

Write-Host "[2/4] Installing config files" -ForegroundColor Yellow
New-Item -ItemType Directory -Path $CommandsDir -Force | Out-Null
Copy-Item -Path (Join-Path $RootDir "litellm_config.yaml") -Destination (Join-Path $ClaudeDir "litellm_config.yaml") -Force
Copy-Item -Path (Join-Path $RootDir "openrouter-empty-mcp.json") -Destination (Join-Path $ClaudeDir "openrouter-empty-mcp.json") -Force
Copy-Item -Path (Join-Path $RootDir "commands\models.md") -Destination (Join-Path $CommandsDir "models.md") -Force
if (!(Test-Path (Join-Path $ClaudeDir ".env"))) {
    Copy-Item -Path (Join-Path $RootDir ".env.template") -Destination (Join-Path $ClaudeDir ".env") -Force
    Write-Host "Created $ClaudeDir\.env. Add your API keys there." -ForegroundColor Yellow
}

Write-Host "[3/4] Installing claude-or PowerShell function" -ForegroundColor Yellow
Install-ProfileBlock

Write-Host "[4/4] Done" -ForegroundColor Green
Write-Host ""
Write-Host "Next:"
Write-Host "  1. Edit $ClaudeDir\.env and add OPENROUTER_API_KEY and NVIDIA_API_KEY"
Write-Host "  2. Reload PowerShell: . `$PROFILE"
Write-Host "  3. List commands: claude-or models"
Write-Host "  4. Start default Laguna session: claude-or"
