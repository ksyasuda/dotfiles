if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/catppuccin_macchiato.omp.json)"
fi

source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.bash_aliases
source ~/.aliases
source ~/.environment

source <(fzf --zsh)

eval $(thefuck --alias)
HISTFILE=~/.zsh_history
HISTSIZE=10000
HISTFILESIZE=2000
HISTCONTROL=ignoreboth

# fpath=(/Users/sudacode/.docker/completions $fpath)
FPATH="$HOME/.docker/completions:$FPATH"

[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

bindkey -v
# zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# zstyle ':completion:*' menu select

# Substring search
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
# mac
# source $HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# Bind arrow keys for vi insert mode
bindkey -M viins '^[[A' history-substring-search-up
bindkey -M viins '^[[B' history-substring-search-down
# Also bind arrow keys for vi command mode
bindkey -M vicmd '^[[A' history-substring-search-up
bindkey -M vicmd '^[[B' history-substring-search-down
bindkey '^ ' autosuggest-accept


# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored _match _approximate
zstyle ':completion:*' completions 1
zstyle ':completion:*' insert-unambiguous false
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' menu select=long
zstyle ':completion:*' original true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' substitute 1
# zstyle :compinstall filename '/Users/sudacode/.zshrc'
zstyle :compinstall filename /home/sudacode/.zsh/.zshrc

autoload -Uz compinit
compinit
# End of lines added by compinstall
