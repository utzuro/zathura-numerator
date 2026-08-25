let
  pkgs = import <nixpkgs> { };
  girara = pkgs.girara.overrideAttrs (_: {
    version = "2026.07.18";
    src = pkgs.fetchFromGitHub {
      owner = "pwmt";
      repo = "girara";
      tag = "2026.07.18";
      hash = "sha256-Q4IbB8Wecob9NH6UPqyIifyd3D+IpMCfe725U3htR+s=";
    };
    mesonFlags = [ "-Ddocs=disabled" ];
    doCheck = false;
  });
in
pkgs.mkShell {
  inputsFrom = [ pkgs.zathura ];

  packages = with pkgs; [
    file
    gettext
    girara
    glib
    gtk4
    json-glib
    libdatrie
    libseccomp
    libselinux
    libsepol
    libsysprof-capture
    libthai
    libxdmcp
    meson
    ninja
    pkg-config
    pkgconf
    pcre2
    sqlite
    util-linux
    xxhash
  ];
}
