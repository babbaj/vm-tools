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
    rev = "5f0fcb9e94faeb55090e7571d87c43258991aec9";
    sha256 = "1qlxz0gxkz8gfh4dis1bixazg6xa0awxxbg26l0501s9q0sqgwr6";
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
