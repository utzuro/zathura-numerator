with import <nixpkgs> {};
stdenv.mkDerivation {
  name = "build";
  nativeBuildInputs = [ cmake ];
  buildInputs = [
    cmake clang clang-tools llvm ccache ninja meson gettext pkgconf
    SDL2 SDL2_ttf SDL2_net SDL2_image SDL2_sound SDL2_mixer SDL2_gfx
    ffmpeg tbb vulkan-headers libxkbcommon
    gtk3 glib girara json-glib sqlite file 
    desktop-file-utils appstream-glib xvfb-run
    sphinx doxygen 
    python312Packages.breathe 
    texlivePackages.synctex
    librsvg libseccomp
  ];
}
