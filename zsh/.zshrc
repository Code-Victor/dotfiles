export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
zstyle ':omz:update' mode auto
plugins=(git sudo copypath extract)
source $ZSH/oh-my-zsh.sh

export EDITOR="code --wait"
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_all_dups

eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)

alias o="open ."
alias reload="exec zsh"
alias zshrc="code ~/.zshrc"
alias ll="eza -la --git --group-directories-first"
alias lt="eza --tree --level=2 --git-ignore"
alias brewup="brew update && brew upgrade && brew cleanup"

killport() { lsof -ti tcp:"$1" | xargs kill -9; }

gh() {
  local user=$(git config github.user)
  [[ $PWD/ == ~/Documents/dev/alu/* ]] && user=$(git config --file ~/.gitconfig-school github.user)
  GH_TOKEN=${user:+$(command gh auth token -u $user 2>/dev/null)} command gh "$@"
}

claude-switch() {
  case $1 in
    personal)
      unset CLAUDE_CONFIG_DIR
      export CLAUDE_PROMPT_INFO="%F{yellow}●[Personal]%f"
      echo "Switched to personal account" ;;
    work)
      mkdir -p "$HOME/.claude-work"
      export CLAUDE_CONFIG_DIR="$HOME/.claude-work"
      export CLAUDE_PROMPT_INFO="%F{magenta}●[Work]%f"
      echo "Switched to work account" ;;
    *)
      echo "Usage: claude-switch [personal|work]"; return 1 ;;
  esac
}
claude-personal() { claude-switch personal && command claude "$@"; }
claude-work()     { claude-switch work && command claude "$@"; }
claude()          { echo "Use claude-personal or claude-work"; return 1; }
PROMPT='${CLAUDE_PROMPT_INFO:+$CLAUDE_PROMPT_INFO }'$PROMPT

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

source $HOMEBREW_PREFIX/share/zsh-you-should-use/you-should-use.plugin.zsh
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# must be sourced last
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
