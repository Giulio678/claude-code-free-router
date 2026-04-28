# Claude Code con LiteLLM Proxy 🚀

Configurazione cross-platform per usare **Claude Code** con modelli AI gratuiti/low-cost tramite un proxy **LiteLLM** locale, con backend su **NVIDIA NIM** e **OpenRouter**.

## ✨ Cosa Ottieni

- 🆓 **Modelli NVIDIA NIM gratuiti**: Qwen 3.5, Qwen Coder, Nemotron, ecc.
- 🌐 **Modelli OpenRouter**: DeepSeek, Hermes, Gemma, ecc.
- 🔄 **Switch dinamico** tra modelli senza riavviare Claude
- 💻 **Cross-platform**: macOS, Linux, Windows
- ⚡ **Proxy locale** veloce e privato
- 📦 **Setup automatizzato** con script pronti

## 📋 Prerequisiti

1. **Python 3.9+** installato
2. **Claude Code** installato:
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```
3. **API key** (gratuite o pay-per-use):
   - [OpenRouter](https://openrouter.ai/keys) - Modelli vari, piano free limitato
   - [NVIDIA NIM](https://build.nvidia.com/) - Alcuni modelli gratuiti

## 🚀 Installazione Rapida

### macOS / Linux

```bash
# 1. Clona il repo
git clone https://github.com/giuliorossi678/claude-litellm-config.git
cd claude-litellm-config

# 2. Esegui lo script di setup
bash setup-linux-mac.sh

# 3. Riavvia lo shell
source ~/.zshrc  # o source ~/.bashrc

# 4. Avvia Claude con i modelli
claude-or
```

### Windows (PowerShell)

```powershell
# 1. Clona il repo
git clone https://github.com/giuliorossi678/claude-litellm-config.git
cd claude-litellm-config

# 2. Esegui lo script di setup
powershell -ExecutionPolicy Bypass -File setup-windows.ps1

# 3. Riavvia PowerShell

# 4. Avvia Claude con i modelli
claude-or
```

## 📝 Configurazione delle API Key

### Passo 1: Ottieni le API Key

1. **OpenRouter**: Vai su [openrouter.ai/keys](https://openrouter.ai/keys) → Generate Key
2. **NVIDIA NIM**: Vai su [build.nvidia.com](https://build.nvidia.com/) → Sign In → Generate API Key

### Passo 2: Imposta le Variabili d'Ambiente

#### macOS / Linux (~/.zshrc o ~/.bashrc)

Aggiungi queste righe alla fine del file:

```bash
# --- LLM API keys (LiteLLM proxy) ---
export OPENROUTER_API_KEY="sk-or-v1-tua-chiave-openrouter"
export NVIDIA_API_KEY="nvapi-tua-chiave-nvidia"
```

Poi riavvia lo shell:
```bash
source ~/.zshrc  # o source ~/.bashrc
```

#### Windows (Variabili d'Ambiente)

**Metodo 1 - Environment Variables (consigliato):**

1. Premi `Win + X` → **System**
2. Clicca su **Advanced system settings**
3. Clicca su **Environment Variables**
4. Sotto **User variables**, clicca **New**
5. Aggiungi:
   - Variable name: `OPENROUTER_API_KEY`
   - Variable value: `sk-or-v1-tua-chiave-openrouter`
6. Ripeti per `NVIDIA_API_KEY`
7. **Riavvia PowerShell**

**Metodo 2 - Profile PowerShell:**

Aggiungi al file `$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`:

```powershell
$env:OPENROUTER_API_KEY = "sk-or-v1-tua-chiave-openrouter"
$env:NVIDIA_API_KEY = "nvapi-tua-chiave-nvidia"
```

## 🎯 Modelli Disponibili

### NVIDIA NIM (alcuni gratuiti)

| Modello | Descrizione | Context | Use Case |
|---------|-------------|---------|----------|
| `qwen3-122b` | Qwen 3.5 122B | 200K | Generale, coding, ragionamento |
| `qwen-coder-480b` | Qwen 3 Coder 480B | 256K | Heavy coding, refactoring |
| `nemotron-120b` | Nemotron Super 120B | 262K | Agents, complessi |
| `nvidia-coder` | Qwen 2.5 Coder 32B | 100K | Leggero, veloce |

### OpenRouter

| Modello | Descrizione | Context | Use Case |
|---------|-------------|---------|----------|
| `deepseek-v4-pro` | DeepSeek V4 Pro (1.6T) | 200K | Ragionamento avanzato |
| `deepseek-flash` | DeepSeek V4 Flash | 200K | Veloce, economico |
| `hermes-405b` | Hermes 405B | 100K | Generale, creative |
| `gemma-12b` | Gemma 2 12B | 8K | Leggero, veloce |
| `gemma-4b` | Gemma 2 4B | 8K | Ultra-leggero |

## 💡 Cambio Modello Dinamico

Durante una sessione Claude Code, usa il comando:

```
/model <nome_modello>
```

**Esempi:**
```
/model qwen-coder-480b
/model deepseek-v4-pro
/model nvidia-coder
```

Il proxy rimane attivo in background, puoi switchare modelli senza riavviare!

## 🔧 Comandi Utili

### Verifica che il proxy sia attivo

```bash
curl http://127.0.0.1:4000/health
```

Risposta attesa:
```json
{"status":"ok"}
```

### Vedi i log del proxy

```bash
# macOS / Linux
tail -f /tmp/litellm-proxy.log

