FROM archlinux:base-devel

RUN pacman-key --init
RUN pacman -Syu --noconfirm

# Dependencies
RUN pacman -S --noconfirm file gtk3 girara json-glib sqlite mujs

# Tools
RUN pacman -S --noconfirm git meson ninja gettext pkgconf gcc

# Install zathura to use as dependency for plugins 
# (they refuse to build my builded version)
RUN pacman -S --noconfirm mupdf girara

WORKDIR /app
COPY . .

# Build modified zathura
RUN meson build \
    && cd build \
    && ninja \
    && ninja install

# Make zathura.pc available for the plugin building
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"

# Build the pdf plugin
RUN git clone https://github.com/pwmt/zathura-pdf-mupdf.git \
    && cd zathura-pdf-mupdf \
    && git switch develop \
    && sed -i 's/, mupdfthird//g' meson.build \
    && sed -i '/mupdf-third/d' meson.build \
    && mkdir build \
    && meson build \
    && cd build \
    && ninja \
    && ninja install

# Force newely builded zathura to use the plugins
ENV ZATHURA_PLUGINS_PATH=/usr/lib/zathura

# numbers file will be available in /volume folder
ENTRYPOINT ["/bin/sh", "-c", "cd /app/volume && zathura manga.pdf"]

