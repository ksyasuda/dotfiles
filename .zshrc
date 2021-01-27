# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/sudacode/.oh-my-zsh"
export PATH="$HOME/scripts:$PATH"
export EDITOR=vim

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

#POWERLEVEL9K_MODE='nerdfont'
#POWERLEVEL9K_MODE='awesome-fontconfig'
POWERLEVEL9K_MODE='nerdfont-complete'
#POWERLEVEL9K_MODE='awesome-patched, nerdfont-complete'

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="powerlevel9k/powerlevel9k"
ZSH_THEME="powerlevel10k/powerlevel10k"
#ZSH_THEME="random"
#ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder


# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(zsh-autosuggestions zsh-syntax-highlighting colored-man-pages zsh-256color wakatime vi-mode)

source $ZSH/oh-my-zsh.sh
#source ~/.oh-my-zsh/plugins/git/git.plugin.zsh


# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin

# ------------------------------------- POWERLINE CONFIG ----------------------
#POWERLEVEL9K_OS_ICON_BACKGROUND="white"
#POWERLEVEL9K_OS_ICON_FOREGROUND="blue"
POWERLEVEL9K_PROMPT_ON_NEWLINE=true
POWERLEVEL9K_RPROMPT_ON_NEWLINE=false
#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon time battery context dir vcs newline)
#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon battery context newline dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time status root_indicator background_jobs history)
POWERLEVEL9K_DISABLE_RPROMPT=false
POWERLEVEL9K_TIME_BACKGROUND='117'
POWERLEVEL9K_SHORTEN_DIR_LENGTH=3

#POWERLEVEL9K_CUSTOM_NOW_PLAYING='~/.nowplaying'
#POWERLEVEL9K_CUSTOM_NOW_PLAYING_BACKGROUND='blue'
#POWERLEVEL9K_CUSTOM_NOW_PLAYING_FOREGROUND='black'

# Icons
OS_ICON='  Yawnick boi: ﴑ'
POWERLEVEL9K_OS_ICON_BACKGROUND='208'
POWERLEVEL9K_OS_ICON_FOREGROUND='000'
POWERLEVEL9K_VCS_GIT_GITHUB_ICON=' '
POWERLEVEL9K_USER_ICON="\uF415" # 
POWERLEVEL9K_USER_DEFAULT_BACKGROUND='199'

zsh_wifi_signal(){
    local signal=$(nmcli device wifi | grep yes | awk '{print $8}')
    local color='%F{yellow}'
    [[ $signal -gt 75 ]] && color='%F{green}'
    [[ $signal -lt 50 ]] && color='%F{red}'
    echo -n "%{$color%}\uf230  $signal%{%f%}" # \uf230 is 
}
POWERLEVEL9K_CUSTOM_WIFI_SIGNAL="zsh_wifi_signal"
#POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon time user dir vcs virtualenv)
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(battery user dir vcs virtualenv)

POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='↱'
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='↳  Yawnick boi : ﴑ '
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX_BACKGROUND='208'
POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX_FOREGROUND='000'
#POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S \uE868  %d.%m.%y}"



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

 # Set 'context' segment colors
POWERLEVEL9K_CONTEXT_DEFAULT_FOREGROUND='010'
POWERLEVEL9K_CONTEXT_DEFAULT_BACKGROUND='128'

# Set directory icons
POWERLEVEL9K_HOME_ICON='🏠'
POWERLEVEL9K_HOME_SUB_ICON='📂'

# Set dir path colors
#POWERLEVEL9K_DIR_PATH_HIGHLIGHT_BOLD=true
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='033'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='016'
POWERLEVEL9K_DIR_HOME_BACKGROUND='033'
POWERLEVEL9K_DIR_HOME_FOREGROUND='016'
POWERLEVEL9K_DIR_PATH_HILIGHT_FOREGROUND='000'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='033'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='016'
POWERLEVEL9K_DIR_NOT_WRITABLE_BACKGROUND='196'
POWERLEVEL9K_DIR_NOT_WRITABLE_FOREGROUND='016'

# Git configurations
POWERLEVEL9K_SHOW_CHANGESET=true
POWERLEVEL9K_VCS_CLEAN_FOREGROUND='233'
#POWERLEVEL9K_VCS_CLEAN_BACKGROUND='black'
POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='033'
#POWERLEVEL9K_VCS_UNTRACKED_BACKGROUND='black'
POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='197'
#POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='black'
#! -----------------------------------END OF POWERLEVEL CONFIG------------------

#LS_COLORS="di=42;1;30:*.mp3=1;32;41:fi=0;91:*.c=1;96:*.js=1;93:*.h=1;35:ex=1;32:*.html=1;36:*.cpp=1;96:*.txt=1;91:*Makefile=1;35:*.css=1;36:*.as=1;36:ow=1;42;93:*.ttf=0;91:*.png=0;91:*README=4;31:*.jpg=0;91:*.md=4;31:*.json=1;94:*.as=0;35:*.obj=0;35:*.correct=1;94"


LS_COLORS="di=42;1;95:*.mp3=1;32;41:fi=0;91:*.c=1;96:*.js=1;93:*.h=1;35:ex=1;32:*.html=1;36:*.cpp=1;96:*.txt=1;91:*Makefile=1;35:*.css=1;36:*.as=1;36:ow=1;42;93:*.ttf=0;91:*.png=0;91:*README=4;31:*.jpg=0;91:*.md=4;31:*.json=1;94:*.as=0;35:*.obj=0;35:*.correct=1;94"

# # ex = EXtractor for all kinds of archives
# # usage: ex <file>
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


### for use with xserver... causes screenfetch and neofetch to not work unless xserver is running
#export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0.0
#
#sudo /etc/init.d/dbus start &> /dev/null

PS2="===>"

# Add gem to PATH
export PATH=$PATH:/home/sudacode/.gem/ruby/2.7.0/bin

# Add go to PATH
export PATH=$PATH:/home/sudacode/go/bin

alias freud='cd /home/sudacode/'

# Add yarn to PATH
export PATH="$PATH:`yarn global bin`"

# set terminal color to 256 color
export TERM=xterm-256color

export PATH=$PATH:/home/sudacode/.local/bin

# add emacs to path
export PATH=$PATH:/home/sudacode/.emacs.d/bin

#Enable tab completions for flags in colorls
source $(dirname $(gem which colorls))/tab_complete.sh

# add pythno to PATH
export PATH="$PATH:/usr/bin/python"

# add jdk-8 to path
export PATH="$PATH:/usr/lib/jvm/java-8-openjdk/bin"

## ibus config
export GTK_IM_MODULE=ibus
# will make libreoffice work
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
export QT4_IM_MODULE=xim
ibus-daemon -drx

export GTK_IM_MODULE_FILE=/etc/gtk-2.0/gtk.immodules
export GTK_IM_MODULE_FILE=/usr/lib/gtk-3.0/3.0.0/immodules.cache


export VISUAL=vim

# source the Xmodmap file to get custom keybindings
[[ -f ~/.Xmodmap  ]] && xmodmap ~/.Xmodmap

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# ~/scripts/random_starter.sh
