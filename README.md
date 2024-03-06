This project, albeit small, is still an early Work in progress.

The following Readme is a Roadmap and not the actual features.

# Sanity

sanity.sh \[-g|-u\] \[-n aliases,prompt,zsh\] \[WORKING DIRECTORY\]

Set sensible config files for Bash, Tmux and Vim

Init the git-submodules for bash.sensible, tmux.sensible and vim.sensible, run
sanity.sh and let the magic happened.

Its use case is configuring offline shared linux computers like the one we
uses on labs and testing environment. Your coworkers and yourself won't need to
struggle anymore with a clumsy unconfigured Bash TTY.

You are a vim poweruser and want vim-keybinding everywhere despite the fact your
coworkers edit config files in Nano ? Sanity got you covered too ! It comes with
the `imavimuser` script which reconfig Bash and Tmux in vim mode on the fly.
Just run `imanemacsuser` when you're done and everything come back to normal.

## USAGE

Clone Sanity's git repository on your USB-Stick, initialise the git-submodules to
get the latest "sensibles" configs, mount the stick on any computer and run
sanity.sh.

## OPTIONS

```
-g 
    Deploy configurations for all users with login capabilities. (By default,
    only deploy for the active user)

-u
    Clean uninstall of all Sanity's related files

-n [aliases,prompt,zsh]
	Does not add the specified features (a few aliases, a colourfull prompt,
    zsh-like tab completion)

-h
    Display a summary of available options
    
```

## IMAVIMUSER

`imavimuser` overwrite Bash and Tmux default "Emacs" mod on the fly and bring a
comfortable experience to vim powerusers. It also swap the Escape and Caps_Lock
key on Xorg **and** TTY.

Its options are :

```
-g
	Set Vimmode for all users

-n
	Do not swap Escape and Caps_Lock
```

It comes with its alter-ego script : `imanemacsuser`, which have the same options,
and revert the config back to "normal" mode.

## FILES

TO-DO
```
/run/local/bin/imavimuser
/run/local/bin/imanemacsuser
	Globally installed imavimuser scripts. (with sanity.sh -g as root)

~/.local/bin/imavimuser
~/.local/bin/imanemacsuser
	Locally installed imavimuser scripts.

~/.config/sanity/aliases.bash
~/.config/sanity/prompt.bash
~/.config/sanity/zsh-tab.bash
	Config files to add a few aliases, a colorfull prompt and zsh-like tab
	completion. When uninstall with the corresponding options flags, the file
	are not suppressed, it just remove the line sourcing them at the end of
	the users .bashrc.

~/.config/sanity/sensible.bash
	mrzool's bash-sensible config. This file is just sourced at the end of the 
	user's .bashrc.

~/.config/sanity/vim.inputrc
	inputrc vim mapping. This file is imported at the end of the user's .inputrc
	when imavimuser is triggered.

~/.vim/plugin/sensible.vim
	tpope's sensible.vim config plugin.

~/.config/sanity/sensible.tmux
	tmux-plugins' tmux-sensible config plugin.

~/.config/sanity/vim.tmux
	tmux vim mapping. This file is imported with 'run-shell' at the end of the
	user's .tmux.conf when imavimuser is triggered.
```
## OTHER

Sanity also add ~/.local/bin and /usr/local/bin to PATH for imavimuser to be accessible

Sanity dependencies :

- bash
- getopt
- sed

You will also need git to pull submodules.

```
- "But this ain't a readme, it's a manpage !"
- "Yep!"
```
