# zsh playground

Practice every feature of your new shell. Each mission says what to **do** and what you should **see**.

**Start:**
```sh
cd ~/.dotfiles/playground
./setup.sh          # builds ./sandbox (run again any time to reset)
cd sandbox
```
Keep this guide open next to your terminal.

---

## Mission 1: Autosuggestions & syntax highlighting

1. Type `echo hello world` and press Enter.
2. Type just `ec`. **See:** grey `ho hello world` appears. Press **→** to accept it (or **End**).
   - **→ vs Tab:** → accepts the grey text, which comes from your history. Tab is a different feature: it only finishes the current word from everything possible (`ec<Tab>` → `echo`, and a second Tab lists `echo echotc echoti`).
   - **Opt-→** accepts just the next word of a suggestion. This needs iTerm2 → Profiles → Keys → Presets → *Natural Text Editing*.
3. Type `ecoh` (a typo). **See:** it's **red**. Fix it to `echo` and it turns **green**.
4. Type `cd webshop` but don't press Enter yet. **See:** `webshop` is underlined because it's a real folder. Now press Enter.

## Mission 2: History

1. Type `git` and press **↑** a few times. **See:** only past commands that start with `git`.
2. Press **Ctrl-R**, then type `hello`. **See:** a searchable list of your history, with the `echo hello world` from Mission 1. Press Enter to put it on the line.
3. Type ` echo my-secret-token` with a **space first** and run it. Then press ↑ twice. **See:** that command isn't there; it was never saved.
   - Use this only for secrets. A leading space by accident also hides the command from the "you should use" plugin, which then nags you about aliases you did use.

## Mission 3: fzf (fuzzy finding)

From `sandbox/`:
1. Type `cat ` (with a space), then press **Ctrl-T** and type `needle`. **See:** `haystack/c/two/needle.md` gets picked out of ~100 files. Press Enter, then Enter again to run it.
2. Type `code haystack/**` and press **Tab**. **See:** a picker limited to that folder. Press Esc to cancel.
3. Press **Opt-C** and type `secret`. **See:** you `cd` straight into `secret-dashboard`.
   *(No result? Set iTerm2 → Settings → Profiles → Keys → Left Option key → **Esc+**.)*
4. Run `sleep 999 &` to start a dummy process. Then type `kill -9 **` and press **Tab** (don't press Enter). **See:** a fuzzy process picker. Type `sleep`, then Enter puts its number on the line, and Enter again kills it. **See:** `[1] + killed sleep 999`.
   - The `**` is fzf's signal. Without it, Tab shows zsh's plain (non-fuzzy) process list.

## Mission 4: zoxide (fast jumps)

1. `cd ~/.dotfiles/playground/sandbox/clients/acme/projects/2026/q4/secret-dashboard` (one long visit, once).
2. `cd ~` to go home.
3. `z secret`. **See:** you're back in `secret-dashboard`.
4. `z ~/.dotfiles/playground/sandbox/webshop`, then `z acme 2026`. **See:** several words narrow it down.
5. `zi`. **See:** an interactive list of every folder zoxide has learned.
6. `z -`. **See:** back to the previous folder.

## Mission 5: Better listings (eza)

In `sandbox/webshop`:
1. `ll`. **See:** folders first, hidden files like `.gitignore` included, and a **git column**. `node_modules` and `dist` show `-I` (ignored), and `src` shows `MN` (has staged and new changes inside).
2. `ll src/components`. **See:** one file in each state:
   - `--` on `Footer.jsx`: clean
   - `-N` on `Search.jsx`: new, untracked
   - `-M` on `Cart.jsx`: modified, not staged
   - `M-` on `Header.jsx`: staged
3. `lt`. **See:** a tree **without** `node_modules` and `dist`.
4. Compare with plain `ls`, which is unchanged.

## Mission 6: Node version switching (fnm)

1. `z webshop`. **See:** fnm uses Node 26 because of `.node-version`. `node -v` → v26.x
2. `cd ../legacy-api`. **See:** fnm says Node 20 isn't installed and offers to install it. Answer **y**.
3. `node server.js`. **See:** `legacy v20.x`.
4. `cd ../webshop && node -v` → back to v26. `cd -` → v20 again. It switches by itself.
5. `fnm list`. **See:** both versions, with 26 as the default.

## Mission 7: Git workflow (git plugin + "you should use")

In `sandbox/webshop`:
1. Type the long form `git status`. **See:** a reminder like *Found existing alias for "git status". You should use: "gst"*.
2. `gss`. **See:** the short status (`M ` staged, ` M` modified, `??` new).
3. `gd` shows unstaged changes; `gds` shows staged ones. Press `q` to quit.
4. `grs src/components/Cart.jsx`. **See:** that change is thrown away (`gss` again).
5. `gswc search-feature`. You're on a new branch, and the prompt shows it.
6. `gaa` then `gcmsg "Add search"`.
7. `glog`. **See:** a graph with your commit on top.
8. Make a mess: `echo wip >> README.md`, then `gwip`. **See:** a `--wip--` commit parks your work. `gunwip` brings it back as normal changes.
9. `gcm`. **See:** you're back on `main`. This repo has no remote, so `gp`/`gl` would fail here. Use them in real repos.

## Mission 8: Oh My Zsh helpers

1. `take sandbox-extra/deep/folder`. **See:** created **and** you're inside it.
2. `...` (three dots, nothing else). **See:** up two folders, with no `cd` needed.
3. `-`. **See:** back to where you were.
4. `d`. **See:** a numbered list of recent folders. Type `1` to jump to one.
5. In `sandbox/archives`: `extract photos.zip`, then `ls photos`. Run `rm -rf photos && extract photos.tar.gz`. Same result.
6. `copypath`, then paste (Cmd-V) anywhere. **See:** the full folder path.
7. `ls /var/root`. **See:** permission denied. Now press **Esc** twice. **See:** `sudo ls /var/root` is ready. Run it and enter your Mac password.

## Mission 9: Your own aliases

1. `o`. **See:** the current folder opens in Finder.
2. `python3 -m http.server 3000 &`, then open http://localhost:3000, then `killport 3000`. **See:** the page stops loading.
3. `zshrc`. **See:** your `.zshrc` opens in VS Code. Close it.
4. `reload`. **See:** the shell restarts with any changes.
5. `brewup` (takes a minute; updates all Homebrew apps).

## Mission 10: Claude accounts

1. `claude`. **See:** "Use claude-personal or claude-work".
2. `claude-personal`. **See:** yellow `●[Personal]` before your prompt after you exit, and `● Personal` in Claude's status line.
3. `claude-work`. The first time, run `/login` inside with your work account. **See:** magenta `●[Work]`.
4. `claude-switch personal` switches the tab back without starting Claude.

---

**Done?** Run `./setup.sh` to reset. The `sandbox/` folder is git-ignored, so nothing you do here ends up in the repo.
