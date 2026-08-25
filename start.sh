#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if (($# > 1)); then
	printf 'usage: %s [PDF]\n' "$0" >&2
	exit 2
fi

if (($# == 1)); then
	document=$1
elif [[ -f $DIR/volume/manga.pdf ]]; then
	document=$DIR/volume/manga.pdf
elif [[ -f $DIR/target.pdf ]]; then
	document=$DIR/target.pdf
else
	printf 'error: no PDF specified and no default PDF found\n' >&2
	exit 1
fi

document_path=$(realpath -e -- "$document")
case "$document_path" in
"$DIR"/*) ;;
*)
	printf 'error: PDF must be inside %s\n' "$DIR" >&2
	exit 1
	;;
esac

document_relative=${document_path#"$DIR"/}
container_document=/app/$document_relative
container_runtime_dir=/tmp/xdg-runtime
host_uid=$(id -u)
host_gid=$(id -g)
docker_args=(
	-it
	--rm
	--user "$host_uid:$host_gid"
	--env HOME=/tmp/home
	--tmpfs "/tmp/home:uid=$host_uid,gid=$host_gid,mode=0700"
	--volume "$DIR:/app"
	--workdir "$(dirname -- "$container_document")"
	--entrypoint zathura
)
if [[ -d /dev/dri ]]; then
	docker_args+=(--device /dev/dri)
fi

gdk_backends=()

if [[ -n ${WAYLAND_DISPLAY:-} && -n ${XDG_RUNTIME_DIR:-} ]]; then
	wayland_socket="$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
	if [[ -S $wayland_socket ]]; then
		docker_args+=(
			--env "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
			--env "XDG_RUNTIME_DIR=$container_runtime_dir"
			--volume "$wayland_socket:$container_runtime_dir/$WAYLAND_DISPLAY"
		)
		gdk_backends+=(wayland)
	fi
fi

if [[ ${DBUS_SESSION_BUS_ADDRESS:-} == unix:path=* ]]; then
	dbus_socket=${DBUS_SESSION_BUS_ADDRESS#unix:path=}
	dbus_socket=${dbus_socket%%,*}
	if [[ -S $dbus_socket ]]; then
		docker_args+=(
			--env "DBUS_SESSION_BUS_ADDRESS=unix:path=$container_runtime_dir/bus"
			--volume "$dbus_socket:$container_runtime_dir/bus"
		)
	fi
fi

if [[ -n ${DISPLAY:-} && -d /tmp/.X11-unix ]]; then
	xauthority=${XAUTHORITY:-${HOME:-}/.Xauthority}
	if [[ -f $xauthority ]]; then
		docker_args+=(
			--env XAUTHORITY=/tmp/.Xauthority
			--volume "$xauthority:/tmp/.Xauthority:ro"
		)
	elif command -v xhost >/dev/null && ! xhost "+si:localuser:$(id -un)" >/dev/null; then
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
docker run "${docker_args[@]}" zathura:latest "$container_document"
