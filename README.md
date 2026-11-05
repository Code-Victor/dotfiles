# dotfiles

My macOS terminal setup: a fast, minimal zsh, two GitHub accounts on one Mac, and Claude Code with separate personal and work logins.

Every piece has a guide that explains **how it works**, not only what to paste. Read them, try the playground, then take what you need.

## Guides

| Guide | You'll learn |
|---|---|
| [The shell](guides/zsh.md) | Oh My Zsh without the bloat, fuzzy search, jumping between folders, per-project Node versions, and the keys that make it all fast |
| [Two GitHub accounts](guides/github-multiple-accounts.md) | SSH keys, picking the right account by folder, and why "who logs in" and "who made the commit" are two separate things |
| [Claude Code](guides/claude-code.md) | Separate personal and work accounts, a prompt badge, and a custom status line |
| [Playground](playground/README.md) | Ten hands-on missions to practise everything above |

## What's inside

| Path | Linked to | What it is |
|---|---|---|
| `zsh/.zshrc` | `~/.zshrc` | Shell config |
| `git/.gitconfig` | `~/.gitconfig` | Git defaults and the account rules |
| `git/.gitignore_global` | `~/.gitignore_global` | Files no repo should ever commit |
| `ssh/config` | `~/.ssh/config` | Which SSH key goes with which GitHub address |
| `claude/statusline.sh` | used by Claude Code | Status line: folder, branch, account, model, context used |
| `Brewfile` | | CLI tools this setup needs |
| `Brewfile.apps` | | My apps (optional) |
| `install.sh` | | Sets everything up on a Mac |
| `playground/` | | Practice sandbox |

The config files are **symlinked**: `~/.zshrc` points into this repo. Edit either one and you're editing the same file, so `git status` here shows every change you've made.

## Install on a new Mac

1. Install [Homebrew](https://brew.sh). It also installs git.
2. Clone and run:
   ```sh
   git clone https://github.com/Code-Victor/dotfiles.git ~/.dotfiles
   ~/.dotfiles/install.sh
   ```
3. The script asks for your name and email(s), creates SSH keys, and copies each one so you can add it at https://github.com/settings/ssh/new.
4. Restart the terminal and run `ssh -T git@github.com`.
5. Optional: `brew bundle --file ~/.dotfiles/Brewfile.apps` installs my apps.

Running `install.sh` again is safe. It skips anything already set up, and any file it replaces is moved to `~/.dotfiles-backup/` first.

Until your SSH key is added to GitHub, `git pull` and `brew update` fail with "Permission denied (publickey)". The git config sends all GitHub traffic over SSH ([why](guides/github-multiple-accounts.md#https-links-still-use-your-keys)).

## Using it yourself

Fork it, then change the parts that are mine:

- **Folder and nickname for the second account:** `~/Documents/dev/alu` and `github-school`, in `git/.gitconfig` and `ssh/config`.
- **Claude accounts:** the `claude-*` functions in `zsh/.zshrc`. Delete them if you only have one account.
- **Apps:** `Brewfile.apps`.

Your name and emails are never in the repo. `install.sh` writes them to `~/.gitconfig.local` and `~/.gitconfig-school`, which only exist on your Mac.

## Not in this repo, on purpose

| File | Why |
|---|---|
| `~/.gitconfig.local`, `~/.gitconfig-school` | Your name and emails |
| `~/.zshrc.local` | API keys, tokens and machine-only settings. `.zshrc` loads it if it exists |
| `~/.ssh/id_ed25519_*` | Private keys never leave your machine |
| `~/.claude/settings.json` | Other tools write to it. `install.sh` only adds the status line |

## Credits

- [w3cj/dotfiles](https://github.com/w3cj/dotfiles): the starting point.
- [Multiple SSH keys gist](https://gist.github.com/alejandro-martin/aabe88cf15871121e076f66b65306610): the classic approach to two accounts, which the GitHub guide builds on.
