# dotfiles

## Requirements

- curl


### Optional

- [bash-completion](https://github.com/scop/bash-completion)
    - aliases
        - cht.sh
        - each shortened
- git
    - enhancd
    - fzf
    - PS1
- tmux
    - auto-attach


## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Foo-x/dotfiles/master/install.sh | sh
exec $SHELL -l
```


## Upgrading

```bash
sh ~/.dotfiles/install.sh
exec $SHELL -l
```
