#!/bin/bash

if [ -n "$CODER" ]; then
    git clone https://github.com/pyephyomaung/.emacs.d.git /home/coder/.emacs.d
    mkdir -p ~/.local/share/fonts
    cp /home/coder/.emacs.d/*.ttf ~/.local/share/fonts
    fc-cache -f -v

    echo '(load-file "/workspace/.emacs.d/init.el")' > /home/coder/.emacs
    echo '(load-file "/home/coder/.config/coderv2/dotfiles/blanket/blanket.el")' >> /home/coder/.emacs

    # install lsp dependencies
    npm i -g typescript typescript-language-server
    pip3 install 'python-lsp-server[all]' pylsp-mypy

    sudo apt install emacs ncurses-term ripgrep -y
    export TERM=xterm-direct
else
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

    # skip mail questions during postfix in apt install
    export DEBIAN_FRONTEND=noninteractive

    # install emacs
    sudo add-apt-repository ppa:ubuntuhandbook1/emacs -y
    sudo apt install emacs-nox ncurses-term -y
fi
