# dotfiles

My Omarchy system config, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Each top-level directory is a "package" that mirrors the layout of `$HOME`; Stow
symlinks its contents into place.

## Layout

```
dotfiles/
├── nvim/.config/nvim/...
├── tmux/.config/tmux/tmux.conf
├── hypr/.config/hypr/...
├── omarchy/.config/omarchy/...   (branding, hooks, themes, extensions — not machine state)
├── bash/.bashrc, .bash_profile
└── ...
```

## New machine setup

```sh
sudo pacman -S --needed stow    # or: brew install stow
git clone git@github.com:<you>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` runs `stow --adopt` for every package. `--adopt` means: if a real
file already exists at the target path (e.g. a fresh Omarchy install's default
`~/.config/hypr/hyprland.conf`), Stow will pull *that* file into the repo
(overwriting the repo's copy) before symlinking — so check `git status`/`git diff`
afterwards in case a fresh machine's defaults clobbered something you meant to keep.

## Adding a new config

```sh
mkdir -p ~/dotfiles/<pkg>/<path/mirroring/home>
cp -a ~/<path> ~/dotfiles/<pkg>/<path>
stow --adopt -d ~/dotfiles -t ~ <pkg>   # converts the original into a symlink
```

## Day to day

```sh
cd ~/dotfiles
git add -A && git commit -m "..." && git push
```

On another machine: `git pull` — since everything is symlinked, changes take
effect immediately, no re-stow needed (unless you added a brand new file, in
which case run `stow -R <pkg>` to link it).

## Omarchy upgrades and this repo

Checked against Omarchy's actual update scripts (`/usr/share/omarchy/bin/omarchy-migrate`,
`omarchy-refresh-config`, and the individual scripts under `migrations/`), most
of the time an update is safe for symlinked configs:

- Most per-version migrations edit files in place with `sed --follow-symlinks`
  or plain `cp -f` — both write *through* a symlink into whatever it points
  to (your repo file), leaving the symlink itself intact. A `.bak.<suffix>`
  file appears next to it as a plain backup copy; the symlink is untouched.
- `refresh_known_config_defaults` (the mechanism that produced most
  `*.bak.<timestamp>` files you'll see) only touches a file if its content
  hash matches a known *stock* default. Anything you've actually customized
  has a different hash and gets skipped entirely.
- The one path that **does** break a symlink is `copy_config_default`, used
  for `always_copy_config_files` — a short, fixed list of "new config entry
  point" files force-copied during a major-version migration (an
  `omarchy-upgrade-to-<name>`-style jump, not routine updates). It does
  `rm -f "$target"; cp -P default "$target"`, which deletes whatever is at
  the target (symlink or not) and writes a fresh regular file. Your repo copy
  is untouched by this — it's just no longer linked from the live path.

A hook is installed at
`~/.config/omarchy/hooks/post-update.d/restow-dotfiles.hook` (tracked in the
`omarchy` package) that runs `stow -R` (plain restow, **not** `--adopt`) for
every package after each Omarchy update. Because hooks run inline in your
terminal during `omarchy-upgrade`, if a file did get unlinked this way you'll
see a stow conflict warning printed right there in the upgrade output —
nothing is silently overwritten either way. Then, by hand:

```sh
cd ~/dotfiles && stow --adopt -t ~ <pkg>   # keep Omarchy's new default (pulls it into the repo)
# or
cp ~/dotfiles/<pkg>/<path> <live path> && stow -R -t ~ <pkg>   # keep your version
```

`git diff` in `~/dotfiles` afterwards always shows exactly what, if anything,
Omarchy's update actually changed in a tracked file.

## Deliberately not tracked

- `~/.config/omarchy/shell.json` / `shell.toml` — session/runtime state, not config.
- `~/.config/btop/themes/current.theme` — Omarchy's live symlink to the active
  theme; left alone so theme switching keeps working.
- `~/.ssh/` — kept out of any dotfiles repo, private or not.
- Anything under `~/.config` that's really app cache/state (browsers, Discord,
  Signal, Obsidian's local vault settings, etc.).
