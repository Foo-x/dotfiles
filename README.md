# dotfiles

## Requirements

- curl
- git


### Optional

- [bash-completion](https://github.com/scop/bash-completion)
    - aliases
- tmux
    - auto-attach
- git diff-highlight
    - `GIT_PAGER`


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
