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
      shell = pkgs.zsh;
      uid = user.darwinUid;
    };
  };

  home-manager.users.${user.username} = import ./home.nix;
}
