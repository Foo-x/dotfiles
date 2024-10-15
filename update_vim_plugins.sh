#!/usr/bin/env bash
set -euCo pipefail

# vim plugins
printf '%s\n' "${XDG_CONFIG_HOME}"/vim/pack/plugins/start/* | xargs -I% git -C % pull

# vim colors
printf '%s\n' "${XDG_CONFIG_HOME}"/vim/pack/colors/opt/* | xargs -I% git -C % pull

# nvim plugins
printf '%s\n' "${XDG_CONFIG_HOME}"/nvim/pack/plugins/start/* | xargs -I% git -C % pull

# nvim colors
printf '%s\n' "${XDG_CONFIG_HOME}"/nvim/pack/colors/opt/* | xargs -I% git -C % pull
