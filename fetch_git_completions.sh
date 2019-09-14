#!/bin/bash

wget https://github.com/git/git/raw/master/contrib/completion/git-prompt.sh
wget https://github.com/git/git/raw/master/contrib/completion/git-completion.bash
echo "__git_complete g __git_main" >> git-completion.bash
