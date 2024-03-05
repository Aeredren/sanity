#!/bin/sh
#
# Copyright (C) by Aeredren
#
# WORK IN PROGRESS ! Not usable at all

deploy()
{
	mkdir -p ~/.config/sanity
	
	cp -t ~/.config/sanity ./git-submodules/bash-sensible/sensible.bash
	echo "source ~/.config/sanity/sensible.bash" >> ~/.bashrc
	
	cp -t ~/.config/sanity ./git-submodules/tmux-sensible/sensible.tmux
	echo "run-shell ~/.config/sanity/sensible.tmux" >> ~/.tmux.conf
	
	cp -t ~/.config/sanity ./config_files/*
	echo "source ~/.config/sanity/aliases.bash" >> ~/.bashrc
	echo "source ~/.config/sanity/prompt.bash" >> ~/.bashrc
	echo "source ~/.config/sanity/zsh-tab.bash" >> ~/.bashrc
	echo "source ~/.config/sanity/path.bash" >> ~/.bashrc
	
	
	mkdir -p ~/.vim/plugin
	cp -t ~/.vim/plugin ./git-submodules/vim-sensible/plugin/sensible.vim
}

sanity_help()
{
	echo HEEEELP
}

dummy()
{
whoami
pwd
}

sanity_uninstall()
{
	return 42
}

while getopts ":gun:h" o; do
	case $o in
		g)
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
						echo "Invalid option argument: -n $n" >&2
						sanity_help
						exit 1
				esac

			done
			;;
		h)
			sanity_help
			exit 0
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			sanity_help
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument" >&2
			sanity_help
			exit 1
			;;
	esac
done	

if [ -n "${SANITY_UNINSTALL+x}" ]; then
	sanity_uninstall
	exit $?
fi
