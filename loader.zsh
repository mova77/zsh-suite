# Main orchestrator linking the split modules
# Guard: never run twice (zprofile + zshrc used to double-load)
[[ -n ${_SUITE_LOADED:-} ]] && return 0
typeset -g _SUITE_LOADED=1

_SUITE_DIR="${0:A:h}"

source "$_SUITE_DIR/aliases.zsh"
source "$_SUITE_DIR/completions.zsh"
source "$_SUITE_DIR/labels.zsh"
source "$_SUITE_DIR/engine.zsh"

# ── In-place line helpers (never clear the screen) ──────────────────────────
# Move cursor up N lines (no scroll, no wipe)
_suite_cup() { (( $1 > 0 )) && printf '\e[%dA' "$1"; }

# Rewrite current line from column 0; erase tail only (not whole screen)
_suite_rewrite_line() { printf '\r\e[2K%b' "$1"; }

# Rewrite a multi-line block already on screen: go up, overwrite each line
_suite_rewrite_block() {
    local -a lines=("$@")
    local n=${#lines[@]} i
    (( n < 1 )) && return 0
    _suite_cup "$n"
    for (( i = 1; i <= n; i++ )); do
        printf '\r\e[2K%b\n' "${lines[i]}"
    done
}

_instant_suite_load() {
    # Interactive TTYs only
    [[ -o interactive ]] || return 0
    [[ -t 1 || -n ${ZSH_SUITE_FORCE:-} ]] || return 0

    # Allow opt-out: ZSH_SUITE_QUIET=1
    [[ -n ${ZSH_SUITE_QUIET:-} ]] && return 0

    zmodload zsh/zselect 2>/dev/null
    _suite_term_size

    local -a art_src
    local art_label=''
    if (( RANDOM % 2 )); then
        # Random interesting Mandelbrot region (not the boring solid center)
        _suite_pick_fractal
        art_src=("${_SUITE_FRACTAL_ROWS[@]}")
        art_label="mandelbrot · ${_SUITE_FRACTAL_VIEW}"
    else
        art_src=("${_SUITE_DONUT_ROWS[@]}")
        art_label='torus'
    fi

    local graphic_color=$'\e[1;36m'
    case $(( RANDOM % 4 )) in
        0) graphic_color=$'\e[1;35m' ;;
        1) graphic_color=$'\e[1;34m' ;;
        2) graphic_color=$'\e[1;33m' ;;
    esac
    local reset=$'\e[0m' dim=$'\e[90m' green=$'\e[32m' bold=$'\e[1m' cyan=$'\e[1;36m'
    local red=$'\e[31m' yellow=$'\e[33m'

    # 1) Paint art ONCE — never redraw it (redrawing art is what felt like flicker)
    local art
    art=$(_suite_scale_art "${art_src[@]}")
    printf '\n%b%s%b\n' "$graphic_color" "$art" "$reset"
    printf '%b  · %s%b\n\n' "$dim" "$art_label" "$reset"

    # 2) Progress bar geometry — track category count, not every label row
    local total=6
    local helper_count=${#_SUITE_LABELS[@]}
    local bar_inner=$(( _SUITE_COLS - 34 ))
    (( bar_inner < 12 )) && bar_inner=12
    (( bar_inner > 40 )) && bar_inner=40

    local compact=1
    # Full label dump only on very tall terminals (suite grew past 20 items)
    (( _SUITE_COLS >= 72 && _SUITE_ROWS >= $(( helper_count + 12 )) )) && compact=0
    (( _SUITE_COLS < 52 )) && compact=2

    # 3) Animate bar + checklist by REWRITING lines in place (no clear / no cls)
    #    Real TTY  → multi-frame with cursor-up + erase-line overwrite
    #    Piped/force → single final frame (cursor motion is meaningless off-TTY)
    local animate=0
    [[ -t 1 ]] && animate=1

    local current filled empty percent bar bar_color idx
    local -a block
    local first=1
    local start=0
    (( animate )) || start=$total

    # Hide cursor during overwrite so it doesn't flash between frames
    (( animate )) && printf '\e[?25l'

    for (( current = start; current <= total; current++ )); do
        percent=$(( current * 100 / total ))
        filled=$(( current * bar_inner / total ))
        empty=$(( bar_inner - filled ))

        bar_color=$red
        (( percent > 45 )) && bar_color=$yellow
        (( percent > 85 )) && bar_color=$green

        bar=${(l:filled::█:)}${(l:empty::░:)}

        block=()
        block+=("${cyan}⚙️  Loading Zsh Suite: ${bar_color}[${bar}]${reset} ${bold}${percent}%${reset} (${current}/${total})")

        if (( compact == 0 )); then
            # Reveal labels proportionally across animation frames
            local show=$(( current * helper_count / total ))
            for (( idx = 1; idx <= show; idx++ )); do
                block+=("  ${green}✔${reset} ${_SUITE_LABELS[idx]}")
            done
            for (( idx = show + 1; idx <= helper_count; idx++ )); do
                block+=("")
            done
            if (( current == total )); then
                block+=("")
                block+=("${green}🚀 All ${helper_count} helpers active.${reset} Type ${bold}suite-list${reset} anytime.")
            else
                block+=("")
                block+=("")
            fi
        elif (( compact == 1 )); then
            # Stable category footer — ticks light up as frames advance
            local s1=$dim s2=$dim s3=$dim s4=$dim s5=$dim s6=$dim
            (( current >= 1 )) && s1=$green
            (( current >= 2 )) && s2=$green
            (( current >= 3 )) && s3=$green
            (( current >= 4 )) && s4=$green
            (( current >= 5 )) && s5=$green
            (( current >= 6 )) && s6=$green
            block+=("  ${s1}✔${reset} ${bold}System${reset}      ${dim}mkd killport note pathls clip paste${reset}")
            block+=("  ${s2}✔${reset} ${bold}DevBox${reset}      ${dim}serve json up nr ni port extract${reset}")
            block+=("  ${s3}✔${reset} ${bold}GitOps${reset}      ${dim}gcap gco gpr gclean glog gundo${reset}")
            block+=("  ${s4}✔${reset} ${bold}Containers${reset} ${dim}dps dsh${reset}")
            block+=("  ${s5}✔${reset} ${bold}K8s${reset}         ${dim}kctx${reset}")
            block+=("  ${s6}✔${reset} ${bold}NetUtils${reset}    ${dim}myip weather genpass sandbox${reset}")
            if (( current == total )); then
                block+=("")
                block+=("${green}🚀 ${helper_count} helpers loaded.${reset} Run ${bold}suite-list${reset} for the full cheat sheet.")
            else
                block+=("")
                block+=("")
            fi
        else
            if (( current == total )); then
                block+=("${green}🚀 ${helper_count} helpers ready.${reset} ${dim}suite-list${reset}")
            else
                block+=("")
            fi
        fi

        if (( first )); then
            local line
            for line in "${block[@]}"; do
                printf '%b\n' "$line"
            done
            first=0
        else
            # Cursor up + per-line erase/overwrite — never `clear` / never cls
            _suite_rewrite_block "${block[@]}"
        fi

        # ~20ms/frame ≈ 0.4s total — no full-screen redraw
        (( animate && current < total )) && zselect -t 2 2>/dev/null
    done

    (( animate )) && printf '\e[?25h'  # restore cursor
    printf '\n'
}

_instant_suite_load

unset -f _instant_suite_load _suite_cup _suite_rewrite_line _suite_rewrite_block
unset -f _suite_term_size _suite_scale_row _suite_scale_art _suite_compute_scale _suite_pick_fractal
unset _SUITE_DIR
