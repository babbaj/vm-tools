{ pkgs, src }:

with pkgs;
stdenv.mkDerivation {
  pname = "snuggleheimer";
  version = "nightly";

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
    pipewire.dev
    libpulseaudio
    libsamplerate
  ];

  cmakeFlags = [ "-DOPTIMIZE_FOR_NATIVE=OFF" "-DENABLE_WAYLAND=no" ];
}
