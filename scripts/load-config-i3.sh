FILE=~/.Xresources
DOTFILE=~/.dotfiles/xorg/.Xresources
if ! [[ $(readlink $FILE) ]]; then rm -rf $FILE; ln -s $DOTFILE $FILE 2> /dev/null; fi

FILE=~/.config/user-dirs.dirs
DOTFILE=~/.dotfiles/xorg/user-dirs.dirs
if ! [[ $(readlink $FILE) ]]; then rm -rf $FILE; ln -s $DOTFILE $FILE 2> /dev/null; fi

FILE=~/.config/i3/config
DOTFILE=~/.dotfiles/i3/config
if ! [[ $(readlink $FILE) ]]; then rm -rf $FILE; ln -s $DOTFILE $FILE 2> /dev/null; fi

FILE=~/.config/polybar/config.ini
DOTFILE=~/.dotfiles/polybar/config.ini
if ! [[ $(readlink $FILE) ]]; then rm -rf $FILE; ln -s $DOTFILE $FILE 2> /dev/null; fi

