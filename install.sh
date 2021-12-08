#!/bin/sh

stow bash
stow git
stow x-system
stow awesome

mkdir -p $HOME/.bin
ln -t $HOME/.bin bin/*
