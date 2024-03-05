#!/bin/bash
#
# Copyright (C) by Aeredren
#
# WORK IN PROGRESS ! Not usable at all

mkdir -p ~/.config/sanity

cp -t ~/.config/sanity ./git-submodules/bash-sensible/sensible.bash
echo "source ~/.config/sanity/sensible.bash" >> ~/.bashrc

cp -t ~/.config/sanity ./git-submodules/tmux-sensible/sensible.tmux
echo "run-shell ~/.config/sanity/sensible.tmux" >> ~/.tmux.conf

cp -t ~/.config/sanity ./config_files/*
echo "source ~/.config/sanity/aliases.bash" >> ~/.bashrc
echo "source ~/.config/sanity/prompt.bash" >> ~/.bashrc
echo "source ~/.config/sanity/zsh-tab.bash" >> ~/.bashrc


mkdir -p ~/.vim/plugin
cp -t ~/.vim/plugin ./git-submodules/vim-sensible/plugin/sensible.vim

ADD_PATH=

echo $PATH | grep "/usr/local/bin" && ADD_PATH="$ADD_PATH:/usr/local/bin"
echo $PATH | grep "~/.local/bin" && ADD_PATH="$ADD_PATH:~/.local/bin"

echo "PATH=\$PATH$ADD_PATH" >> ~/.bashrc
