{ pkgs ? import <nixpkgs> {} }:

with pkgs;
let
    files = writeTextFile {
        name = "files";
        text = ''
            GameAssembly.dll
            global-metadata.dat
            RustClient_Data/il2cpp_data/Metadata/global-metadata.dat
        '';
    };

    dumper = callPackage ./Il2CppDumper.nix {};
in
writeScriptBin "dump" 
''
    #!${stdenv.shell}
    rust=$(mktemp -d -t rust-XXXX)
    ${depotdownloader}/bin/depotdownloader -os windows -osarch 64 -app 252490 -filelist ${files} -dir $rust -username $STEAM_USER -password $STEAM_PASS
    if [[ $? -ne 0 ]] ; then 
        rm -rf $rust
        exit $?
    fi
    ${dumper}/bin/Il2CppDumper $rust/GameAssembly.dll $rust/RustClient_Data/il2cpp_data/Metadata/global-metadata.dat ./
    err=$?
    rm -rf $rust
    exit $err
''
