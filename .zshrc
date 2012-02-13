
# ------------------------------------------------------------------------------
# env
# ------------------------------------------------------------------------------

export LANG=ja_JP.UTF-8
export PATH=${HOME}/bin:/opt/local/bin:/usr/local/bin:/var/lib/gems/1.9.1/bin/:${PATH}
export GISTY_DIR="$HOME/dev/gists"
export PATH=${PATH}:${HOME}/android/android-sdk-linux_86/tools
fpath=(${HOME}/.zsh/completion ${fpath})

source ${HOME}/.zsh/plugin/incr*.zsh

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
autoload -U colors; colors                            # $fg[blue]

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
# prompt
# ------------------------------------------------------------------------------
# %m ... $HOSTNAME (from begin to first period)
# %n ... $USER
# %L ... $SHLVL
# %(condition.true.false)

setopt prompt_subst # extend format
PROMPT="%(?.%B.%S)%{$fg[yellow]%}[%D{%Y-%m-%d %H:%M:%S}]%{$fg[white]%}:%{$fg[green]%}Lv.%L%{$fg[white]%}:%{$fg[blue]%}%m%{$fg[white]%}:%{$fg[blue]%}%~%{$fg[white]%}%(?.%b.%s)
%{$fg[green]%}%n%{$reset_color%}%(!.#.$) "


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
# /usr/lib/command-not-found
# ------------------------------------------------------------------------------
if [[ -f '/etc/zsh_command_not_found' ]] ; then
  source /etc/zsh_command_not_found
fi

# ------------------------------------------------------------------------------
# rvm
# ------------------------------------------------------------------------------
if [[ -s $HOME/.rvm/scripts/rvm ]] ; then source $HOME/.rvm/scripts/rvm ; fi


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

# ------------------------------------------------------------------------------
# for nave
# ------------------------------------------------------------------------------
function _naverc_check() {
if [[ -f '.naverc' ]] ; then
  source '.naverc'
fi
}

chpwd_functions+=_naverc_check

# ------------------------------------------------------------------------------
# vcs
# ------------------------------------------------------------------------------
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
_vcs_info_msg_on_rprompt () {
    psvar=()
    LANG=en_US.UTF-8 vcs_info
    [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}
precmd_functions+=_vcs_info_msg_on_rprompt

RPROMPT="%1(v|%F{green}%1v%f|)"

# ------------------------------------------------------------------------------
# change upper directory
# ------------------------------------------------------------------------------

function up()
{
    to=$(perl -le '$p=$ENV{PWD}."/";$d="/".$ARGV[0]."/";$r=rindex($p,$d);$r>=0 && print substr($p, 0, $r+length($d))' $1)
    if [ "$to" = "" ]; then
        echo "no such file or directory: $1" 1>&2
        return 1
    fi
    cd $to
}
# ------------------------------------------------------------------------------
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
# extract
# ------------------------------------------------------------------------------

extract () {
  file $1 | grep "HTML document text"
  if [ $? -eq 0 ] ; then
      echo "$1 is not archive file but HTML file!"
      return 1
  fi
  if [ -f $1 ] ; then
      case $1 in
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.tar.xz)    tar xvJf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       unrar x $1     ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *.lzma)      lzma -dv $1    ;;
          *.xz)        xz -dv $1      ;;
          *)           echo "don't know how to extract '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
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
# Emacs
# ------------------------------------------------------------------------------

## Invoke the ``dired'' of current working directory in Emacs buffer.
function dired () {
  emacsclient -e "(dired \"$PWD\")"
}

## Chdir to the ``default-directory'' of currently opened in Emacs buffer.
function cde () {
    EMACS_CWD=`emacsclient -e "
     (expand-file-name
      (with-current-buffer
          (nth 1
               (assoc 'buffer-list
                      (nth 1 (nth 1 (current-frame-configuration)))))
        default-directory))" | sed 's/^"\(.*\)"$/\1/'`

    echo "chdir to $EMACS_CWD"
    cd "$EMACS_CWD"
}

# ------------------------------------------------------------------------------
# GNU SCREEN
# ------------------------------------------------------------------------------
if [ `which tmux` ]; then
    if [ $SHLVL = 1 ]; then # 自動実行
        tmux
    fi
elif [ `which screen` ]; then
    if [ -f $HOME/.zsh_screen ]; then
        source $HOME/.zsh_screen
    fi
    if [ $SHLVL = 1 ]; then # 自動実行
        screen -xR default
    fi
fi


# ------------------------------------------------------------------------------
# long command notify
# ------------------------------------------------------------------------------
local COMMAND=""
local COMMAND_TIME=""
_notify_after_long_command_precmd() {
    if [ "$COMMAND_TIME" -ne "0" ] ; then
        local d=`date +%s`
        d=`expr $d - $COMMAND_TIME`
        if [ "$d" -ge "30" ] ; then
             COMMAND="$COMMAND "
             notify-send "${${(s: :)COMMAND}[1]}" "$COMMAND"
        fi
    fi
    COMMAND="0"
    COMMAND_TIME="0"
}
_notify_after_long_command_preexec () {
    COMMAND="${1}"
    COMMAND_TIME=`date +%s`
}
precmd_functions+=_notify_after_long_command_precmd
preexec_functions+=_notify_after_long_command_preexec


# ------------------------------------------------------------------------------
# scratch .zshrc
# ------------------------------------------------------------------------------
if [ -f $HOME/.zshrc.mine ]; then
    source $HOME/.zshrc.mine
fi

