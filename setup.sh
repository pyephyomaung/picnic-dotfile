#!/bin/bash

brew install emacs the_silver_searcher

# setup lsp dependencies
npm i -g typescript typescript-language-server

git clone https://github.com/pyephyomaung/.emacs.d.git /workspace/.emacs.d
mkdir -p ~/.local/share/fonts
cp /workspace/.emacs.d/*.ttf ~/.local/share/fonts
fc-cache -f -v

cp /home/gitpod/.dotfiles/.emacs /home/gitpod/
cp /home/gitpod/.dotfiles/.emacs.d /home/gitpod/

# setup blanket
# git clone https://github.picnichealth.com/picnichealth/utilities.git /workspace/utilities
# echo '(load-file "/workspace/utilities/blanket/blanket.el")' >> ~/.emacs
