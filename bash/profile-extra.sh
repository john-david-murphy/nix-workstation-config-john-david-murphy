# Sourced by ~/.profile (home-manager generated) for login shells.
# Ported from the hand-written ~/.bash_profile.

# --- nix (defensive) ----------------------------------------------------------
# The multi-user installer hooks /etc/bashrc, which /etc/profile sources for
# login bash. If NIX_PROFILES is unset here, that hook did not run.
if [[ -z ${NIX_PROFILES-} && -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# nix-provided completions: bash-completion@2 searches XDG_DATA_DIRS.
# Word splitting on $NIX_PROFILES is intentional.
for _profile in $NIX_PROFILES; do
    [[ -d $_profile/share ]] && XDG_DATA_DIRS="${XDG_DATA_DIRS:+$XDG_DATA_DIRS:}$_profile/share"
done
unset _profile
export XDG_DATA_DIRS

# --- rustup (optional) --------------------------------------------------------
# This prepends ~/.cargo/bin, whose shims can shadow the nix-pinned toolchain.
# direnv re-prepends the dev shell on entering a repo, so nix wins there. Once
# nothing outside a dev shell needs rustup, delete this block.
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
