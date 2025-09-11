{pkgs, ...}:
with pkgs; [
  # AI Agents
  amp
  claude-code
  codex
  crush
  cursor-agent
  forge
  gemini-cli
  goose-cli
  groq-code-cli
  opencode
  qwen-code

  # General Tools
  curl
  git
  jq
  bat
  ripgrep
  ast-grep
  vim
]
