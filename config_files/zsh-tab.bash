#!/bin/bash

# zsh like completion
shopt -s no_empty_cmd_completion
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
