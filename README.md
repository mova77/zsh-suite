# Modular Zsh Productivity Suite

Split modules loaded from `~/.zshrc` via `loader.zsh`.

| File | Role |
|------|------|
| `loader.zsh` | Orchestrator + flicker-free banner (cursor overwrite) |
| `aliases.zsh` | Helpers (git, docker, npm, net, clipboard, …) |
| `completions.zsh` | Tab completions for suite commands |
| `labels.zsh` | `suite-list` cheat sheet |
| `engine.zsh` | Window-scaled ASCII art (torus + Mandelbrot views) |
| `suite.zsh` | Legacy entrypoint → `loader.zsh` |

## Config snapshots

`config/` holds copies of related home/app configs at commit time:

- `zshrc`, `zprofile`, `zsh_prod_suite`
- `ghostty.config.ghostty`

These are **snapshots**, not live files. Live paths remain under `$HOME` and Ghostty’s Application Support directory.

## Usage

```zsh
# already sourced from ~/.zshrc:
# [[ -f "$HOME/.zsh-suite/loader.zsh" ]] && source "$HOME/.zsh-suite/loader.zsh"

suite-list   # full cheat sheet
```

Quiet banner: `ZSH_SUITE_QUIET=1`
