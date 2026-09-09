{...}: let
  user = import ./user.nix;
in {
  home = {
    username = user.username;
    homeDirectory = user.homeDirectory;
    stateVersion = user.homeStateVersion;
  };

  onechronos.development = {
    enable = true;
    directory = user.developmentDirectory;
    email = user.email;
    fullName = user.fullName;
    gitContributor = user.gitContributor;
  };

  programs.git.settings.user = {
    email = user.email;
    name = user.fullName;
  };
}
