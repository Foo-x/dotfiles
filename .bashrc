# use in your .bashrc or .bash_profile like below
# . /path/to/dotfiles/.bashrc

shopt -s autocd
shopt -s extglob
shopt -s globstar
shopt -s histappend
shopt -s nocaseglob
shopt -s nocasematch
shopt -s nullglob

# set CapsLock to Ctrl
if [ "$(uname)" != 'Darwin' ] && type setxkbmap &> /dev/null; then
  setxkbmap -option ctrl:nocaps
fi
