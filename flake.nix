{
  description = "Scripts and dependencies for vm cheats";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    snuggleheimer = {
      url = "git+ssh://git@github.com/babbaj/snuggleheimer.git?ref=snuggle";
      flake = false;
    };
    memflow-nixos.url = github:memflow/memflow-nixos?ref=pull/5/head;#github:memflow/memflow-nixos;
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
        MEMFLOW_EXTRA_PLUGIN_PATHS = pkgs.symlinkJoin {
          name = "memflow-connectors";
          paths = [
            "${memflow-kvm}/lib/" # KVM Connector
            "${memflow-win32}/lib/" # Win32 Connector plugin
            "${memflow-qemu}/lib/" # QEMU procfs Connector
          ];
        };

        nativeBuildInputs = with pkgs; [
          #pkg-config-file
          pkg-config
          memflow-nixos.packages.${system}.memflow

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
          read -p 'Steam username: ' username
          read -s -p 'Steam password: ' password
          ${depotdownloader}/bin/DepotDownloader -os windows -osarch 64 -app ${toString appId} -filelist ${files} -dir $game -username $username -password $password
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

