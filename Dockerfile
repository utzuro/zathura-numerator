FROM archlinux:base-devel

RUN pacman-key --init
# Refresh mirrorlist early so pacman does not hit dead mirrors during setup
RUN pacman -Sy --noconfirm reflector \
    && reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

RUN pacman -Syu --noconfirm

# Dependencies
RUN pacman -S --noconfirm file girara gtk4 json-glib mujs mupdf sqlite xxhash

# Tools
RUN pacman -S --noconfirm git meson ninja gettext pkgconf gcc

WORKDIR /app
COPY . .

# Build modified zathura
RUN meson setup build \
    && meson compile -C build \
    && meson install -C build

# Make zathura.pc available for the plugin building
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"

# Build the pdf plugin matching this zathura release
RUN git clone --branch 2026.07.18 --depth 1 https://github.com/pwmt/zathura-pdf-mupdf.git \
    && meson setup zathura-pdf-mupdf/build zathura-pdf-mupdf \
    && meson compile -C zathura-pdf-mupdf/build \
    && meson install -C zathura-pdf-mupdf/build \
    && printf '/usr/local/lib\n' > /etc/ld.so.conf.d/local.conf \
    && ldconfig

# numbers file will be available in /volume folder
ENTRYPOINT ["/bin/sh", "-c", "cd /app/volume && zathura manga.pdf"]
