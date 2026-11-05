# The shell

The goal: a shell that helps you while you type and starts in under 0.1 seconds. It's [Oh My Zsh](https://ohmyz.sh) with four built-in plugins, three add-on plugins and four small tools. That's all.

Check the speed any time:
```sh
time zsh -i -c exit
```
If it creeps past 0.2s, the last thing you added is the cause.

## `.zshrc` from top to bottom

| Block | What it does |
|---|---|
| `ZSH`, `ZSH_THEME`, `plugins`, `source $ZSH/oh-my-zsh.sh` | Loads Oh My Zsh with the `robbyrussell` prompt and four plugins. `mode auto` updates it quietly instead of asking every two weeks |
| `EDITOR` | Commit messages and `git rebase -i` open in VS Code. `--wait` makes git wait until you close the tab |
| `HISTSIZE`, `SAVEHIST`, `hist_ignore_all_dups` | Keeps 100,000 commands (Oh My Zsh saves 10,000) with no repeats, so searching history stays clean |
| `fnm`, `zoxide`, `fzf` lines | Turn on the three tools below |
| `alias …`, `killport` | Shortcuts, explained below |
| `claude-*` | Claude Code accounts, see the [Claude guide](claude-code.md) |
| `~/.zshrc.local` | Loaded if it exists. Put API keys and tokens there, never in this repo |
| The last three `source` lines | Add-on plugins. Syntax highlighting has to be last |

## What Oh My Zsh already does

Before adding something, check it isn't already there:

- **History** is shared between tabs instantly, and duplicates are skipped. **Commands that start with a space are never saved**, which is handy when pasting a token.
- **Type part of a command, then ↑** to cycle only through past commands that start that way.
- **Moving around:** type `..` or `...` to go up (no `cd` needed), `-` to go back, `d` to list recent folders (then type a number), and `take new-folder` to create a folder and enter it.
- **Tab completion** ignores case, so `cd doc<Tab>` finds `Documents`.

The four built-in plugins:

| Plugin | Gives you |
|---|---|
| `git` | 200+ shortcuts, see below |
| `sudo` | Press **Esc twice** to put `sudo` in front of the current or last command |
| `copypath` | `copypath` copies the current folder's path; `copypath file` copies a file's path |
| `extract` | `extract anything.zip` (or `.tar.gz`, `.7z`, …) unpacks without remembering `tar` flags |

### Git shortcuts worth learning

Each one is `g` plus the first letters of the git command. Run `alias | grep git` to see all of them.

| Alias | Runs |
|---|---|
| `gst` / `gss` | `git status` / short version |
| `gaa` / `gapa` | add everything / add piece by piece |
| `gcmsg "msg"` | `git commit -m "msg"` |
| `gc!` | amend the last commit |
| `gp` / `gl` | push / pull |
| `gsw` / `gswc name` | switch branch / create and switch |
| `gcm` | switch to `main` (or `master`, it detects which) |
| `gd` / `gds` | diff / staged diff |
| `glog` | one-line history graph |
| `grs file` | throw away changes to a file |
| `gwip` / `gunwip` | park work in a `--wip--` commit / bring it back |

A feature from start to finish: `gcm` → `gl` → `gswc my-feature` → work → `gaa` → `gcmsg "Add login"` → `gp`.

## Add-on plugins

Installed with Homebrew and loaded at the end of `.zshrc`.

- **zsh-autosuggestions** shows grey text from your history as you type. **→** or **End** accepts all of it, and **Opt-→** accepts one word.
- **zsh-syntax-highlighting** colours the command **red** if it doesn't exist and **green** if it does, before you press Enter. It works by wrapping the editing functions defined before it, so it must be loaded last.
- **zsh-you-should-use** reminds you when an alias exists: type `git status` and it tells you about `gst`. Remove it once the aliases are habit.

**→ vs Tab.** They're different features. **→** accepts the grey suggestion, which comes from what **you typed before**. **Tab** completes the current word from **everything possible**: `ec<Tab>` gives `echo`, and a second Tab lists `echo echotc echoti`.

## Tools

### fzf: fuzzy search for everything

