[[ $- != *i* ]] && return

HISTSIZE=5000
HISTCONTROL=ignoreboth
shopt -s checkwinsize

alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'
alias netmenu='nmtui'

[ -f /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
command -v starship >/dev/null && eval "$(starship init bash)"
