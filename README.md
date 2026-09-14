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

Omarchy's own upgrade process (`omarchy-upgrade`) directly overwrites several
config files with new defaults (you'll see it leave behind
`*.omarchy-upgrade-*.bak` files when it does). If one of the files it touches
is a Stow symlink, the upgrade can replace the symlink with a brand new real
file, silently "unstowing" it.

A hook is installed at
`~/.config/omarchy/hooks/post-update.d/restow-dotfiles.hook` (tracked in the
`omarchy` package) that re-runs `stow --adopt` for every package after each
Omarchy update. It uses `--adopt`, so it always keeps whatever ended up on
disk (Omarchy's new default, if it changed something) and pulls it into the
repo. After an update, run:

```sh
cd ~/dotfiles && git status
```

to see whether Omarchy changed anything you care about, and `git diff` /
`git checkout -- <file>` to decide whether to keep the new default or restore
your version.

## Deliberately not tracked

- `~/.config/omarchy/shell.json` / `shell.toml` — session/runtime state, not config.
- `~/.config/btop/themes/current.theme` — Omarchy's live symlink to the active
  theme; left alone so theme switching keeps working.
- `~/.ssh/` — kept out of any dotfiles repo, private or not.
- Anything under `~/.config` that's really app cache/state (browsers, Discord,
  Signal, Obsidian's local vault settings, etc.).
