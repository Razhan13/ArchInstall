#!/bin/bash

dialog --infobox "[$(whoami)] Create base folders" 10 60
mkdir -p /home/$(whoami)/Documents
mkdir -p /home/$(whoami)/Downloads

mkdir -p /home/$(whoami)/workspace
mkdir -p /home/$(whoami)/composer

command -v "go" >/dev/null && mkdir -p /home/$(whoami)/workspace/go/bin >/dev/null
command -v "go" >/dev/null && mkdir -p /home/$(whoami)/workspace/go/pkg >/dev/null
command -v "go" >/dev/null &&  mkdir -p /home/$(whoami)/workspace/go/src >/dev/null
command -v "nextcloud" >/dev/null &&  mkdir -p /home/$(whoami)/Nextcloud >/dev/null

# Activate netctl
sudo systemctl enable netctl > /dev/null
sudo systemctl start netctl > /dev/null

#Install an AUR package manually.
aur_install() {
    curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/$1.tar.gz \
    && tar -xvf $1.tar.gz \
    && cd $1 \
    && makepkg --noconfirm -si \
    && cd - \
    && rm -rf $1 $1.tar.gz ;
}

#aur_check runs on each of its arguments, if the argument is not already installed, it either uses yay to install it, or installs it manually.
aur_check() {
    qm=$(pacman -Qm | awk '{print $1}')
    for arg in "$@"
    do
        if [[ $qm != *"$arg"* ]]; then
            yay --noconfirm -S $arg &> /dev/null || aur_install $arg
        fi
    done
}

cd /tmp/
dialog --infobox "[$(whoami)] Installing \"yay\", an AUR helper..." 10 60
aur_check yay

count=$(cat /tmp/aur_queue | wc -l)
c=0
for prog in $(cat /tmp/aur_queue)
do
    c=$((c+1))
    dialog --infobox "[$(whoami)] AUR install - Downloading and installing program $c out of $count: $prog..." 10 60
    aur_check $prog
done


DOTFILES=/home/$(whoami)/.dotfiles
if [ ! -d $DOTFILES ];
    then
        dialog --infobox "[$(whoami)] Downloading .dotfiles..." 10 60
        git clone --recurse-submodules https://github.com/Phantas0s/.dotfiles.git $DOTFILES >/dev/null
fi

source /home/$(whoami)/.dotfiles/zsh/zshenv
cd $DOTFILES
(command -v "zsh" >/dev/null && zsh ./install.sh -y) || sh ./install.sh -y

# TODO doesn't really work... to fix
# dialog --infobox "[$(whoami)] Install composer global tools" 10 60
# composer global update
