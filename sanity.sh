#!/bin/sh
#
# Copyright (C) by Aeredren
#
# WORK IN PROGRESS ! Not usable at all

## FUNCTIONS DEFINITION

error_exit()
{
	echo $1 >&2
	sanity_help
	exit 1
}

get_user_homedir()
{
	awk -F: "\$1 == \"$1\" { print \$6 }" /etc/passwd
}

sanity_help()
{
	cat << EOF

Sanity - Set sensible config files for Bash, Tmux and Vim
sanity.sh [-g|-u] [-n aliases,prompt,zsh] [WORKING DIRECTORY]

EOF
}

sanity_clean()
{
	echo "CLEANING Sanity parameters on $(whoami) config files"
	sed -ine '/\/\.config\/sanity\//d' $work_homedir/.bashrc $work_homedir/.tmux.conf
}

sanity_install()
{
	sanity_clean
	echo "SETTING sensible config files for user $(whoami)"
	mkdir -p $work_homedir/.config/sanity
	cp -t $work_homedir/.config/sanity $SANITY_DIR/config_files/*
	echo "source $work_homedir/.config/sanity/path.bash" >> $work_homedir/.bashrc

	# vim.sensible
	mkdir -p $work_homedir/.vim/plugin
	cp -t $work_homedir/.vim/plugin $SANITY_DIR/git-submodules/vim-sensible/plugin/sensible.vim

	# tmux.sensible
	cp -t $work_homedir/.config/sanity $SANITY_DIR/git-submodules/tmux-sensible/sensible.tmux
	echo "run-shell $work_homedir/.config/sanity/sensible.tmux" >> $work_homedir/.tmux.conf
	
	# bash.sensible
	cp -t $work_homedir/.config/sanity $SANITY_DIR/git-submodules/bash-sensible/sensible.bash
	echo "source $work_homedir/.config/sanity/sensible.bash" >> $work_homedir/.bashrc
	
	# Optionnal bash settings
	if [ -z "${SANITY_NO_ALIASES+x}" ]; then
		echo "ADDING aliases to bashrc"
		echo "source $work_homedir/.config/sanity/aliases.bash" >> $work_homedir/.bashrc
	fi
	if [ -z "${SANITY_NO_PROMPT+x}" ]; then
		echo "ADDING prompt to bashrc"
		echo "source $work_homedir/.config/sanity/prompt.bash" >> $work_homedir/.bashrc
	fi
	if [ -z "${SANITY_NO_ZSH+x}" ]; then
		echo "ADDING zsh-like tab completion to bashrc"
		echo "source $work_homedir/.config/sanity/zsh-tab.bash" >> $work_homedir/.bashrc
	fi

	echo "DONE"
}

sanity_uninstall()
{
	sanity_clean

	echo "REMOVING sanity files for user $(whoami)"
	rm -rf $work_homedir/.config/sanity
	rm -f $work_homedir/.vim/plugin/sensible.vim
	rm -f $work_homedir/.local/bin/imavimuser $work_homedir/.local/bin/imanemacsuser 
}

## MAIN

while getopts ":gun:h" o; do
	case $o in
		g)
			if [ "$(whoami)" != "root" ]; then
				error_exit "-g global option requires root privilege"
			fi
			SANITY_GLOBAL=
			awk -F: '$3 > 999 && $1 != "nobody" { print $1 "," $6 }' /etc/passwd
			;;
		u)
			SANITY_UNINSTALL=
			;;
		n)
			for n in $(echo $OPTARG | tr ',' ' '); do
				case $n in
					aliases)
						SANITY_NO_ALIASES=
						;;
					prompt)
						SANITY_NO_PROMPT=
						;;
					zsh)
						SANITY_NO_ZSH=
						;;
					*)
						error_exit "Invalid option argument: -n $n"
				esac

			done
			;;
		h)
			sanity_help
			exit 0
			;;
		\?)
			error_exit "Invalid option: -$OPTARG"
			;;
		:)
			error_exit "Option -$OPTARG requires an argument"
			;;
	esac
done	

work_homedir="$(get_user_homedir $(whoami))"

if [ -n "${SANITY_UNINSTALL+x}" ]; then
	sanity_uninstall
	if [ -n "${SANITY_GLOBAL+x}" ]; then
		echo "uninstall for all users"
	fi
	exit 0
fi

# Operand is for specifying Sanity's dir
shift $(($OPTIND - 1))
if [ -n "$1" ]; then
	SANITY_DIR=$1
else
	SANITY_DIR=$(pwd)
fi
# Test if we have a Sanity dir
ls \
	$SANITY_DIR/config_files/path.bash \
	$SANITY_DIR/git-submodules/vim-sensible/plugin/sensible.vim \
	$SANITY_DIR/git-submodules/tmux-sensible/sensible.tmux \
	$SANITY_DIR/git-submodules/bash-sensible/sensible.bash \
	>/dev/null 2>&1 || error_exit "Init submodules and specify Sanity directory as operand"

sanity_install
if [ -n "${SANITY_GLOBAL+x}" ]; then
	echo "install for all user"
fi
