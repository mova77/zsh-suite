# Completions for suite helpers (compinit already run by oh-my-zsh / zshrc)
_suite_completions() {
    (( $+functions[compdef] )) || return 0
    compdef '_files -/' mkd
    compdef '_files -/' serve
    compdef _files bak
    compdef _files extract
    compdef _files json
    compdef _files note

    _comp_ports() {
        local -a ports
        ports=(
            '3000:Frontend'
            '5000:Backend'
            '8000:Python'
            '5432:PostgreSQL'
            '8080:Alt HTTP'
            '11434:Ollama'
        )
        _describe 'common ports' ports
    }
    compdef _comp_ports port
    compdef _comp_ports killport

    # docker container names for dsh
    if command -v docker >/dev/null 2>&1; then
        _comp_dsh() {
            local -a containers
            containers=(${(f)"$(docker ps --format '{{.Names}}' 2>/dev/null)"})
            _describe 'running containers' containers
        }
        compdef _comp_dsh dsh
    fi

    # kubectl contexts for kctx
    if command -v kubectl >/dev/null 2>&1; then
        _comp_kctx() {
            local -a ctxs
            ctxs=(${(f)"$(kubectl config get-contexts -o name 2>/dev/null)"})
            _describe 'kubectl contexts' ctxs
        }
        compdef _comp_kctx kctx
    fi

    # npm scripts for nr
    _comp_nr() {
        local -a scripts
        if [[ -f package.json ]] && command -v jq >/dev/null 2>&1; then
            scripts=(${(f)"$(jq -r '.scripts | keys[]' package.json 2>/dev/null)"})
            _describe 'npm scripts' scripts
        fi
    }
    compdef _comp_nr nr
}
_suite_completions
unset -f _suite_completions
