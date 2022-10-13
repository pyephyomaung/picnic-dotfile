#!/bin/bash

# setup lsp dependencies
npm i -g typescript typescript-language-server

# setup emacs
sudo add-apt-repository -y ppa:kelleyk/emacs
sudo apt update

sudo apt remove emacs*
sudo apt install -y silversearcher-ag emacs28
git clone https://github.com/pyephyomaung/.emacs.d.git /workspace/.emacs.d

echo '(load-file "/workspace/.emacs.d/init.el")' >> ~/.emacs
mkdir -p ~/.local/share/fonts
cp /workspace/.emacs.d/*.ttf ~/.local/share/fonts
fc-cache -f -v

emacs --daemon
alias ec="emacs-client -c"

# setup blanket
git clone https://github.picnichealth.com/picnichealth/utilities.git /workspace/utilities
echo '(load-file "/workspace/utilities/blanket/blanket.el")' >> ~/.emacs
