# dotfiles

## Requirements

- curl


### Optional

- [bash-completion](https://github.com/scop/bash-completion)
    - aliases
        - cht.sh
        - each shortened
- git
    - fzf
    - PS1
- tmux
    - auto-attach


## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/Foo-x/dotfiles/master/install.sh | bash
exec $SHELL -l
```


## Upgrading

```bash
bash ~/.dotfiles/install.sh
exec $SHELL -l
```
