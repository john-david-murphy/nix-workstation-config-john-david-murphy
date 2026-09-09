# OneChronos Darwin consumer

This flake is the required user-specific composition for one OneChronos macOS
workstation.

Before evaluation:

1. Confirm that GitHub SSH authentication can read the private
   `onechronos/nix-workstation` repository.
2. Edit `user.nix`.
3. Review `host.nix` and confirm the UID, host platform, state versions, and
   development directory.
4. Commit the consumer before activation so its inputs and configuration are
   recoverable.
5. Generate and commit `flake.lock`.

The Just recipes obtain the configuration name directly from `user.nix`. Use the
maintained build-before-switch workflow:

```sh
just check
just build
just switch
just generations
just rollback GENERATION
```

`just switch` builds the complete closure, activates that exact store path,
registers it as a system generation, and verifies that `/run/current-system` and
the system profile agree. Do not use a prebuilt closure's
`darwin-rebuild activate` action by itself because activation alone does not
advance the rollback profile.

`just rollback GENERATION` activates and registers an existing retained
generation. It validates the active and registered system paths and attempts to
restore the starting generation if rollback fails or is interrupted. List the
available generation numbers with `just generations` before selecting one.

Do not place credentials, tokens, private keys, decrypted configuration, or
licensed material in this repository.
