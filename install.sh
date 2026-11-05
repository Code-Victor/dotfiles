#!/bin/zsh
set -e
DOTFILES=${0:A:h}
backup=~/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)

step() { print -P "\n%F{cyan}==>%f $1"; }

link() {
  local src=$DOTFILES/$1 dest=$2
  [[ $(readlink $dest) == $src ]] && return
  if [[ -e $dest || -L $dest ]]; then
    mkdir -p $backup && mv $dest $backup/ && echo "backed up $dest to $backup"
  fi
  ln -s $src $dest && echo "linked $dest"
}

new_key() {
  local key=~/.ssh/id_ed25519_$1
  [[ -f $key ]] && return
  ssh-keygen -t ed25519 -C "$2" -f $key
  pbcopy < $key.pub
  echo "Copied $key.pub. Add it to your $1 GitHub account: https://github.com/settings/ssh/new"
  read "?Press Enter once it's added "
}

for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  [[ -x $b ]] && eval "$($b shellenv)" && break
done
if ! command -v brew >/dev/null; then
  echo "Install Homebrew first: https://brew.sh"
  exit 1
fi

step "Homebrew packages"
grep -qs "brew shellenv" ~/.zprofile || echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.zprofile
brew bundle --file=$DOTFILES/Brewfile

step "Oh My Zsh"
if [[ ! -d ~/.oh-my-zsh ]]; then
  ZSH=$HOME/.oh-my-zsh sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
else
  echo "already installed"
fi

step "Git identity"
if [[ ! -f ~/.gitconfig.local ]]; then
  read "name?Your name for commits: "
  read "email?Personal GitHub email: "
  git config --file ~/.gitconfig.local user.name "$name"
  git config --file ~/.gitconfig.local user.email "$email"
fi
if [[ ! -f ~/.gitconfig-school ]]; then
  read "school_email?School GitHub email (Enter to skip): "
  if [[ -n $school_email ]]; then
    git config --file ~/.gitconfig-school user.name "$(git config --file ~/.gitconfig.local user.name)"
    git config --file ~/.gitconfig-school user.email "$school_email"
    git config --file ~/.gitconfig-school core.sshCommand "ssh -i ~/.ssh/id_ed25519_school -o IdentitiesOnly=yes"
  fi
fi
echo "personal: $(git config --file ~/.gitconfig.local user.email)"
[[ -f ~/.gitconfig-school ]] && echo "school:   $(git config --file ~/.gitconfig-school user.email)"

step "SSH keys"
mkdir -p -m 700 ~/.ssh
grep -qs "^github.com ssh-ed25519" ~/.ssh/known_hosts ||
  echo "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl" >> ~/.ssh/known_hosts
new_key personal "$(git config --file ~/.gitconfig.local user.email)"
[[ -f ~/.gitconfig-school ]] && new_key school "$(git config --file ~/.gitconfig-school user.email)"
ls ~/.ssh/id_ed25519_*.pub

step "Linking config files"
link zsh/.zshrc ~/.zshrc
link git/.gitconfig ~/.gitconfig
link git/.gitignore_global ~/.gitignore_global
link ssh/config ~/.ssh/config

step "Claude Code status line"
mkdir -p ~/.claude ~/.claude-work
[[ -f ~/.claude/settings.json ]] || echo '{}' > ~/.claude/settings.json
[[ -f ~/.claude-work/settings.json ]] || cp ~/.claude/settings.json ~/.claude-work/settings.json
for f in ~/.claude/settings.json ~/.claude-work/settings.json; do
  jq --arg cmd "bash $DOTFILES/claude/statusline.sh" '.statusLine = {type: "command", command: $cmd}' $f > $f.tmp
  mv $f.tmp $f
  echo "updated $f"
done

step "Node.js"
eval "$(fnm env --shell zsh)"
fnm list | grep -q default || fnm install --lts
fnm list

step "Done. Restart your terminal, then check both accounts:"
echo "  ssh -T git@github.com"
[[ -f ~/.gitconfig-school ]] && echo "  ssh -T git@github-school"
echo "iTerm2: Settings → Profiles → Keys → Left Option key → Esc+"
