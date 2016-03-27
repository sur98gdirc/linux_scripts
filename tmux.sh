# this file should be sourced from bashrc

function tm_my
{
    if [ -z "$TMUX" ] && [ "$TERM" != 'screen' ] ;  then
        printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "tmux"
        export TMUX_USER=$USER
        export TMUX_HOSTNAME=${HOSTNAME%%.*}
        tmux attach || tmux new
    else
        echo >&2 "already in tmux"
    fi
}

function tm_prompt
{
    PR_USER=$USER
    PR_HOSTNAME=${HOSTNAME%%.*}
    if [ "$PR_USER" = "$TMUX_USER" ] ; then
        PR_USER=
    fi
    if [ "$PR_HOSTNAME" = "$TMUX_HOSTNAME" ] ; then
        PR_HOSTNAME=
    fi
    printf "\033k%s@%s:%s\033\\" "${PR_USER}" "${PR_HOSTNAME}" "$1"
    #tmux set -q automatic-rename off
}

alias tm='tm_my'

if [ "$PS1" ]; then
  PS1='[\u@\h \w]\$ '

    case $TERM in
    screen*)
      PROMPT_COMMAND='tm_prompt "${PWD/#$HOME/~}"'
      alias mc='tm_prompt "mc" ; mc'
      alias man='tm_prompt "man" ; man'
      ;;
    *)
      ;;
    esac
fi

