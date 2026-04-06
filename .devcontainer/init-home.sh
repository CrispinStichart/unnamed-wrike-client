#!/usr/bin/env bash
set -euo pipefail

VSCODE_UID="$(id -u vscode)"
VSCODE_GID="$(id -g vscode)"
HOME_DIR="/home/vscode"

mkdir -p "${HOME_DIR}"

if [ -z "$(ls -A "${HOME_DIR}")" ]; then
  cp -a /etc/skel/. "${HOME_DIR}/"
fi

chown -R "${VSCODE_UID}:${VSCODE_GID}" "${HOME_DIR}"

exec "$@"
