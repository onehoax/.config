#!/usr/bin/env bash
# Claude Code status line
# Shows: model name | thinking effort | context usage
# Reads the statusLine JSON payload once from stdin and parses it with jq.
#
# Note: the current permission mode (default / plan / auto-accept / bypass) is
# intentionally NOT shown — Claude Code does not expose it in the statusLine
# stdin payload (verified against the official schema for v2.1.x).

input=$(cat)

# 1. Model name
model=$(jq -r '.model.display_name // .model.id // "unknown model"' <<< "$input")

# 2. Thinking effort level. `.effort.level` is only present for models that
#    support a reasoning-effort parameter; fall back to the thinking on/off
#    boolean, then to a dash if neither is present.
effort_level=$(jq -r '.effort.level // empty' <<< "$input")
thinking_enabled=$(jq -r '.thinking.enabled // empty' <<< "$input")
if [ -n "$effort_level" ]; then
  effort_label="${effort_level} effort"
elif [ "$thinking_enabled" = "true" ]; then
  effort_label="thinking"
elif [ "$thinking_enabled" = "false" ]; then
  effort_label="no thinking"
else
  effort_label="-"
fi

# 3. Context usage, from the pre-calculated percentage.
used_pct=$(jq -r '.context_window.used_percentage // empty' <<< "$input")
if [ -n "$used_pct" ]; then
  context_label=$(printf "ctx %.0f%%" "$used_pct")
else
  context_label="ctx n/a"
fi

# 4. Session cost so far, in USD.
cost_usd=$(jq -r '.cost.total_cost_usd // empty' <<< "$input")
if [ -n "$cost_usd" ]; then
  cost_label=$(printf "\$%.2f" "$cost_usd")
else
  cost_label=""
fi

# 5. Account email, from the config dir of the running instance
#    (CLAUDE_CONFIG_DIR points at either the "personal" or "work" profile).
email=""
if [ -n "$CLAUDE_CONFIG_DIR" ] && [ -f "$CLAUDE_CONFIG_DIR/.claude.json" ]; then
  email=$(jq -r '.oauthAccount.emailAddress // empty' "$CLAUDE_CONFIG_DIR/.claude.json")
fi

# Dim separators, since the status line is rendered with dimmed colors.
DIM=$'\033[2m'
RESET=$'\033[0m'
CYAN=$'\033[36m'

sep=" ${DIM}|${RESET} "
line="${CYAN}${model}${RESET}${sep}${effort_label}${sep}${context_label}"
[ -n "$cost_label" ] && line="${line}${sep}${cost_label}"
[ -n "$email" ] && line="${line}${sep}${email}"

printf "%s\n" "$line"
