# 💻 Navigation & System Shortcuts
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
mkd() { mkdir -p "$1" && cd "$1"; }
alias ducks="du -cksh * | sort -hr | head -n 10"
if [[ "$OSTYPE" == darwin* ]]; then
    alias cpfile="pbcopy <"
    alias clip="pbcopy"
    alias paste="pbpaste"
else
    alias cpfile="xclip -selection clipboard <"
    alias clip="xclip -selection clipboard"
    alias paste="xclip -selection clipboard -o"
fi
alias cls="clear && printf '\e[3J'"

# Print $PATH one entry per line
pathls() {
    local p
    for p in ${(s.:.)PATH}; do
        print -r -- "$p"
    done
}

# Find + kill whatever is bound to a TCP port
killport() {
    local port=${1:?usage: killport <port>}
    local pids
    pids=$(lsof -ti tcp:"$port" -sTCP:LISTEN 2>/dev/null) || true
    if [[ -z "$pids" ]]; then
        print -r -- "nothing listening on :$port"
        return 1
    fi
    print -r -- "killing :$port → $pids"
    # shellcheck disable=SC2086
    kill $pids 2>/dev/null || kill -9 $pids 2>/dev/null
}

# Append a dated note (clipboard if no args)
note() {
    local dir="${NOTE_DIR:-$HOME/notes}"
    local file="$dir/$(date +%Y-%m-%d).md"
    mkdir -p "$dir"
    local text="$*"
    if [[ -z "$text" ]]; then
        if [[ "$OSTYPE" == darwin* ]]; then
            text=$(pbpaste 2>/dev/null) || true
        else
            text=$(xclip -selection clipboard -o 2>/dev/null) || true
        fi
    fi
    if [[ -z "$text" ]]; then
        print -r -- "usage: note <text>  (or copy text first, then: note)"
        return 1
    fi
    printf '\n## %s\n%s\n' "$(date +%H:%M)" "$text" >>"$file"
    print -r -- "→ $file"
}

# 📦 Development & File Management
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     unrar x "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Better local static server: serve [dir] [port]
serve() {
    local dir=${1:-.}
    local port=${2:-8000}
    if [[ ! -d "$dir" ]]; then
        print -r -- "not a directory: $dir"
        return 1
    fi
    print -r -- "serving $dir on http://127.0.0.1:$port"
    (cd "$dir" && python3 -m http.server "$port")
}
# keep old name as alias
alias server='serve .'

port() { lsof -nP -iTCP:"$1" -sTCP:LISTEN 2>/dev/null || lsof -i :"$1"; }
bak() { cp "$1" "${1}.bak"; }
alias histg="history 1 | grep"

# Pretty-print JSON from stdin, a file, or the clipboard
json() {
    if [[ -n "$1" && -f "$1" ]]; then
        jq . <"$1"
    elif [[ ! -t 0 ]]; then
        jq .
    else
        local raw
        if [[ "$OSTYPE" == darwin* ]]; then
            raw=$(pbpaste 2>/dev/null) || true
        else
            raw=$(xclip -selection clipboard -o 2>/dev/null) || true
        fi
        if [[ -z "$raw" ]]; then
            print -r -- "usage: json [file]  |  … | json  |  (clipboard) json"
            return 1
        fi
        print -r -- "$raw" | jq .
    fi
}

# Homebrew (and friends) updater
up() {
    if command -v brew >/dev/null 2>&1; then
        print -r -- "→ brew update && brew upgrade"
        brew update && brew upgrade
        brew cleanup -s 2>/dev/null || true
    else
        print -r -- "brew not found"
    fi
}

# 📦 JS helpers (history: npm run ×123, npm install ×37)
nr() {
    if [[ $# -eq 0 ]]; then
        npm run
    else
        npm run "$@"
    fi
}
alias ni="npm install"

# 🐙 Git Productivity
gcap() { git add . && git commit -m "$*"; }
# oh-my-zsh git plugin already aliases these — remove before redefining
unalias gco gclean 2>/dev/null
gco() { git checkout "$1" 2>/dev/null || git checkout -b "$1"; }
gclean() {
    local branches
    branches=$(git branch --merged 2>/dev/null | grep -v '^\*' | grep -vE '^\s*(master|main|develop)\s*$' || true)
    [[ -n "$branches" ]] && print -r -- "$branches" | xargs git branch -d
}
alias glog="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gundo="git reset HEAD~1"

# Push current branch and open a PR (needs gh)
gpr() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || {
        print -r -- "not a git repo"
        return 1
    }
    if [[ "$branch" == "HEAD" ]]; then
        print -r -- "detached HEAD — checkout a branch first"
        return 1
    fi
    git push -u origin HEAD || return $?
    if command -v gh >/dev/null 2>&1; then
        gh pr create --fill "$@" || gh pr create "$@"
    else
        print -r -- "pushed $branch (install gh for PR create)"
    fi
}

# 🐳 Docker (history: docker ×52, docker compose ×15)
dps() {
    if ! command -v docker >/dev/null 2>&1; then
        print -r -- "docker not found"
        return 1
    fi
    docker ps --format 'table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}' "$@"
}
dsh() {
    local name=${1:?usage: dsh <container-name-or-id> [cmd...]}
    shift
    if ! command -v docker >/dev/null 2>&1; then
        print -r -- "docker not found"
        return 1
    fi
    if [[ $# -gt 0 ]]; then
        docker exec -it "$name" "$@"
    else
        docker exec -it "$name" sh -c 'command -v bash >/dev/null && exec bash || exec sh'
    fi
}

# ☸️ Kubernetes context helper (no-op message if kubectl missing)
kctx() {
    if ! command -v kubectl >/dev/null 2>&1; then
        print -r -- "kubectl not found"
        return 1
    fi
    if [[ -z "$1" ]]; then
        print -r -- "current: $(kubectl config current-context 2>/dev/null)"
        print -r -- "contexts:"
        kubectl config get-contexts
        return 0
    fi
    kubectl config use-context "$1"
}

# 🌐 Network & External Tools
alias myip="curl -s ipinfo.io"
alias pingg="ping -c 5 8.8.8.8"
weather() { curl -s "https://wttr.in/${1:-}?3"; }
alias genpass="openssl rand -base64 20 | tr -dc 'a-zA-Z0-9' | head -c 20; echo"
sandbox() {
    local rand dir
    rand=$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 8)
    dir="/tmp/sandbox_$rand"
    mkdir -p "$dir" && cd "$dir" && zsh && rm -rf "$dir"
}