| Keys | Does |
|---|---|
| **Ctrl-R** | Search history. Type words in any order: `push main` |
| **Ctrl-T** | Pick a file and paste its path onto the line |
| **Opt-C** | Pick a folder and `cd` into it ([needs one iTerm2 setting](#iterm2-settings)) |
| `**` then **Tab** | Fuzzy completion after any command: `code **<Tab>`, `cd src/**<Tab>`, `kill -9 **<Tab>` |

Without the `**`, Tab gives zsh's normal (non-fuzzy) completion. fzf skips `.git` and `node_modules` by default.

### zoxide: jump to folders by name

zoxide remembers every folder you `cd` into and ranks them by how often and how recently you visit.

```sh
z dotfiles      # jump to ~/.dotfiles from anywhere
z dev api       # several words: a path matching "dev" then "api"
zi              # pick from a list
z -             # previous folder
```
It only knows folders you've visited, so it's empty on day one. `zoxide query -l` shows what it has learned.

### eza: better listings

- `ll` lists everything, hidden files included, folders first, with a **git column**:

  | Shows | Meaning |
  |---|---|
  | `--` | Clean |
  | `-N` | New, not tracked yet |
  | `-M` | Modified, not staged |
  | `M-` | Staged |
  | `-I` | Ignored |

- `lt` shows a two-level tree that skips anything in `.gitignore`, such as `node_modules` and `dist`. It's a good first look at a new project.
- Plain `ls`, `l` and `la` are unchanged, so tutorials still match what you see.

### fnm: the right Node version for each project

Projects need different Node versions. fnm installs several side by side and switches automatically when you `cd`.

```sh
fnm install --lts      # newest long-term-support version
fnm install 20         # add another
fnm list               # see what's installed
fnm use 20             # switch this tab
fnm default 22         # what new tabs start with
node -v > .nvmrc       # pin the current project to your current version
```

How it picks a version:

1. **A hook runs on every `cd`.** If the folder has `.node-version`, `.nvmrc` or `package.json`, it runs `fnm use`. Other folders are ignored, which keeps `cd` fast.
2. **It reads the version** from `.node-version`, then `.nvmrc`, then `"engines": { "node": "…" }` in `package.json`. `20` means the newest 20.x you have installed. If that version is missing, fnm offers to install it.
3. **It switches instantly.** Each tab has its own shortcut (symlink) in `PATH` pointing to one installed version. Switching just re-points it, so different tabs can run different versions.

Things to know:

- **Leaving a project doesn't switch back.** Go from a Node 20 project to `~` and you stay on 20. Run `fnm use default`, or open a new tab.
- **Only the folder you land in is checked.** Opening a tab straight into `project/src` gives you the default version. Adding `--version-file-strategy=recursive` to the fnm line makes it search parent folders too.
- **Global packages belong to one version.** After switching, reinstall them (`npm i -g pnpm`).

Why fnm and not nvm: nvm loads on every new tab and adds a noticeable delay. fnm is a single fast program.

## Aliases and functions

| Command | Does |
|---|---|
| `o` | Open the current folder in Finder |
| `reload` | Restart the shell after editing `.zshrc` |
| `zshrc` | Open `.zshrc` in VS Code (the symlink means you're editing this repo) |
| `ll`, `lt` | See [eza](#eza-better-listings) |
| `brewup` | Update Homebrew and all its apps, then clean up old versions |
| `killport 3000` | Stop whatever is using a port, for "port already in use" errors |

`killport` uses `kill -9`. `kill` doesn't really kill; it sends a signal:

| Command | Signal | Effect |
|---|---|---|
| `kill PID` | 15, TERM | "Please stop." The program can save and clean up |
| **Ctrl-C** | 2, INT | Interrupt, what you use to stop `npm run dev` |
| `kill -9 PID` | 9, KILL | Removed immediately. No cleanup, so try plain `kill` first |

## iTerm2 settings

**Settings → Profiles → Keys → General → Left Option key → Esc+**

Terminals only understand characters, so shortcuts are sent as characters too. On a Mac, Option types special characters: Opt-C types `ç`. Programs like fzf expect **Alt-C**, which terminals send as **Esc** followed by **c**. Esc+ makes the left Option key send that. The right Option key still types `ç`, `é` and `©`.

It also turns on these shell shortcuts:

| Keys | Does |
|---|---|
| **Opt-.** | Paste the last word of the previous command (`mkdir app`, then `cd ` + Opt-.) |
| **Opt-B / Opt-F** | Back / forward one word |
| **Opt-D** | Delete the next word |

**Settings → Profiles → Keys → Key Mappings → Presets → Natural Text Editing** makes Opt-← and Opt-→ jump by word, like in any Mac text field.

## Left out on purpose

- **`CASE_SENSITIVE="true"`**: breaks `cd doc<Tab>` → `Documents`.
- **`ENABLE_CORRECTION="true"`**: constantly asks "correct X to Y?" about commands that were already right.
- **Duplicate aliases** like `l`, `ll` or `gaa`: Oh My Zsh already defines them.
- **nvm**: slow to load. fnm does the same job.
- **Lots of plugins**: each one adds startup time. Add one only when you'll use it weekly.
- **A fancy prompt**: [Starship](https://starship.rs) is the best upgrade if you want one.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| "You should use: ll" right after typing `ll` | The command started with a space, so it was hidden from history and from the plugin | Don't start commands with a space unless you mean to hide them |
| Opt-C types `ç` | Option still types special characters | [Esc+](#iterm2-settings) |
| `kill -9` then Tab doesn't open a picker | fzf needs its trigger | `kill -9 **` then Tab |
| Tab doesn't accept the grey text | Tab is completion | Use → |
| A setting change does nothing | The shell loaded the old file | `reload` |
