with import <nixpkgs> { };
stdenv.mkDerivation {
  name = "build";
  buildInputs = [
    meson
    pkgconf
    pkg-config
    gettext
    autoconf
    automake
    libtool
    sphinx
    ffmpeg
    texinfo
    SDL2
    gtk3
    glib
    glibc
    json-glib
    sqlite
    libffi
    zlib
    libmediainfo
    libffi
    libseccomp
    girara
    shared-mime-info
    libnotify
    doxygen
  ];
}
