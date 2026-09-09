set dotenv-load := false

flake := justfile_directory()
configuration := `nix eval --raw --file user.nix configurationName`

default:
    @just --list

fmt:
    nix fmt "{{flake}}"

check:
    nix flake check "{{flake}}"

build:
    nix build "{{flake}}#darwinConfigurations.{{configuration}}.system" --print-build-logs

switch:
    "{{flake}}/scripts/switch" "{{configuration}}"

rollback generation:
    "{{flake}}/scripts/rollback" "{{generation}}"

generations:
    sudo -H /nix/var/nix/profiles/default/bin/nix-env \
        --profile /nix/var/nix/profiles/system \
        --list-generations
