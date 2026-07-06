---
name: models
description: "Show Claude Code Free Router startup commands and /model aliases"
category: utility
complexity: basic
mcp-servers: []
personas: []
---

# /models

Default startup:

```text
claude-or              # poolside/laguna-xs-2.1:free
```

OpenRouter free:

```text
claude-or laguna-xs       # poolside/laguna-xs-2.1:free (default)
claude-or north-code      # cohere/north-mini-code:free
claude-or laguna-m        # poolside/laguna-m.1:free
claude-or nemotron-free   # nvidia/nemotron-3-super-120b-a12b:free
claude-or router          # openrouter/free
```

Legacy OpenRouter free:

```text
claude-or qwen-coder      # qwen/qwen3-coder:free
claude-or qwen-next       # qwen/qwen3-next-80b-a3b-instruct:free
claude-or gpt-oss-20b     # openai/gpt-oss-20b:free
claude-or gpt-oss-120b    # openai/gpt-oss-120b:free
claude-or hermes-405b     # nousresearch/hermes-3-llama-3.1-405b:free
```

NVIDIA NIM:

```text
claude-or kimi-k2.6         # moonshotai/kimi-k2.6
claude-or mistral-medium    # mistralai/mistral-medium-3.5-128b
claude-or nvidia-nano       # nvidia/nemotron-3-nano-30b-a3b
claude-or nvidia-omni       # nvidia/nemotron-3-nano-omni-30b-a3b-reasoning
claude-or nemotron-120b     # nvidia/nemotron-3-super-120b-a12b
claude-or qwen-coder-nvidia # qwen/qwen3-coder-480b-a35b-instruct
claude-or qwen-next-nvidia  # qwen/qwen3-next-80b-a3b-instruct
claude-or qwen3.5-122b      # qwen/qwen3.5-122b-a10b
```

Inside Claude Code:

```text
/model sonnet  -> poolside/laguna-xs-2.1:free
/model opus    -> poolside/laguna-m.1:free
/model haiku   -> cohere/north-mini-code:free
```

Full model IDs also work:

```text
claude-or poolside/laguna-xs-2.1:free
claude-or cohere/north-mini-code:free
claude-or poolside/laguna-m.1:free
claude-or nvidia/nemotron-3-super-120b-a12b:free
claude-or openrouter/free
claude-or moonshotai/kimi-k2.6
claude-or mistralai/mistral-medium-3.5-128b
```

Do not use `inclusionai/ring-2.6-1t:free`; it is a removed/stale OpenRouter model in this setup.
