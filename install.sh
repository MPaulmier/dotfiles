#!/bin/sh

stow bash
stow git
stow x-system
stow awesome

mkdir -p $HOME/.bin
ln -t $HOME/.bin bin/*

# Write git config with env variables
# Needs $NAME and $EMAIL to be set

echo "[commit]
	template = ~/.gitmessage
[user]
	name = $NAME
	email = $EMAIL
" >> $HOME/.gitconfig
