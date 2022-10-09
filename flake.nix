{
  description = "Scripts and dependencies for vm cheats";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    snuggleheimer = {
      #url = "git+ssh://git@github.com/babbaj/snuggleheimer.git?ref=snuggle";
      url = "git+ssh://git@github.com/babbaj/snuggleheimer.git";
      type = "git";
      ref = "snuggle";
      submodules = true;
      flake = false;
    };
    memflow.url = github:memflow/memflow-nixos;
    il2cppdumper = {
      url = github:babbaj/Il2CppDumper/header;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, memflow, snuggleheimer, ... } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          snuggleheimer = import ./snuggleheimer.nix {
            inherit pkgs;
            src = snuggleheimer;
          };

          # Il2CppDumper dumper program itself
          il2cppdumper = pkgs.callPackage ./Il2CppDumper.nix { il2cppdumper-src = inputs.il2cppdumper; };

          # Convenience script for Il2CppDumper & DepotDownloader
          dump-il2cpp = pkgs.callPackage ./dump-il2cpp.nix { inherit (self.packages.${system}) il2cppdumper; };
        };

        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; with memflow.packages.${system}; [
            pkg-config
            memflow-ffi

            self.packages.${system}.snuggleheimer
            libGL
          ];
        };
      });
}
