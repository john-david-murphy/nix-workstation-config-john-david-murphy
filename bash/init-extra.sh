# Sourced by ~/.bashrc (home-manager generated) for interactive shells.
# Ported from the hand-written ~/.bashrc. home-manager already handles the
# non-interactive early return, hm-session-vars.sh, history options and the
# direnv hook, so none of that appears here.

# --- Homebrew / GNU userland --------------------------------------------------
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    # Prefer GNU coreutils/findutils/sed/grep when installed:
    #   brew install coreutils findutils gnu-sed grep
    for _d in coreutils findutils gnu-sed grep; do
        _p="$HOMEBREW_PREFIX/opt/$_d/libexec/gnubin"
        [[ -d $_p ]] && PATH="$_p:$PATH"
    done
    unset _d _p
fi

# --- Personal bin dirs (appended, as before) ----------------------------------
PATH="$PATH:$HOME/bin:$HOME/.local/bin"

# --- Re-assert nix ahead of Homebrew ------------------------------------------
# brew shellenv and the gnubin loop above both PREPEND, which otherwise leaves
# Homebrew tools shadowing nix-pinned ones and breaks reproducibility. If you
# would rather keep GNU coreutils in front for interactive use, delete this
# block -- but then expect `sed`/`readlink`/`install` to differ from CI.
for _p in "$HOME/.nix-profile/bin" \
          /run/current-system/sw/bin \
          /nix/var/nix/profiles/default/bin; do
    [[ -d $_p ]] && PATH="$_p:$PATH"
done
unset _p
export PATH

# --- ls colors ----------------------------------------------------------------
if command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"
    alias ls='ls --quoting-style=literal --color'
else
    export CLICOLOR=1
    alias ls='ls -G'
fi

# --- bash completion ----------------------------------------------------------
for _f in "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" \
          /run/current-system/sw/etc/profile.d/bash_completion.sh \
          "$HOME/.nix-profile/etc/profile.d/bash_completion.sh"; do
    if [[ -r $_f ]]; then . "$_f"; break; fi
done
unset _f

# --- Prompt -------------------------------------------------------------------
# Deliberately not exported: these are prompt escapes, and pushing them into
# every child process's environment buys nothing.
RED='\[\033[00;31;31m\]'
BLUE='\[\033[01;34;34m\]'
YELLOW='\[\033[01;33;33m\]'
GREEN='\[\033[01;32;32m\]'
PURPLE='\[\033[00;34;35m\]'
WHITE='\[\033[01;37;37m\]'
NONE='\[\033[00m\]'
NORM='\[\033[01;00;0m\]'
GRAY='\[\033[1;30m\]'
LIGHT_GRAY='\[\033[0;37m\]'

# Under nix-darwin with home-manager as a module, per-user packages live in
# /etc/profiles/per-user/$USER -- NOT ~/.nix-profile. That is where git's
# contrib scripts actually are on this machine.
for _f in "/etc/profiles/per-user/$USER/share/git/contrib/completion/git-prompt.sh" \
          /run/current-system/sw/share/git/contrib/completion/git-prompt.sh \
          "$HOME/.nix-profile/share/git/contrib/completion/git-prompt.sh" \
          "$HOMEBREW_PREFIX/etc/bash_completion.d/git-prompt.sh" \
          "$HOMEBREW_PREFIX/opt/git/etc/bash_completion.d/git-prompt.sh"; do
    if [[ -r $_f ]]; then . "$_f"; break; fi
done
unset _f

# Last resort: derive it from wherever git itself resolves to.
if ! type __git_ps1 >/dev/null 2>&1; then
    _gitshare="$(dirname -- "$(dirname -- "$(command -v git)")")/share/git"
    [[ -r "$_gitshare/contrib/completion/git-prompt.sh" ]] &&
        . "$_gitshare/contrib/completion/git-prompt.sh"
    unset _gitshare
fi

type __git_ps1 >/dev/null 2>&1 || __git_ps1() { :; }

# Branch plus a dirty-state marker. Unset these if the extra `git status`
# call per prompt ever feels slow in a large working tree.
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=
GIT_PS1_SHOWUPSTREAM=auto

PS1="\n${WHITE}\u@\h ${YELLOW}\w${GREEN}\$(__git_ps1)\n${NORM}$ "

# --- Pagers / man -------------------------------------------------------------
# fold: GNU long opts if available, else BSD short opts
if fold --version >/dev/null 2>&1; then
    _fold() { fold --spaces --width=100; }
else
    _fold() { fold -s -w 100; }
fi

ll() { cat "$1" | _fold | less; }
lh() {
    local base
    base=$(basename -- "$1")
    cat "$1" | _fold | bat -n --language="${base##*.}"
}
lhc() {
    local base
    base=$(basename -- "$1")
    cat "$1" | _fold | bat --paging=never -n --language="${base##*.}"
}

# --- Clipboard ----------------------------------------------------------------
# clip            copy stdin            e.g.  git diff | clip
# clip FILE...    copy file contents    e.g.  clip Cargo.toml
# clipo           paste clipboard to stdout
# clipt           copy stdin AND pass it through (tee-style)
clip()  { if (( $# )); then cat -- "$@" | pbcopy; else pbcopy; fi; }
clipo() { pbpaste; }
clipt() { tee >(pbcopy); }

# --- Simple calculator --------------------------------------------------------
# printf format string is fixed and the expression passed as an argument, so a
# stray % or \ in the expression can no longer be interpreted as a directive.
calc() {
    local result
    result="$(printf 'scale=10;%s\n' "$*" | bc --mathlib | tr -d '\\\n')"
    if [[ $result == *.* ]]; then
        printf '%s' "$result" |
            sed -e 's/^\./0./' \
                -e 's/^-\./-0./' \
                -e 's/0*$//;s/\.$//'
    else
        printf '%s' "$result"
    fi
    printf '\n'
}
