#!/usr/bin/env bash
set -euCo pipefail

# vim plugins
printf '%s\n' "${XDG_CONFIG_HOME}"/vim/pack/plugins/start/* | xargs -I% bash -c 'echo %; git -C % pull'

# vim colors
printf '%s\n' "${XDG_CONFIG_HOME}"/vim/pack/colors/opt/* | xargs -I% bash -c 'echo %; git -C % pull'

# nvim plugins
printf '%s\n' "${XDG_CONFIG_HOME}"/nvim/pack/plugins/start/* | xargs -I% bash -c 'echo %; git -C % pull'

# nvim colors
printf '%s\n' "${XDG_CONFIG_HOME}"/nvim/pack/colors/opt/* | xargs -I% bash -c 'echo %; git -C % pull'

nvim -es +"
set pp+=${XDG_CONFIG_HOME}/vim,${XDG_CONFIG_HOME}/vim/after |
  silent! packl! |
  packadd everforest |
  helptags ALL |
  q
"