# Windows
Get-Content C:\tmp\litellm-proxy.log -Wait
```

### Riavvia il proxy

```bash
# macOS / Linux
pkill -f "litellm --config"
litellm --config ~/.claude/litellm_config.yaml --port 4000 &

# Windows
Get-Process | Where-Object { $_.ProcessName -like "*litellm*" } | Stop-Process
litellm --config $env:USERPROFILE\.claude\litellm_config.yaml --port 4000
```

### Lista modelli disponibili via API

```bash
curl http://127.0.0.1:4000/v1/models
```

## 🛠️ Installazione Manuale (Alternativa)

Se preferisci configurare manualmente:

### 1. Installa LiteLLM

```bash
pip install litellm
```

### 2. Crea la directory di configurazione

```bash
mkdir -p ~/.claude
```

### 3. Copia il file di configurazione

```bash
cp litellm_config.yaml ~/.claude/litellm_config.yaml
```

### 4. Avvia il proxy

```bash
litellm --config ~/.claude/litellm_config.yaml --port 4000
```

### 5. Avvia Claude Code

```bash
# macOS / Linux
ANTHROPIC_BASE_URL=http://127.0.0.1:4000 claude --model qwen3-122b

# Windows
$env:ANTHROPIC_BASE_URL="http://127.0.0.1:4000"
claude --model qwen3-122b
```

## ❌ Risoluzione Problemi

### Proxy non risponde dopo 30s

**Problema:** Il proxy non si avvia correttamente

**Soluzione:**
1. Controlla i log: `cat /tmp/litellm-proxy.log` (macOS/Linux) o `Get-Content C:\tmp\litellm-proxy.log` (Windows)
2. Verifica che Python sia installato: `python3 --version`
3. Reinstalla LiteLLM: `pip install --upgrade litellm`
4. Assicurati che la porta 4000 non sia occupata:
   ```bash
   # macOS/Linux
   lsof -i :4000
   
   # Windows
   netstat -ano | findstr :4000
   ```

### Errore 401 Unauthorized

**Problema:** API key non valida o mancante

**Soluzione:**
1. Verifica che le variabili d'ambiente siano impostate:
   ```bash
   # macOS/Linux
   echo $OPENROUTER_API_KEY
   echo $NVIDIA_API_KEY
   
   # Windows
   $env:OPENROUTER_API_KEY
   $env:NVIDIA_API_KEY
   ```
2. Ricontrolla le key sulle dashboard:
   - [OpenRouter Keys](https://openrouter.ai/keys)
   - [NVIDIA NIM Keys](https://build.nvidia.com/)
3. Riavvia lo shell/PowerShell dopo aver impostato le variabili

### Modello non trovato

**Problema:** Errore quando provi a usare un modello specifico

**Soluzione:**
1. Verifica il nome del modello in `litellm_config.yaml`
2. Controlla che il provider supporti quel modello:
   - NVIDIA: [NVIDIA NIM Models](https://build.nvidia.com/explore/discover)
   - OpenRouter: [OpenRouter Models](https://openrouter.ai/models)
3. Aggiorna il file di configurazione se necessario

### LiteLLM non trovato

**Problema:** Comando `litellm` non riconosciuto

**Soluzione:**
```bash
# Installa o reinstalla LiteLLM
pip install --upgrade litellm

