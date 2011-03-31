
# ------------------------------------------------------------------------------
# env
# ------------------------------------------------------------------------------

export LANG=ja_JP.UTF-8
export PATH=${HOME}/bin:/opt/local/bin:/usr/local/bin:/var/lib/gems/1.9.1/bin/:${PATH}
export GISTY_DIR="$HOME/dev/gists"

# $PAGER
if [ `which lv > /dev/null` ]; then
    export PAGER=lv
elif [ `which less > /dev/null` ]; then
    export PAGER=less
fi

# $EDITOR
if [ `which emacs > /dev/null` ]; then
    export EDITOR=emacs
elif [ `which vim > /dev/null` ]; then
    export EDITOR=vim
elif [ `which vi > /dev/null` ]; then
    export EDITOR=vi
fi


# ------------------------------------------------------------------------------
# host
# ------------------------------------------------------------------------------
_cache_hosts=(localhost
 $HOST
#  sv{1..9}.hoge.ne.jp
)

# ------------------------------------------------------------------------------
# Options
# ------------------------------------------------------------------------------
setopt always_to_end
setopt append_history
setopt auto_cd
setopt auto_list
setopt auto_menu
setopt auto_param_keys
setopt auto_param_slash
setopt auto_pushd
setopt auto_remove_slash
setopt no_beep
setopt complete_in_word
setopt interactive_comments # コマンドラインでも#以降をコメントにする
# setopt correct
setopt dvorak
setopt extended_history
setopt glob_complete
setopt glob_dots
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt inc_append_history
setopt list_types
setopt mark_dirs
setopt no_flow_control
setopt pushd_silent
setopt rm_star_silent # do `rm *` without confirm
setopt share_history
setopt magic_equal_subst
# setopt xtrace

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'   # :smart
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} # colored candidates
zstyle ':completion:*:default' menu select=1          # select candidates
WORDCHARS='*?_-.[]~&;!#$%^(){}<>'                     # C-w (stop / =)

#autoload -U compinit; compinit -u                     # complation (-u for cygwin)
autoload -U compinit; compinit                        # complation

# ------------------------------------------------------------------------------
# key bindings
# ------------------------------------------------------------------------------
bindkey -e # emacs

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^P" up-line-or-beginning-search
bindkey "^N" down-line-or-beginning-search

zmodload zsh/complist # for menu
bindkey -M menuselect '^n' down-line-or-history
bindkey -M menuselect '^p' up-line-or-history
bindkey -M menuselect '^o' accept-and-infer-next-history

bindkey '\e/' redo                 # M-/
bindkey '\e<' beginning-of-history # M-<
bindkey '\e>' end-of-history       # M->

bindkey '\e^h' run-help            # M-C-h : help
bindkey '\eh' backward-kill-word   # M-h   : kill

# ------------------------------------------------------------------------------
# color definitions
# ------------------------------------------------------------------------------
local BLACK=$'%{\e[1;30m%}'
local RED=$'%{\e[1;31m%}'
local GREEN=$'%{\e[1;32m%}'
local YELLOW=$'%{\e[1;33m%}'
local BLUE=$'%{\e[1;34m%}'
local PURPLE=$'%{\e[1;35m%}'
local WATER=$'%{\e[1;36m%}'
local WHITE=$'%{\e[1;37m%}'
local DEFAULT=$'%{\e[1;m%}'

# ------------------------------------------------------------------------------
# prompt
# ------------------------------------------------------------------------------
#
# %n ... $USER
# %m ... $HOSTNAME (from begin to first period)

setopt prompt_subst # extend format
PROMPT_ORIG=$PURPLE'[%n@%m] %(!.#.$) '$DEFAULT
PROMPT_ERROR=$RED'[%n@%m] %(!.#.$) '$DEFAULT
RPROMPT=$LIGHT_GRAY'[%~]'$DEFAULT

precmd () {
  PROMPT=%(?.$PROMPT_ORIG.$PROMPT_ERROR)%
}

# ------------------------------------------------------------------------------
# history
# ------------------------------------------------------------------------------
HISTFILE=$HOME/.azsh_history
HISTSIZE=100000
SAVEHIST=100000
function history-all { history -E 1 }

# ------------------------------------------------------------------------------
# lscolor
# ------------------------------------------------------------------------------

if [ -f $HOME/.zsh/ls_colors ]; then
    source $HOME/.zsh/ls_colors
fi


