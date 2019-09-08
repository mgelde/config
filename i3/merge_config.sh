#! /bin/bash

CONFIG_BASE="${HOME}/config/i3/config"
CONFIG_LOCAL="${HOME}/.i3/local.conf"
if [[ -f "${CONFIG_LOCAL}" ]]; then
    cat "${CONFIG_BASE}" "${CONFIG_LOCAL}" > "${HOME}/.config/i3/config"
else
    cat "${CONFIG_BASE}" > "${HOME}/.config/i3/config"
fi

