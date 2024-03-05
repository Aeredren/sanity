#!/bin/bash

## TPUT COLOR CODES
if [ -x "$(command -v tput)" ]; then
	BOLD="$(tput bold)"
	BLACK="$(tput setaf 1)"
	RED="$(tput setaf 1)"
	GREEN="$(tput setaf 2)"
	YELLOW="$(tput setaf 3)"
	BLUE="$(tput setaf 4)"
	MAGENTA="$(tput setaf 5)"
	CYAN="$(tput setaf 6)"
	WHITE="$(tput setaf 7)"
	BR_BLACK="$(tput setaf 8)"
	BR_RED="$(tput setaf 9)"
	BR_GREEN="$(tput setaf 10)"
	BR_YELLOW="$(tput setaf 11)"
	BR_BLUE="$(tput setaf 12)"
	BR_MAGENTA="$(tput setaf 13)"
	BR_CYAN="$(tput setaf 14)"
	BR_WHITE="$(tput setaf 15)"
	RESET="$(tput sgr0)"
fi

## Prompt
use_color=false
if type -P dircolors >/dev/null ; then
	LS_COLORS=
	if [[ -f ~/.dir_colors ]] ; then
		eval "$(dircolors -b ~/.dir_colors)"
	elif [[ -f /etc/DIR_COLORS ]] ; then
		eval "$(dircolors -b /etc/DIR_COLORS)"
	else
		eval "$(dircolors -b)"
	fi

	if [[ -n ${LS_COLORS:+set} ]] ; then
		use_color=true
	else
		unset LS_COLORS
	fi
fi

if ${use_color} ; then
	PS1='\[$BR_GREEN\]\u\[$RESET\]@\H \[$GREEN\]\w\[$RESET\] $(MY_EXIT=$? ; git branch 2> /dev/null | sed -n "s/* \(.*\)/(\1) /p" ; [ $MY_EXIT -ne 0 ] && echo "\[$RED\][\[$RESET$BR_RED\]$MY_EXIT\[$RESET$RED\]]\[$RESET\] ")\$ '
else
	PS1='\u@\H \w $(MY_EXIT=$? ; git branch 2> /dev/null | sed -n "s/* \(.*\)/(\1) /p" ; [ $MY_EXIT -ne 0 ] && echo "[$MY_EXIT]")\$ '
fi

unset use_color sh
