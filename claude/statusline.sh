#!/bin/bash

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
model_id=$(echo "$input" | jq -r '.model.id')

cd "$cwd" 2>/dev/null || true

GREEN='\033[32m'; CYAN='\033[36m'; MAGENTA='\033[35m'
YELLOW='\033[33m'; DIM='\033[2m'; RESET='\033[0m'

printf "${GREEN}-> %s${RESET}" "$(basename "$cwd")"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  printf " ${CYAN}git:${RESET}${DIM}(${RESET}${MAGENTA}%s${RESET}${DIM})${RESET}" "$branch"
fi

if [ -n "${CLAUDE_CONFIG_DIR}" ]; then
  printf " ${DIM}|${RESET} ${MAGENTA}● Work${RESET}"
else
  printf " ${DIM}|${RESET} ${YELLOW}● Personal${RESET}"
fi

short_model="$model"
for family in Opus Sonnet Haiku Fable; do
  lower=$(echo "$family" | tr 'A-Z' 'a-z')
  if [[ "$model_id" =~ $lower-([0-9]+-[0-9]+) ]]; then
    short_model="$family ${BASH_REMATCH[1]//-/.}"; break
  fi
done
printf " ${DIM}|${RESET} %s" "$short_model"

usage=$(echo "$input" | jq '.context_window.current_usage')
size=$(echo "$input" | jq '.context_window.context_window_size // 0')
if [ "$usage" != "null" ] && [ "$size" -gt 0 ]; then
  current=$(echo "$usage" | jq '(.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)')
  pct=$((current * 100 / size)); [ "$pct" -gt 100 ] && pct=100
  bar_width=16; filled=$((pct * bar_width / 100))
  printf " ${DIM}|${RESET} ${GREEN}["
  for ((i=0; i<bar_width; i++)); do
    if [ $i -lt $filled ]; then printf "█"; else printf " "; fi
  done
  printf "]${RESET} ${GREEN}%dK / %dK tokens${RESET}" "$((current / 1000))" "$((size / 1000))"
fi
printf "\n"
