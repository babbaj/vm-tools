{ pkgs, src }:

with pkgs;
stdenv.mkDerivation {
    pname = "snuggleheimer";
    version = "nightly";

    /*src = builtins.fetchGit {
        url = "ssh://git@github.com/babbaj/snuggleheimer.git";
        ref = "snuggle";
        rev = "8bc24aaab0f5a717aaa75b8b089529e28e609e01";
        submodules = true;
    };*/
    inherit src;

    sourceRoot = "source/client";

    nativeBuildInputs = [ cmake pkg-config ];

    buildInputs = with xorg; [
        libGL
        freefont_ttf
        spice-protocol
        expat
        libbfd
        nettle
        fontconfig
        libffi
        libxkbcommon
        libXi
        libXScrnSaver
        libXinerama
        libXcursor
        libXpresent
        libXext
        libXrandr
        #wayland
        #wayland-protocols
    ];

    cmakeFlags = [ "-DOPTIMIZE_FOR_NATIVE=OFF" "-DENABLE_WAYLAND=no" ];
}
