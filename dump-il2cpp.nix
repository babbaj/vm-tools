{ stdenv
, writeShellApplication
, depotdownloader
, writeTextFile
, il2cppdumper
}:

writeShellApplication (
  let
    depotFiles = writeTextFile {
      name = "files";
      text = ''
        GameAssembly.dll
        global-metadata.dat
        regex:\w+_Data/il2cpp_data/Metadata/global-metadata.dat
      '';
    };
  in
  {
    name = "dump-il2cpp";

    runtimeInputs = [ depotdownloader il2cppdumper ];

    text = ''
      game=$(mktemp -d -t game-XXXX)

      read -r -p "Steam username: " username
      read -sr -p "Steam password:"$'\n' password
      read -r -p "Steam AppID: " steam_app_id

      DepotDownloader \
        -os windows \
        -osarch 64 \
        -app "$steam_app_id" \
        -filelist ${depotFiles} \
        -dir "$game" \
        -username "$username" \
        -password "$password"

      Il2CppDumper \
        "$game/GameAssembly.dll" \
        "$game/"*"_Data/il2cpp_data/Metadata/global-metadata.dat" \
        ./
    '';
  }
)
