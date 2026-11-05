# Claude Code: personal and work accounts

Two Claude accounts on one Mac, a badge in the prompt showing which one a tab is using, and a status line inside Claude Code:

```
-> dotfiles git:(main) | ● Personal | Opus 5.5 | [██              ] 143K / 1000K tokens
```

## How two accounts work

Claude Code keeps everything (login, settings, history) in `~/.claude`. If the `CLAUDE_CONFIG_DIR` environment variable points somewhere else, it uses that folder instead, with its own login. So:

| Account | Folder | `CLAUDE_CONFIG_DIR` |
|---|---|---|
| Personal | `~/.claude` | not set |
| Work | `~/.claude-work` | `~/.claude-work` |

## Commands

| Command | Does |
|---|---|
| `claude-personal` | Switch this tab to personal and start Claude |
| `claude-work` | Switch this tab to work and start Claude |
| `claude-switch personal` / `work` | Switch without starting Claude |
| `claude` | Prints a reminder to pick one, so you never start on the wrong account by accident |

Arguments pass through: `claude-work --continue` works.

The first time you run `claude-work`, type `/login` inside it and sign in with the work account.

The choice **sticks for the tab**, because `claude-switch` exports the variable into the shell. After `claude-work`, the tab stays on work until you switch back. Other tabs aren't affected.

## Why functions, not aliases

The obvious version breaks:

```zsh
alias claude='echo "Use claude-personal or claude-work"'
alias claude-work='claude-switch work && claude'
```
zsh expands aliases inside aliases, so `claude-work` ends up running the reminder instead of Claude. The functions use `command claude`, which skips aliases and functions and runs the real program. Functions also pass arguments through cleanly with `"$@"`.

## The prompt badge

```zsh
PROMPT='${CLAUDE_PROMPT_INFO:+$CLAUDE_PROMPT_INFO }'$PROMPT
```
- **Single quotes** keep `${…}` unexpanded, so zsh re-reads it every time it draws the prompt. Oh My Zsh turns on `PROMPT_SUBST`, which allows that.
- **`${VAR:+text}`** means "`text` if `VAR` is set, otherwise nothing", so tabs where you haven't picked an account show no badge and no stray space.
- **`%F{yellow}…%f`** inside the variable is zsh's prompt colour code.
- It has to come after Oh My Zsh loads, because the theme sets `PROMPT` itself.

## The status line

Claude Code can run a command of your choice and show what it prints at the bottom of the screen. The setting in `settings.json`:

```json
"statusLine": { "type": "command", "command": "bash ~/.dotfiles/claude/statusline.sh" }
```

Each time the conversation updates, Claude Code sends the command details about the session as JSON on stdin:

```json
{
  "model": { "id": "claude-opus-5-5", "display_name": "Opus 5.5" },
  "workspace": { "current_dir": "/Users/you/.dotfiles", "project_dir": "/Users/you/.dotfiles" },
  "context_window": {
    "context_window_size": 1000000,
    "current_usage": {
      "input_tokens": 2,
      "cache_creation_input_tokens": 1219,
      "cache_read_input_tokens": 139991
    }
  }
}
```

[`statusline.sh`](../claude/statusline.sh) reads it with [`jq`](https://jqlang.org), a small JSON tool (`jq -r '.model.display_name'` prints `Opus 5.5`), and prints one coloured line:

| Part | From |
|---|---|
| `-> dotfiles` | last part of `workspace.current_dir` |
| `git:(main)` | `git` run inside that folder |
| `● Personal` / `● Work` | whether `CLAUDE_CONFIG_DIR` is set. Claude Code passes its environment to the script |
| `Opus 5.5` | `model.id`, so any model family works |
| bar and tokens | the three token counts added up, out of `context_window_size` |

Try it without Claude:
```sh
echo '{"workspace":{"current_dir":"'"$PWD"'"},"model":{"display_name":"Opus 5.5","id":"claude-opus-5-5"}}' | bash ~/.dotfiles/claude/statusline.sh
```
The token bar only appears with real usage data.

To change it, edit `statusline.sh`. Claude Code picks up the change on the next update, with no restart.

## Settings are separate per account

Each folder has its own `settings.json`. `install.sh`:
- creates `~/.claude-work/settings.json` as a copy of the personal one if it doesn't exist,
- adds the `statusLine` entry to both, leaving everything else as it is,
- turns off attribution in both, so commits and PRs Claude writes carry no `Co-Authored-By` line or "Generated with Claude Code" footer:
  ```json
  "attribution": { "commit": "", "pr": "", "sessionUrl": false }
  ```

Other tools (iTerm2's notification hooks, for example) write to these files, which is why `settings.json` isn't in the repo. To change a setting for both accounts, change it in both files.
