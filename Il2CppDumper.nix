{ stdenv, lib, fetchFromGitHub, fetchurl, linkFarmFromDrvs, makeWrapper
,  dotnet-sdk_3, dotnetPackages
}:

let
  fetchNuGet = {name, version, sha256}: fetchurl {
    name = "nuget-${name}-${version}.nupkg";
    url = "https://www.nuget.org/api/v2/package/${name}/${version}";
    inherit sha256;
  };
  deps = import ./deps.nix fetchNuGet;
in
stdenv.mkDerivation rec {
  pname = "il2cppdumper";
  version = "header";

  src = fetchFromGitHub {
    owner = "babbaj";
    repo = "Il2CppDumper";
    rev = "66cd66dd08ee5bd76eb8e739834244d812486b82";
    sha256 = "0n19vfrxkzh21imw7ymy1n7q179clbgdian74kvlq6gr1m747rxp";
  };

  nativeBuildInputs = [ dotnet-sdk_3 dotnetPackages.Nuget makeWrapper ];

  buildPhase = ''
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    export DOTNET_NOLOGO=1
    export HOME=$TMP/home
    nuget sources Add -Name tmpsrc -Source $TMP/nuget
    nuget init ${linkFarmFromDrvs "deps" deps} $TMP/nuget
    dotnet restore --source $TMP/nuget Il2CppDumper/Il2CppDumper.csproj

    dotnet publish --no-restore -c Release -f netcoreapp3.1 --output $out
  '';

  installPhase = ''
    makeWrapper ${dotnet-sdk_3}/bin/dotnet $out/bin/Il2CppDumper \
      --add-flags $out/Il2CppDumper.dll
  '';
}
