##!/usr/bin/env bash

paru -S oh-my-posh zsh-history-substring-search fzf --needed --noconfirm
git clone git@github.com:unixorn/fzf-zsh-plugin.git plugins/fzf-zsh-plugin
git clone git@github.com:zsh-users/zsh-autosuggestions.git plugins/zsh-autosuggestions
git clone git@github.com:zsh-users/zsh-syntax-highlighting.git plugins/zsh-syntax-highlighting
git clone git@github.com:agkozak/zsh-z.git plugins/zsh-z
