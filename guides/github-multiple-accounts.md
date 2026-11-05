# Two GitHub accounts on one Mac

I have a **personal** account (Code-Victor) and a **school** account (HelloWorldVictor). With this setup, git uses the right one automatically: everything inside `~/Documents/dev/alu/` is school, everything else is personal. I paste clone links exactly as GitHub gives them.

## Git answers two separate questions

| Question | Decided by | Used for |
|---|---|---|
| **Who is logging in?** Can I push here? | The **SSH key** | clone, pull, push |
| **Whose name goes on the commit?** | `user.name` / `user.email` | `git commit`, which never touches the network |

Most multi-account problems come from fixing one and forgetting the other. You can push successfully as your school account while the commits still carry your personal email, and GitHub then credits them to the wrong profile. This setup handles both.

## Why it needs setting up

Everyone connects to GitHub as the same user, `git@github.com`. GitHub tells accounts apart **only by the SSH key** you show it. With two keys, something has to decide which key to show.

The classic fix ([this gist](https://gist.github.com/alejandro-martin/aabe88cf15871121e076f66b65306610)) gives each account a nickname like `github-school` and makes you edit every clone URL to use it. Forget once and you push as the wrong account. Here, git decides by **folder** instead.

## Setup

`install.sh` does steps 1, 2, 5 and 6 for you. They're written out so you know what it did.

### 1. One key per account

```sh
ssh-keygen -t ed25519 -C "personal@example.com" -f ~/.ssh/id_ed25519_personal
ssh-keygen -t ed25519 -C "school@example.com"   -f ~/.ssh/id_ed25519_school
```
- `ed25519` is the modern key type: shorter and stronger than the RSA keys older guides use.
- `-C` is only a label, so you can tell the keys apart later.
- Each command creates two files. `id_ed25519_personal` is **private** and never leaves your Mac. `id_ed25519_personal.pub` is **public**, and you give it to GitHub.
- It asks for a passphrase. With one, a stolen key file is useless on its own. Without one, rely on FileVault disk encryption.

### 2. Tell SSH which key goes with which address

[`ssh/config`](../ssh/config), linked to `~/.ssh/config`:

```
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_personal
  IdentitiesOnly yes

Host github-school
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_school
  IdentitiesOnly yes
```
- **`Host`** is the address you type. `github.com` matches normal GitHub links, so the personal key is used by default.
- **`HostName`** is the real server. `github-school` isn't a website; it's a nickname that connects to github.com but shows the school key. It's a fallback for school repos that live outside the school folder.
- **`User git`**: everyone logs in as `git`. The key is what identifies you.
- **`IdentitiesOnly yes`** offers **only** the listed key. Without it, SSH may try every key it knows, and if the school key goes first, GitHub logs you in as the school account. That causes confusing "Repository not found" errors. Many guides leave this out.

### 3. Add each public key to its account

```sh
pbcopy < ~/.ssh/id_ed25519_personal.pub
```
Signed in as the **personal** account, go to https://github.com/settings/ssh/new, paste, and save. Then sign in as the **school** account (a private window is easiest) and do the same with `id_ed25519_school.pub`.

### 4. Test

```sh
ssh -T git@github.com      # Hi Code-Victor! …
ssh -T git@github-school   # Hi HelloWorldVictor! …
```
The first connection asks you to trust GitHub's server. GitHub [publishes its fingerprints](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints); the ed25519 one is `SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU`. `install.sh` writes the known key directly, so you never see the question.

### 5. Choose the identity by folder

[`git/.gitconfig`](../git/.gitconfig) starts with:

```ini
[include]
	path = ~/.gitconfig.local

[includeIf "gitdir:~/Documents/dev/alu/"]
	path = ~/.gitconfig-school
```

- **`[include]`** loads your personal name and email from `~/.gitconfig.local`. That file isn't in the repo, so your email isn't published:
  ```ini
  [user]
  	name = Your Name
  	email = personal@example.com
  ```
- **`[includeIf "gitdir:…"]`** loads `~/.gitconfig-school` **only when the repo is inside that folder**. The trailing `/` means "this folder and everything under it". It's read after the personal file, so its values win:
  ```ini
  [user]
  	name = Your Name
  	email = school@example.com
  [core]
  	sshCommand = ssh -i ~/.ssh/id_ed25519_school -o IdentitiesOnly=yes
  ```
- **`user.email`** answers the commit question.
- **`sshCommand`** answers the login question. Inside the school folder the link is still plain `github.com`, which `~/.ssh/config` maps to the personal key. SSH can't see folders, but git can. `-i` puts the school key first, so GitHub sees the school account.

This works during `git clone` too (tested with git 2.50), so you can clone into the school folder with the normal link.

### 6. Or by remote address

The rest of the include rules cover school repos **outside** the school folder that were cloned with the nickname:

```ini
[includeIf "hasconfig:remote.*.url:git@github-school:**/**"]
	path = ~/.gitconfig-school
[includeIf "hasconfig:remote.*.url:github-school:**/**"]
	path = ~/.gitconfig-school
[includeIf "hasconfig:remote.*.url:ssh://git@github-school/**"]
	path = ~/.gitconfig-school
```
`hasconfig` means "if any remote's link matches". There are three rules because the same address can be written three ways. It needs git 2.36 or newer.

The trade-off: git can only check *any* remote, not just `origin`. If a personal repo has a school repo added as a second remote, its commits get your school email. Fix that repo with `git config user.email personal@example.com`; a repo's own setting always wins.

## What happens when you push

Inside `~/Documents/dev/alu/project`:
1. Git reads `~/.gitconfig` and loads `~/.gitconfig.local` (personal).
2. The folder matches, so it loads `~/.gitconfig-school`, which overrides the name, email and SSH command.
3. Commits get the school email, and the push uses the school key. GitHub sees HelloWorldVictor.

Anywhere else, step 2 is skipped. Commits get the personal email, plain `ssh` reads `~/.ssh/config`, and GitHub sees Code-Victor.

## Everyday use

```sh
cd ~/Documents/dev/alu
git clone git@github.com:HelloWorldVictor/assignment.git    # school

cd ~/Documents/dev
git clone https://github.com/Code-Victor/my-app.git         # personal
```
- **Check any repo:** `git config user.email`.
- **School repo in the wrong folder?** A private one fails with "Repository not found". Move it into the school folder; the identity follows the folder, with nothing to reconfigure.
- **Personal repo inside the school folder** would push as the school account. Keep them apart.

## HTTPS links still use your keys

```ini
[url "git@github.com:"]
	insteadOf = https://github.com/
```
Git rewrites any `https://github.com/…` link to SSH before using it. HTTPS ignores your keys and asks for a token instead, and then none of the account rules apply. With this rewrite, a link copied from GitHub's default HTTPS tab still goes through your keys.

The side effect: every GitHub download goes over SSH, including `brew update` and Oh My Zsh updates. That's fine once your key is on GitHub, but on a fresh Mac they fail until it is.

## The GitHub CLI (`gh`)

`gh` doesn't use SSH keys. It talks to GitHub's API with a login token, so it needs its own setup. It can store several accounts, but it uses only one at a time and has no folder rules.

### Log in to both accounts

```sh
gh auth login --hostname github.com --git-protocol ssh --skip-ssh-key --web
```
Run it once per account. It shows a code and opens github.com/login/device, and you approve it **in a browser signed in to that account**. A private window makes the second account easy.

- `--git-protocol ssh` makes `gh repo clone` use SSH, so your keys and folder rules apply. It also stops `gh` from adding itself to `~/.gitconfig` as a password helper.
- `--skip-ssh-key` stops it from uploading a new key, because you already added yours.

`gh auth status` lists both accounts. `gh auth switch` changes the active one by hand.

### Picking the account automatically

Each identity file also records the GitHub username:

```ini
# ~/.gitconfig.local                # ~/.gitconfig-school
[github]                            [github]
	user = Code-Victor                	user = HelloWorldVictor
```
So `git config github.user` already gives the right answer, using the same folder and remote rules as the email. `.zshrc` wraps `gh` to use it:

```zsh
gh() {
  local user=$(git config github.user)
  [[ $PWD/ == ~/Documents/dev/alu/* ]] && user=$(git config --file ~/.gitconfig-school github.user)
  GH_TOKEN=${user:+$(command gh auth token -u $user 2>/dev/null)} command gh "$@"
}
```
- `gh auth token -u user` prints that account's stored token, and `GH_TOKEN` makes `gh` use it for this one command.
- The folder check covers places that aren't a repo yet, like `~/Documents/dev/alu` itself, where you'd run `gh repo clone` or `gh repo create`.
- `command gh` runs the real program instead of calling the function again.

```sh
cd ~/Documents/dev/alu && gh api user -q .login   # HelloWorldVictor
cd ~ && gh api user -q .login                     # Code-Victor
```

## Other git defaults in `.gitconfig`

| Setting | Effect |
|---|---|
| `init.defaultBranch = main` | New repos start on `main`, matching GitHub |
| `push.autoSetupRemote = true` | The first push of a new branch works without `-u origin branch` |
| `pull.rebase = true` | Pulling puts your commits on top of the new ones, with no "Merge branch 'main'" commits |
| `fetch.prune = true` | Branches deleted on GitHub disappear locally too |
| `core.excludesFile` | Applies [`.gitignore_global`](../git/.gitignore_global) to every repo: `.DS_Store`, `.env.local`, logs, editor folders |

## Gotchas

- **Commits don't show your avatar.** The commit email must be listed under Settings → Emails on that account. If you'd rather not publish your email, use the private `ID+username@users.noreply.github.com` address shown on that page.
- **Fix the author of your last commit** after correcting the email: `git commit --amend --reset-author --no-edit`.
- **"Permission denied (publickey)"** means the key isn't on GitHub, or the wrong key was offered. `ssh -T git@github.com` shows which account you're getting.
