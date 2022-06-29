if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

LS_COLORS="di=42;1;90:*.mp3=1;32;41:fi=0;91:*.c=1;96:*.js=1;93:*.h=1;35:ex=1;32:*.html=1;36:*.cpp=1;96:*.txt=1;91:*Makefile=1;95:*.css=1;36:*.as=1;36:ow=1;42;93:*.ttf=0;91:*.png=0;91:*README=4;31:*.jpg=0;91:*.md=4;31:*.json=1;94:*.as=0;35:*.obj=0;35:*.correct=1;94:*.py=1;91:*.ipynb=3;91"
PS2="===>"

# ex = EXtractor for all kinds of archives
# usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1   ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *.deb)       ar x $1      ;;
      *.tar.xz)    tar xf $1    ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

get_git_commit_hash() {
	git rev-parse HEAD | cut -c -12
}


# export CLASSPATH="$CLASSPATH:/usr/share/java/mariadb-jdbc/mariadb-java-client.jar"
# export EDITOR=vim
# export FZF_DEFAULT_COMMAND='fd --type f --follow --exclude .git'
# export FZF_DEFAULT_COMMAND='fd --type f'
# export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# export PATH="$PATH:/usr/lib/jvm/java-8-openjdk/bin"
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
# export VISUAL=vim
export ARCHFLAGS="-arch x86_64"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export EDITOR=nvim
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GOPATH="$XDG_DATA_HOME"/go
export GRIPHOME="$XDG_CONFIG_HOME/grip"
export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-1.0/gtkrc
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter
export LANG=en_US.UTF-8
export MANPAGER='nvim +Man!'
export MANPATH="/usr/local/man:$MANPATH"
export MINIKUBE_HOME="$XDG_DATA_HOME"/minikube
export MPLAYER_HOME="$XDG_CONFIG_HOME"/mplayer
export MYSQL_HISTFILE="$XDG_DATA_HOME"/mysql_history
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/Projects/Python/Sudasong/src/:$PATH"
export PATH="$HOME/Work/rofi/:$PATH"
export PATH="$HOME/Work/scripts:$PATH"
export PATH="$HOME/scripts:$PATH"
export PATH=$PATH:/home/sudacode/.emacs.d/bin
export PYTHONSTARTUP="${XDG_CONFIG_HOME}/python/pythonrc"
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export SQLITE_HISTORY="$XDG_CACHE_HOME"/sqlite_history
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/yubikey-agent/yubikey-agent.sock"
export TERM=xterm-256color
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo
export VISUAL=nvim
export WORKON_HOME="$XDG_DATA_HOME/virtualenvs"
export XDG_CACHE_DIR="$HOME/.cache"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export ZSH="$HOME/.oh-my-zsh"
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export _Z_DATA="$XDG_DATA_HOME/z"
## ibus config
# export GTK_IM_MODULE=ibus
# # will make libreoffice work
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
export QT4_IM_MODULE=xim
export GLFW_IM_MODULE=ibus
ibus-daemon -drx

# export SPACESHIP_TIME_SHOW=true
# export SPACESHIP_GCLOUD_SHOW=false
# export SPACESHIP_EXIT_CODE_SHOW=true
# export SPACESHIP_TIME_COLOR=blue
# export SPACESHIP_VENV_PREFIX=" "
# export SPACESHIP_DIR_TRUNC=0
# eval spaceship_vi_mode_enable


bindkey '^ ' autosuggest-accept

if [ -f ~/.bash_aliases ]; then
	. $HOME/.bash_aliases
fi
if [ -f ~/.aliases ]; then
	. $HOME/.aliases
fi
if [ -f ~/Work/.aliases ]; then
	. $HOME/Work/.aliases
fi

#POWERLEVEL9K_MODE='nerdfont'
#POWERLEVEL9K_MODE='awesome-fontconfig'
POWERLEVEL9K_MODE='nerdfont-complete'
#POWERLEVEL9K_MODE='awesome-patched, nerdfont-complete'

ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_THEME="random"
# ZSH_THEMES="spaceship"
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"
# DISABLE_AUTO_UPDATE="true"
# DISABLE_UPDATE_PROMPT="true"
# export UPDATE_ZSH_DAYS=13
# DISABLE_MAGIC_FUNCTIONS=true
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="false"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"
HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoreboth

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(zsh-autosuggestions zsh-syntax-highlighting vi-mode git zsh-z)

source $ZSH/oh-my-zsh.sh

# set battery stages and colors
POWERLEVEL9K_BATTERY_STAGES=(
   $'▏    ▏' $'▎    ▏' $'▍    ▏' $'▌    ▏' $'▋    ▏' $'▊    ▏' $'▉    ▏' $'█    ▏'
   $'█▏   ▏' $'█▎   ▏' $'█▍   ▏' $'█▌   ▏' $'█▋   ▏' $'█▊   ▏' $'█▉   ▏' $'██   ▏'
   $'██   ▏' $'██▎  ▏' $'██▍  ▏' $'██▌  ▏' $'██▋  ▏' $'██▊  ▏' $'██▉  ▏' $'███  ▏'
   $'███  ▏' $'███▎ ▏' $'███▍ ▏' $'███▌ ▏' $'███▋ ▏' $'███▊ ▏' $'███▉ ▏' $'████ ▏'
   $'████ ▏' $'████▎▏' $'████▍▏' $'████▌▏' $'████▋▏' $'████▊▏' $'████▉▏' $'█████▏' )

POWERLEVEL9K_BATTERY_LEVEL_BACKGROUND=(red3 darkorange3 darkgoldenrod gold3 yellow3 chartreuse2 mediumspringgreen green3 green3 green4 darkgreen)
POWERLEVEL9K_BATTERY_CHARGING_FOREGROUND=green3
POWERLEVEL9K_BATTERY_LOW_FOREGROUND='226'
POWERLEVEL9K_BATTERY_CHARGED_FOREGROUND='021'
POWERLEVEL9K_BATTERY_DISCONNECTED_FOREGROUND='021'
POWERLEVEL9K_BATTERY_LOW_THRESHOLD=20
POWERLEVEL9K_BATTERY_VERBOSE=true

source $(dirname $(gem which colorls))/tab_complete.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# added by Snowflake SnowSQL installer
export PATH=/home/sudacode/.bin:$PATH

eval $(thefuck --alias)
