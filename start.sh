#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
docker_args=(-it --volume "$DIR:/app")
gdk_backends=()

# Prefer native Wayland when its compositor socket is available.
if [[ -n ${WAYLAND_DISPLAY:-} && -n ${XDG_RUNTIME_DIR:-} ]]; then
	wayland_socket="$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
	if [[ -S $wayland_socket ]]; then
		container_runtime_dir=/tmp/xdg-runtime
		docker_args+=(
			--env "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
			--env "XDG_RUNTIME_DIR=$container_runtime_dir"
			--volume "$wayland_socket:$container_runtime_dir/$WAYLAND_DISPLAY"
		)
		gdk_backends+=(wayland)
	fi
fi

# Keep X11/XWayland as a fallback.
if [[ -n ${DISPLAY:-} && -d /tmp/.X11-unix ]]; then
	if ! command -v xhost >/dev/null || ! xhost +local:docker >/dev/null; then
		printf 'warning: could not grant container X11 access\n' >&2
	fi
	docker_args+=(
		--env "DISPLAY=$DISPLAY"
		--volume /tmp/.X11-unix:/tmp/.X11-unix
	)
	gdk_backends+=(x11)
fi

if ((${#gdk_backends[@]} == 0)); then
	printf 'error: no usable Wayland or X11 display found\n' >&2
	exit 1
fi

gdk_backend=$(
	IFS=,
	printf '%s' "${gdk_backends[*]}"
)
docker_args+=(--env "GDK_BACKEND=$gdk_backend")

docker build -t zathura .
docker run "${docker_args[@]}" zathura:latest
