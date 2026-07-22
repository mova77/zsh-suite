# zsh-suite

**Modular Zsh productivity suite** — a small set of everyday helpers, tab completions, and a flicker-free startup banner that scales to your terminal window.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-zsh-blue.svg)](#requirements)

| | |
|---|---|
| **Install path** | `~/.zsh-suite` |
| **Entry point** | `loader.zsh` |
| **Helpers** | 30+ aliases & functions |
| **Prompt** | Works with Starship / Oh My Zsh (suite does not own the prompt) |

---

## Features

- **Modular layout** — aliases, completions, labels, and graphics live in separate files; one loader wires them together
- **Flicker-free banner** — never calls `clear`; animates with cursor-up + line erase/overwrite only
- **Window-aware art** — torus or Mandelbrot ASCII art scales to `$COLUMNS` / `$LINES`
- **Interesting fractals** — random zoom into seahorse valley, spirals, tendrils, lightning, etc. (not the boring solid cardioid center)
- **Double-load guard** — safe if both `.zprofile` and `.zshrc` might source something
- **Oh My Zsh friendly** — unaliases conflicting git plugin names (`gco`, `gclean`) before redefining functions
- **Optional tools** — Docker / kubectl / `gh` / `jq` / Homebrew helpers degrade gracefully when missing

---

## Requirements

| Requirement | Notes |
|-------------|--------|
| **zsh** | 5.x+ recommended |
| **Interactive shell** | Banner only runs interactively on a TTY |
| **Optional** | `jq`, `docker`, `kubectl`, `gh`, `brew`, `python3` (for `serve`), `npm` (for `nr`/`ni`) |
| **Linux clipboard** | `xclip` if not on macOS |

---

## Install

### Clone

```bash
git clone https://github.com/mova77/zsh-suite.git ~/.zsh-suite
```

### Wire into `~/.zshrc`

Add near the **end** of your `~/.zshrc` (after Oh My Zsh / `compinit` if you use them):

```zsh
# Modular Zsh Productivity Suite
[[ -f "$HOME/.zsh-suite/loader.zsh" ]] && source "$HOME/.zsh-suite/loader.zsh"
```

If you use **Starship**, keep its init **after** the suite so the prompt wins:

```zsh
[[ -f "$HOME/.zsh-suite/loader.zsh" ]] && source "$HOME/.zsh-suite/loader.zsh"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
```

### Reload

```zsh
exec zsh
# or open a new terminal tab
```

### Do not double-load

Source **only** `loader.zsh` (or only `suite.zsh`). Do not also source a legacy monolithic script that calls `clear` every animation frame.

---

## Quick start

```zsh
suite-list          # full cheat sheet of every helper
killport 3000       # free a stuck dev port
nr dev              # npm run dev
gpr                 # push branch + open GitHub PR
dps                 # pretty docker ps
json package.json   # pretty-print JSON
note "shipped gpr"  # append to ~/notes/YYYY-MM-DD.md
```

---

## Repository layout

```text
~/.zsh-suite/
├── loader.zsh          # Orchestrator + banner (source this)
├── aliases.zsh         # All helpers
├── completions.zsh     # Tab completions
├── labels.zsh          # suite-list text + labels array
├── engine.zsh          # Term size, art scale, Mandelbrot views
├── suite.zsh           # Legacy entry → loader.zsh
├── README.md
└── config/             # Snapshots of related home configs (not live)
    ├── zshrc
    ├── zprofile
    ├── zsh_prod_suite
    └── ghostty.config.ghostty
```

### Load order

1. `aliases.zsh` — define functions/aliases  
2. `completions.zsh` — register `compdef`s  
3. `labels.zsh` — cheat-sheet data + `suite-list`  
4. `engine.zsh` — art + geometry helpers  
5. Banner (interactive TTY only)

---

## Startup banner

On interactive shells the suite paints:

1. **Art once** — random torus *or* a random interesting Mandelbrot view  
2. **Progress footer** — rewritten in place (`\e[nA` + `\r\e[2K`), **never** full-screen clear  
3. **Adaptive layout**
   - **Wide + tall** — optional full helper list  
   - **Normal** — category summary (System / DevBox / GitOps / Containers / K8s / NetUtils)  
   - **Narrow** — one-line status  

A dim caption under the art shows which view you got, e.g. `mandelbrot · seahorse`.

### Environment variables

| Variable | Effect |
|----------|--------|
| `ZSH_SUITE_QUIET=1` | Skip the banner entirely (helpers still load) |
| `ZSH_SUITE_FORCE=1` | Force banner even when stdout is not a TTY (testing) |
| `NOTE_DIR` | Override notes directory for `note` (default: `~/notes`) |

Examples:

```zsh
# permanently quiet banner
echo 'export ZSH_SUITE_QUIET=1' >> ~/.zshrc

# one-off quiet session
ZSH_SUITE_QUIET=1 zsh
```

### Mandelbrot views

When fractal art is chosen, one of these pre-baked viewpoints is selected at random:

| Name | Region (approx.) |
|------|------------------|
| `seahorse` | Seahorse valley deep zoom |
| `spiral` | Filament spiral near −0.75 |
| `juliaish` | Edge filaments / mini-bulbs |
| `feather` | Boundary feathering |
| `lightning` | Dendrite / lightning structure |
| `valley` | Wider seahorse valley |
| `tendril` | Northern antenna tendril |
| `double_sp` | Double spiral |

Art is **pre-rendered** (no Python at shell start) and **scaled** at runtime to the window.

---

## Command reference

Run `suite-list` anytime for the in-shell version of this list.

### System

| Command | Description |
|---------|-------------|
| `..` `...` `....` `.....` | Jump up 1–4 directories |
| `mkd <dir>` | `mkdir -p` and `cd` into it |
| `ducks` | Top 10 disk hogs in current directory |
| `clip` | Copy stdin → clipboard |
| `paste` | Print clipboard |
| `cpfile <file>` | Copy file contents → clipboard |
| `cls` | Clear screen **and** scrollback (manual only; banner never uses this) |
| `pathls` | Print `$PATH` one entry per line |
| `killport <port>` | Kill process(es) listening on TCP port |
| `note [text]` | Append timestamped note to `~/notes/YYYY-MM-DD.md` (uses clipboard if no args) |

### DevBox

| Command | Description |
|---------|-------------|
| `extract <archive>` | Unpack tar/gz/bz2/zip/7z/rar/… |
| `serve [dir] [port]` | Python HTTP server (defaults: `.` / `8000`) |
| `server` | Alias for `serve .` |
| `port <n>` | Show listener(s) on port |
| `bak <file>` | Copy to `<file>.bak` |
| `histg <pattern>` | Search shell history |
| `json [file]` | Pretty-print JSON from file, stdin, or clipboard (`jq`) |
| `up` | `brew update && brew upgrade` (+ cleanup) |
| `nr [script]` | `npm run …` (no args → list scripts) |
| `ni` | `npm install` |

### GitOps

| Command | Description |
|---------|-------------|
| `gcap <msg>` | `git add .` + commit with message |
| `gco <branch>` | Checkout existing branch, or create it |
| `gclean` | Delete merged local branches (keeps main/master/develop) |
| `glog` | Pretty graph log |
| `gundo` | `git reset HEAD~1` (soft undo last commit) |
| `gpr` | `git push -u origin HEAD` then `gh pr create --fill` |

> **Note:** Oh My Zsh’s git plugin defines aliases for some of these names. The suite **unaliases** them first so the functions win.

### Containers & Kubernetes

| Command | Description |
|---------|-------------|
| `dps` | `docker ps` as a compact table |
| `dsh <name> [cmd…]` | `docker exec -it` (default: bash or sh) |
| `kctx` | List contexts / show current |
| `kctx <name>` | `kubectl config use-context` |

### NetUtils

| Command | Description |
|---------|-------------|
| `myip` | Public IP info (`ipinfo.io`) |
| `pingg` | Ping Google DNS (5 packets) |
| `weather [city]` | 3-day forecast via [wttr.in](https://wttr.in) |
| `genpass` | 20-char alphanumeric password |
| `sandbox` | Disposable `/tmp/sandbox_*` shell (removed on exit) |

---

## Completions

Registered when `compdef` is available (Oh My Zsh / your `compinit`):

| Command | Completes |
|---------|-----------|
| `mkd`, `serve` | Directories |
| `bak`, `extract`, `json`, `note` | Files |
| `port`, `killport` | Common ports (3000, 5000, 8000, 5432, 8080, 11434) |
| `dsh` | Running Docker container names |
| `kctx` | kubectl context names |
| `nr` | Scripts from `package.json` (needs `jq`) |

---

## Configuration snapshots (`config/`)

The `config/` directory stores **point-in-time copies** of related configs for reference in git. They are **not** live:

| Snapshot | Typical live path |
|----------|-------------------|
| `config/zshrc` | `~/.zshrc` |
| `config/zprofile` | `~/.zprofile` |
| `config/zsh_prod_suite` | `~/.zsh_prod_suite` (legacy; should not animate) |
| `config/ghostty.config.ghostty` | Ghostty Application Support config |

Update live files in place; refresh snapshots when you intentionally want them in the repo.

---

## Design notes

### Why no `clear` in the banner?

The previous monolithic loader called `clear` every animation frame (~80ms × 21 frames). That full-screen wipe is what felt like stuttering/flicker in Ghostty. The current loader:

1. Draws art **once**
2. Reserves a fixed-height footer block
3. Rewrites only those lines with cursor motion + erase-to-end-of-line

### Why unalias before `gco` / `gclean`?

If an alias exists, zsh expands `gco()` into the alias body and throws:

```text
defining function based on alias `gco'
parse error near `()'
```

### Performance

- No Python/network work at startup for graphics  
- Banner animation ~0.4s on a real TTY, or a single final frame when forced off-TTY  
- Helpers are plain zsh + common CLI tools  

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Banner flickers / full-screen flash | Ensure nothing else sources an old animator that calls `clear`. Only `loader.zsh`. |
| `theme 'starship' not found` | Starship is **not** an Oh My Zsh theme. Set `ZSH_THEME=""` and `eval "$(starship init zsh)"`. |
| `gco` / `gclean` parse errors | Suite should unalias first; ensure you’re on current `aliases.zsh`. |
| No banner | Interactive? TTY? Check `ZSH_SUITE_QUIET` is unset. |
| Completions missing | Load suite **after** Oh My Zsh / `compinit`. |
| `json` fails | Install `jq`. |
| `gpr` only pushes | Install [GitHub CLI](https://cli.github.com/) (`gh`). |

Debug load:

```zsh
ZSH_SUITE_FORCE=1 zsh -i -c 'type killport; type gpr; suite-list | head'
```

---

## Development

```bash
# syntax check all modules
for f in ~/.zsh-suite/*.zsh; do zsh -n "$f" && echo "OK $f"; done

# force banner in a pipe/test
COLUMNS=120 LINES=40 ZSH_SUITE_FORCE=1 zsh -i -c 'true'
```

Contributions welcome: keep helpers small, document them in `labels.zsh`, and avoid calling `clear` from the load path.

---

## License

This project is licensed under the **GNU General Public License v3.0** (or later, at your option, where permitted by the license text).

See the full terms in [`LICENSE`](LICENSE).

In short: you may run, study, share, and modify this software, provided derivative works remain under GPL-3.0 (copyleft).

---

## Credits

- Banner art: pre-baked torus + classic Mandelbrot viewpoints  
- Weather: [wttr.in](https://wttr.in)  
- Inspired by everyday shell ergonomics with Oh My Zsh + Starship + Ghostty
