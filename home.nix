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

  programs.git.settings = {
    user = {
      email = user.email;
      name = user.fullName;
    };

    # Short, always-terminal output regardless of what LESS says. Belt and
    # braces alongside the LESS fix below.
    pager = {
      branch = false;
      tag = false;
      stash = false;
    };
  };

  # Login shell is bash (see host.nix). Home Manager writes ~/.bashrc,
  # ~/.bash_profile and ~/.profile as store symlinks, sources
  # hm-session-vars.sh for us, and installs the direnv hook below.
  programs.bash = {
    enable = true;

    historySize = 100000;
    historyFileSize = 200000;
    historyControl = ["ignoredups" "ignorespace"];

    shellAliases = {
      v = "nvim";
      sl = "ls";
      m = "make -j$(sysctl -n hw.ncpu)";
      diff = "diff -W $(( $(tput cols) - 2 ))";
      gcl = "git clone";
      gentags = "ctags -R && cscope -b -q -R";
      plot = "gnuplot -p -e \"plot '<cat'\"";
      config = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";
      n = "nix";
      nd = "nix develop";
    };

    # Kept on programs.bash rather than home.sessionVariables: the latter is
    # shared with zsh and would collide if the workstation module sets EDITOR.
    sessionVariables = {
      EDITOR = "nvim";
      MANWIDTH = "100";
      # -F (quit if one screen) and -R (pass colour through) are what git
      # sets for its own pager, but only when LESS is unset. Exporting LESS
      # without them is why `git branch` sits in the pager instead of
      # printing and exiting.
      LESS = "--quit-if-one-screen --RAW-CONTROL-CHARS --mouse --wheel-lines=3 --ignore-case";
    };

    profileExtra = builtins.readFile ./bash/profile-extra.sh;
    initExtra = builtins.readFile ./bash/init-extra.sh;
  };

  # Installs the hook into every managed shell, so rust-analyzer, cargo and
  # rustfmt resolve to the repo's pinned dev shell. nix-direnv caches the
  # flake evaluation; without it every `cd` into a repo re-evaluates.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