# Verifica l'installazione
litellm --version

# Se il comando non è nella PATH, prova:
python3 -m litellm --version
```

### Errore di permessi su Windows

**Problema:** PowerShell blocca l'esecuzione dello script

**Soluzione:**
```powershell
# Esegui PowerShell come Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 📁 Struttura dei File

```
claude-litellm-config/
├── README.md                 # Questo file
├── litellm_config.yaml       # Configurazione modelli LiteLLM
├── .env.template             # Template per le API key
├── setup-linux-mac.sh        # Script di setup per macOS/Linux
├── setup-windows.ps1         # Script di setup per Windows
└── .gitignore                # File da ignorare in git
```

## 🔒 Sicurezza

- ✅ **Non condividere mai le tue API key**
- ✅ Usa variabili d'ambiente invece di hardcodare le key
- ✅ Il proxy gira in locale (localhost) - sicuro per sviluppo
- ✅ Aggiungi `.env` al `.gitignore` se usi git
- ⚠️ Non commitare mai file con API key reali su GitHub

## 💰 Costi

### NVIDIA NIM
- Alcuni modelli sono **gratuiti** con limiti
- Altri modelli sono a pagamento (pay-per-use)
- Controlla [build.nvidia.com](https://build.nvidia.com/) per dettagli sui pricing

### OpenRouter
- Pay-per-use in base al modello e ai token usati
- Piano free limitato disponibile
- Controlla [openrouter.ai/pricing](https://openrouter.ai/pricing) per dettagli

**Consiglio:** Inizia con i modelli gratuiti NVIDIA per testing, poi usa OpenRouter per modelli specifici.

## 🎓 Come Funziona l'Architettura

```
┌─────────────────┐
│  Claude Code    │
│   (CLI)         │
└────────┬────────┘
         │
         │ ANTHROPIC_BASE_URL=http://127.0.0.1:4000
         │
         ▼
┌─────────────────────────────┐
│    LiteLLM Proxy            │
│    (localhost:4000)         │
│  - Router intelligente      │
│  - Gestione modelli multipli│
└────────┬────────────────────┘
         │
         │ Switch automatico in base al modello
         │
    ┌────┴────┬───────────────┐
    │         │               │
    ▼         ▼               ▼
┌────────┐ ┌──────────┐ ┌───────────┐
│ NVIDIA │ │ OpenRouter│ │  Altri    │
│  NIM   │ │          │ │  Provider │
└────────┘ └──────────┘ └───────────┘
```

## 🤝 Contribuisci

Hai suggerimenti per nuovi modelli o miglioramenti? Apri una issue o fai una PR!

## 📚 Risorse Aggiuntive

- [Documentazione LiteLLM](https://docs.litellm.ai/)
- [NVIDIA NIM Documentation](https://docs.nvidia.com/nim/)
- [OpenRouter Documentation](https://openrouter.ai/docs)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)

## 📄 Licenza

MIT License - Usa liberamente, modifica, condividi!

## 🙏 Crediti

Configurazione creata da [Giulio Rossi](https://github.com/giuliorossi678) per uso personale e condiviso con la community.

Se ti è utile, lascia una ⭐ su GitHub!

---

**Happy coding! 🚀**
