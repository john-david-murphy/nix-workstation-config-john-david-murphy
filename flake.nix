{
  description = "User-specific OneChronos Darwin workstation consumer";

  inputs = {
    onechronos.url = "git+ssh://git@github.com/onechronos/nix-workstation.git";
    nix-darwin.follows = "onechronos/nix-darwin";
    nixpkgs.follows = "onechronos/nixpkgs";
  };

  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    onechronos,
    ...
  }: let
    user = import ./user.nix;
    system = "aarch64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    darwinConfigurations.${user.configurationName} = nix-darwin.lib.darwinSystem {
      modules = [
        onechronos.darwinModules.workstation
        ./host.nix
      ];
    };

    checks.${system} = {
      darwin-system = self.darwinConfigurations.${user.configurationName}.system;

      formatting =
        pkgs.runCommand "alejandra-check" {
          nativeBuildInputs = [
            pkgs.alejandra
            pkgs.findutils
          ];
          src = self;
        } ''
          cd "$src"
          find . -name '*.nix' -print0 | xargs -0 alejandra --check
          touch "$out"
        '';
    };

    formatter.${system} = pkgs.alejandra;
  };
}
