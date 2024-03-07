#!/bin/sh
#
# Copyright (C) by Aeredren
# Script under the GPLV3 licence. See LICENCE file for details.
#
# Sanity - Set sensible config files for Bash, Tmux and Vim

######## FUNCTIONS DEFINITION ########## 

error_exit()
{
	echo "ERROR $1" >&2
	sanity_help
	exit 1
}

set_current_user()
{
	export current_user=$1
	export current_homedir=$2
}

sanity_help()
{
	cat << EOF

Sanity - Set sensible config files for Bash, Tmux and Vim
sanity.sh [-g|-u] [-n aliases,prompt,zsh] [WORKING DIRECTORY]

EOF
}

########################################
# Clean user config files from Sanity's modification
########################################
sanity_clean()
{
	echo "CLEANING Sanity parameters on $current_user config files"
	sed -ine '/\/\.config\/sanity\//d' $current_homedir/.bashrc $current_homedir/.tmux.conf
}

########################################
# Make dirs and touch files before their modification
# To be run by each user to have the right owner:group and umask
# Variables needed:
#	$current_user
#	$current_homedir
# Returns:
#	1 if users can not change his own files
########################################
sanity_create()
{
	# Let the users create their own files and directories
	echo "INITIALIZING $current_user config files"
	mkdir -p \
		$current_homedir/.config/sanity \
		$current_homedir/.vim/plugin \
		$current_homedir/.local/bin \
		|| return 1
	touch \
		$current_homedir/.bashrc \
		$current_homedir/.tmux.conf \
		$current_homedir/.config/sanity/aliases.bash \
		$current_homedir/.config/sanity/path.bash \
		$current_homedir/.config/sanity/prompt.bash \
		$current_homedir/.config/sanity/sensible.bash \
		$current_homedir/.config/sanity/sensible.tmux \
		$current_homedir/.config/sanity/vim.inputrc \
		$current_homedir/.config/sanity/vim.tmux \
		$current_homedir/.config/sanity/zsh-tab.bash \
		$current_homedir/.vim/plugin/sensible.vim \
		$current_homedir/.local/bin/imavimuser \
		$current_homedir/.local/bin/imanemacsuser \
		|| return 1
}

########################################
# Copy Sanity's files to user's home
# Add "includes" to the user's config files
# Variables needed:
#	$current_user
#	$current_homedir
########################################
sanity_install()
{
	sanity_clean

	echo "SETTING sensible config files for user $current_user"
	cp --no-preserve=mode,ownership \
			-t $current_homedir/.config/sanity \
			$SANITY_DIR/config_files/*
	echo "source $current_homedir/.config/sanity/path.bash" >> $current_homedir/.bashrc

	# vim.sensible
	cp --no-preserve=mode,ownership \
			-t $current_homedir/.vim/plugin \
			$SANITY_DIR/git-submodules/vim-sensible/plugin/sensible.vim

	# tmux.sensible
	cp --no-preserve=mode,ownership \
			-t $current_homedir/.config/sanity \
			$SANITY_DIR/git-submodules/tmux-sensible/sensible.tmux
	echo "run-shell $current_homedir/.config/sanity/sensible.tmux" >> $current_homedir/.tmux.conf
	
	# bash.sensible
	cp --no-preserve=mode,ownership \
			-t $current_homedir/.config/sanity \
			$SANITY_DIR/git-submodules/bash-sensible/sensible.bash
	echo "source $current_homedir/.config/sanity/sensible.bash" >> $current_homedir/.bashrc
	
	# Optionnal bash settings
	if [ -z "${SANITY_NO_ALIASES+x}" ]; then
		echo "ADDING aliases to bashrc"
		echo "source $current_homedir/.config/sanity/aliases.bash" >> $current_homedir/.bashrc
	fi
	if [ -z "${SANITY_NO_PROMPT+x}" ]; then
		echo "ADDING prompt to bashrc"
		echo "source $current_homedir/.config/sanity/prompt.bash" >> $current_homedir/.bashrc
	fi
	if [ -z "${SANITY_NO_ZSH+x}" ]; then
		echo "ADDING zsh-like tab completion to bashrc"
		echo "source $current_homedir/.config/sanity/zsh-tab.bash" >> $current_homedir/.bashrc
	fi

}

########################################
# Removes all Sanity's related files for user
# Variables needed:
#	$current_user
#	$current_homedir
# Returns:
#	1 if user can not removes his own files
########################################
sanity_uninstall()
{
	sanity_clean

	echo "REMOVING sanity files for user $current_user"
	rm -rf \
		$current_homedir/.config/sanity \
		$current_homedir/.vim/plugin/sensible.vim \
		$current_homedir/.local/bin/imavimuser \
		$current_homedir/.local/bin/imanemacsuser \
		|| return 1
}

################# MAIN #################

while getopts ":gun:h" o; do
	case $o in
		g)
			if [ "$(whoami)" != "root" ]; then
				error_exit "-g global option requires root privilege"
			fi
			SANITY_GLOBAL=
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

## Init var and export fn
export current_homedir="$(cd ~ && pwd)"
export current_user="$(whoami)"
export -f sanity_create

## Uninstall use-case
if [ -n "${SANITY_UNINSTALL+x}" ]; then
	sanity_uninstall \
		|| error_exit "$(whoami) can not remove config files for $current_user"
	if [ -n "${SANITY_GLOBAL+x}" ]; then
		echo "START uninstall for all users"
		for n in $(awk -F: '$3 > 999 && $1 != "nobody" { print $1 ":" $6 }' /etc/passwd); do
			set_current_user $(echo $n | tr ':' ' ')
			sanity_uninstall \
				|| echo -e "ERROR $(whoami) can not delete $current_user files\nSkipping $current_user"
		done
	fi
	exit 0
fi

## Checking Sanity's working directory
shift $(($OPTIND - 1))
if [ -n "$1" ]; then
	SANITY_DIR=$1
else
	SANITY_DIR=$(pwd)
fi
ls \
	$SANITY_DIR/config_files/path.bash \
	$SANITY_DIR/git-submodules/vim-sensible/plugin/sensible.vim \
	$SANITY_DIR/git-submodules/tmux-sensible/sensible.tmux \
	$SANITY_DIR/git-submodules/bash-sensible/sensible.bash \
	>/dev/null 2>&1 \
	|| error_exit "Init submodules and specify Sanity's directory as operand"

## Install use-case
sanity_create \
	&& sanity_install \
	|| error_exit "User $current_user can not write its own config files"

if [ -n "${SANITY_GLOBAL+x}" ]; then
	echo "START installing for all user"
	for n in $(awk -F: '$3 > 999 && $1 != "nobody" { print $1 ":" $6 }' /etc/passwd); do
		set_current_user $(echo $n | tr ':' ' ')
		su -p $current_user -c "bash -c sanity_create" \
			&& sanity_install \
			|| echo -e "ERROR User $current_user can not write its own config files\nSkipping $current_user"
	done
fi
