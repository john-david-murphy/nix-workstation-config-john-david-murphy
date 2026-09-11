{pkgs, ...}: let
  user = import ./user.nix;
in {
  home = {
    username = user.username;
    homeDirectory = user.homeDirectory;
    stateVersion = user.homeStateVersion;
  };

  home.packages = [
    # Real ctags. macOS ships an Xcode/BSD stub at /usr/bin/ctags that fails
    # on --version. Useful only for the non-Rust parts of the tree (OCaml,
    # Bazel/Starlark, TS) -- rust-analyzer resolves macros and trait impls
    # that a tags file cannot see.
    pkgs.universal-ctags
    # Structural (AST) search. monoclonal already ships sgconfig.yml, so the
    # team keeps rules under dev/ast-grep-rules.
    pkgs.ast-grep
    # Required by nvim-treesitter's `main` branch, which generates parsers
    # with the CLI rather than shipping pre-generated C like master did.
    pkgs.tree-sitter
  ];

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
      # No cscope: it has no Rust parser at all. Rust is excluded because
      # rust-analyzer covers it properly; this indexes the OCaml/Java/TS/
      # Starlark parts of the tree, and skips build output.
      gentags = "ctags -R --exclude=target --exclude='bazel-*' --exclude=node_modules --exclude=.direnv --exclude=.git --languages=-Rust .";
      plot = "gnuplot -p -e \"plot '<cat'\"";
      config = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";
      n = "nix";
      nd = "nix develop";
      asg = "ast-grep";
      asgr = "ast-grep run --lang rust --pattern";
      asgs = "ast-grep scan";
    };

    # Kept on programs.bash rather than home.sessionVariables: the latter is
    # shared with zsh and would collide if the workstation module sets EDITOR.
    sessionVariables = {
      EDITOR = "nvim";
      MANWIDTH = "100";
      # Silence direnv's per-directory dump of every exported variable.
      # Use "direnv: %s" instead if you want to keep the "loading" line.
      DIRENV_LOG_FORMAT = "";

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