# ------------------------------------------------------------------------------
# alias
# ------------------------------------------------------------------------------

# alias un='unison.sh'

alias pd='popd'  # popd
alias du='du -h'
alias df='df -h'

alias rm='rm -r'
alias mkdir='mkdir -p'
alias cld='cd $_'

# ls
if [ `uname` = "FreeBSD" -o `uname` = "Darwin" ]; then
    if [ `which gls` ]; then
        alias ls="gls -hF --color"
    else
        alias ls="ls -hFG"
    fi
else
    alias ls="ls -hF --color"
fi
alias ll='ls -lapG'
alias l.='ls -d .*'
alias l='ls -lapG'

# screen
alias sc='screen -xR default'
alias sl='screen -ls'
alias sr='screen -r'

# svn
alias svnu='svn update'
alias svnci='svn ci'
alias svnco='svn co'

alias -g ...='../..'
alias -g L='| lv -c'
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g W='| wc'
alias -g LE='|& less'
alias -g HE='|& head'
alias -g TE='|& tail'
alias -g GE='|& grep'
alias -g WE='|& wc'
alias -g SE='|& sed'
alias -g AE='|& awk'

alias -s txt=emacs
alias -s emacs=emacs
alias e='emacsclient --no-wait'

# ssh
# alias ssh1='ssh -t user@host "auto exec command"'

# ------------------------------------------------------------------------------
# Dabbrev
# ------------------------------------------------------------------------------
HARDCOPYFILE=$HOME/tmp/screen-hardcopy
if [ ! -d $HOME/tmp ]; then
    mkdir $HOME/tmp
fi
touch $HARDCOPYFILE
dabbrev-complete () {
        local reply lines=80 # 80行分
        screen -X eval "hardcopy -h $HARDCOPYFILE"
        reply=($(sed '/^$/d' $HARDCOPYFILE | sed '$ d' | tail -$lines))
        compadd - "${reply[@]%[*/=@|]}"
}
zle -C dabbrev-complete menu-complete dabbrev-complete
bindkey '^o' dabbrev-complete
bindkey '^o^_' reverse-menu-complete

# ------------------------------------------------------------------------------
# ls after change directory
# ------------------------------------------------------------------------------
typeset -ga chpwd_functions

function _toriaezu_ls() {
ls -v -F --color=auto
}
chpwd_functions+=_toriaezu_ls


function _change_rprompt {
if [ $PWD = $HOME ]; then
  RPROMPT="[%T]"
else
  RPROMPT="%{$fg_bold[white]%}[%{$reset_color%}%{$fg[cyan]%}%60<..<%~%{$reset_color%}%{$fg_bold[white]%}]%{$reset_color%}"
fi
}
chpwd_functions+=_change_rprompt

# ------------------------------------------------------------------------------
# for nave
# ------------------------------------------------------------------------------
function _naverc_check() {
if [[ -f '.naverc' ]] ; then
  source '.naverc'
fi
}

chpwd_functions+=_naverc_check

# reload .zshrc
# ------------------------------------------------------------------------------
function reload () {
    local j
    jobs  > /tmp/$$-jobs
    j=$(</tmp/$$-jobs)
    if [ "$j" = "" ]; then
	exec zsh
    else
	fg
    fi
}


# ------------------------------------------------------------------------------
# git (by cho45)
# ------------------------------------------------------------------------------

function git(){
    if [[ -e '.svn' ]]; then
	command svn $@ | $PAGER
	echo
	echo "X / _ / X < .svn があったので svn コマンドにしました !"
    else
	if [[ $1 == "" ]]; then
	    # git だけ打った時は status 表示
	    command git branch -a --verbose
	    command git status
	elif [[ $1 == "log" ]]; then
	    # 常に diff を表示してほしい
	    command git log -p ${@[2, -1]}
	else
	    command git $@
	fi
    fi
}

# ------------------------------------------------------------------------------
# GNU SCREEN
# ------------------------------------------------------------------------------
if [ `which screen` ]; then
    if [ -f $HOME/.zsh_screen ]; then
        source $HOME/.zsh_screen
    fi
    if [ $SHLVL = 1 ]; then # 自動実行
        screen -xR default
    fi
fi

# ------------------------------------------------------------------------------
# scratch .zshrc
# ------------------------------------------------------------------------------
if [ -f $HOME/.zshrc.mine ]; then
    source $HOME/.zshrc.mine
fi
