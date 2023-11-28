#!/bin/bash

# install emacs config
git clone https://github.com/pyephyomaung/.emacs.d.git /workspace/.emacs.d
mkdir -p ~/.local/share/fonts
cp /workspace/.emacs.d/*.ttf ~/.local/share/fonts
fc-cache -f -v

ln -s /home/gitpod/.dotfiles/.emacs /home/gitpod/.emacs

mkdir -p /workspace/.emacs.d
ln -s /workspace/.emacs.d /home/gitpod/.emacs.d

# install lsp dependencies
npm i -g typescript typescript-language-server
pip3 install 'python-lsp-server[all]' pylsp-mypy

# update brew
brew update

# install system dependencies for emacs
HOMEBREW_NO_AUTO_UPDATE=1 brew install emacs the_silver_searcher
