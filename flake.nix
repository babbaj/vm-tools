{
  description = "Scripts and dependencies for vm cheats";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    snuggleheimer = {
      url = "git+ssh://git@github.com/babbaj/snuggleheimer.git?ref=snuggle";
      flake = false;
    };
    memflow-nixos.url = github:memflow/memflow-nixos;
  };

  outputs = { self, nixpkgs, flake-utils, snuggleheimer, memflow-nixos }:
    let
      snuggleheimer-src = builtins.fetchGit {
        url = "ssh://git@github.com/babbaj/snuggleheimer.git";
        inherit (snuggleheimer) rev;
        submodules = true;
      };
      system = "x86_64-linux"; # this doesn't need to be portable
      pkgs = import nixpkgs { inherit system; };
      lib = pkgs.lib;
    in {
      packages.${system} = {
        snuggleheimer = import ./snuggleheimer.nix {
          inherit pkgs;
          src = snuggleheimer-src;
        };
      };

      devShell.${system} = with memflow-nixos.packages.${system}; 
      pkgs.mkShell {
        MEMFLOW_EXTRA_PLUGIN_PATHS = lib.makeLibraryPath [
          memflow-kvm # KVM Connector
          memflow-win32 # Win32 Connector plugin
          memflow-qemu # QEMU procfs Connector
        ];

        nativeBuildInputs = with pkgs; [
          pkg-config-file
          pkg-config

          self.packages.${system}.snuggleheimer
          libGL
        ];
      };

      dumper = { dataDir, appId }: with pkgs;
        let
          files = writeTextFile {
            name = "files";
            text = ''
              GameAssembly.dll
              global-metadata.dat
              ${dataDir}/il2cpp_data/Metadata/global-metadata.dat
            '';
          };

          dumper = callPackage ./Il2CppDumper.nix { };
        in writeScriptBin "dump" ''
          #!${stdenv.shell}
          game=$(mktemp -d -t rust-XXXX)
          ${depotdownloader}/bin/DepotDownloader -os windows -osarch 64 -app ${appId} -filelist ${files} -dir $game
          err=$?
          if [[ $err -ne 0 ]]; then 
              rm -rf $rust
              exit $err
          fi
          ${dumper}/bin/Il2CppDumper $game/GameAssembly.dll $game/${dataDir}/il2cpp_data/Metadata/global-metadata.dat ./
          err=$?
          rm -rf $game
          exit $err
        '';
    };
}

