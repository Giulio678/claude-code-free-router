---
name: models
description: "Show Claude Code Free Router startup commands"
category: utility
complexity: basic
mcp-servers: []
personas: []
---

# /models

Start a new session with one of these commands:

```text
OpenRouter free:
claude-or qwen-coder        # qwen/qwen3-coder:free
claude-or qwen-next         # qwen/qwen3-next-80b-a3b-instruct:free
claude-or ring              # inclusionai/ring-2.6-1t:free (default)
claude-or nemotron-free     # nvidia/nemotron-3-super-120b-a12b:free
claude-or gpt-oss-20b       # openai/gpt-oss-20b:free
claude-or gpt-oss-120b      # openai/gpt-oss-120b:free
claude-or hermes-405b       # nousresearch/hermes-3-llama-3.1-405b:free

NVIDIA NIM:
claude-or kimi-k2.6         # moonshotai/kimi-k2.6
claude-or mistral-medium    # mistralai/mistral-medium-3.5-128b
claude-or nvidia-nano       # nvidia/nemotron-3-nano-30b-a3b
claude-or nvidia-omni       # nvidia/nemotron-3-nano-omni-30b-a3b-reasoning
claude-or nemotron-120b     # nvidia/nemotron-3-super-120b-a12b
claude-or qwen-coder-nvidia # qwen/qwen3-coder-480b-a35b-instruct
claude-or qwen-next-nvidia  # qwen/qwen3-next-80b-a3b-instruct
claude-or qwen3.5-122b      # qwen/qwen3.5-122b-a10b
```

Full model IDs also work at session start:

```text
claude-or qwen/qwen3-coder:free
claude-or qwen/qwen3-next-80b-a3b-instruct:free
claude-or inclusionai/ring-2.6-1t:free
claude-or nvidia/nemotron-3-super-120b-a12b:free
claude-or moonshotai/kimi-k2.6
claude-or mistralai/mistral-medium-3.5-128b
```
