{pkgs, ...}: let
  user = import ./user.nix;
in {
  nixpkgs.hostPlatform = "aarch64-darwin";

  system = {
    primaryUser = user.username;
    stateVersion = 1;
  };

  users = {
    knownUsers = [user.username];
    users.${user.username} = {
      home = user.homeDirectory;
      name = user.username;
      # Login shell moved from zsh to a nix-pinned bash. Leaving this as
      # pkgs.zsh means activation reverts any `chsh` done by hand.
      shell = pkgs.bashInteractive;
      uid = user.darwinUid;
    };
  };

  # Activation refuses to clobber pre-existing ~/.bashrc, ~/.bash_profile and
  # ~/.profile. This renames them to *.backup on the first switch instead of
  # aborting. darwin-rebuild takes no -b flag, so it has to be set here.
  home-manager.backupFileExtension = "backup";

  home-manager.users.${user.username} = import ./home.nix;
}
