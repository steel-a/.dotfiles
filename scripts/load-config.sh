#!/bin/sh

# Função para criar links simbólicos
create_symlink() {
    FILE=$1
    DOTFILE=$2

    if ! [ "$(readlink "$FILE")" ]; then
        rm -rf "$FILE"
        ln -s "$DOTFILE" "$FILE" 2> /dev/null
    fi
}

# Função para verificar e adicionar uma linha a um arquivo
add_line_to_file() {
    LINE=$1
    FILE=$2

    if ! grep -Fxq "$LINE" "$FILE"; then
        echo "$LINE" >> "$FILE"
        echo "Linha adicionada ao $FILE."
    else
        echo "A linha já existe em $FILE."
    fi
}

# Função para criar links no ambiente Xorg
xorg() {
    create_symlink ~/.Xresources ~/.dotfiles/xorg/.Xresources
    create_symlink ~/.config/i3/config ~/.dotfiles/i3/config
    create_symlink ~/.config/polybar/config.ini ~/.dotfiles/polybar/config.ini
}

# Função para criar links no ambiente Wayland (a ser implementado)
wayland() {
    create_symlink ~/.XCompose ~/.dotfiles/.XCompose
    mkdir -p ~/.config/hypr
    create_symlink ~/.config/hypr/hyprland.conf ~/.dotfiles/hypr/hyprland.conf
    create_symlink ~/.config/hypr/hyprpaper.conf ~/.dotfiles/hypr/hyprpaper.conf
    create_symlink ~/.config/hypr/wallpaper.sh ~/.dotfiles/hypr/wallpaper.sh
    mkdir -p ~/.config/waybar
    create_symlink ~/.config/waybar/config.jsonc ~/.dotfiles/waybar/config.jsonc
    create_symlink ~/.config/waybar/style.css ~/.dotfiles/waybar/style.css
}

# Main
# Criar links simbólicos comuns a ambos os ambientes
create_symlink ~/.secrets/.gitconfig ~/.gitconfig
create_symlink ~/.config/user-dirs.dirs ~/.dotfiles/xorg/user-dirs.dirs
create_symlink ~/.config/nvim ~/.dotfiles/nvim
mkdir -p ~/.config/kitty
create_symlink ~/.config/kitty/kitty.conf ~/.dotfiles/kitty/kitty.conf
mkdir -p ~/.config/lf
create_symlink ~/.config/lf/lfrc ~/.dotfiles/lf/lfrc
create_symlink ~/.config/lf/clean.sh ~/.dotfiles/lf/clean.sh
create_symlink ~/.config/lf/preview.sh ~/.dotfiles/lf/preview.sh
create_symlink ~/.config/lf/icons ~/.dotfiles/lf/icons
mkdir -p ~/.config/tmux
create_symlink ~/.config/tmux/tmux.conf ~/.dotfiles/tmux/tmux.conf

~/.dotfiles/scripts/bin/setup_pywal.sh
add_line_to_file "test -s ~/.dotfiles/.alias && . ~/.dotfiles/.alias || true" ~/.bashrc

# Chamando apenas as funções específicas para o ambiente em execução
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    xorg
elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    wayland
else
    echo "Ambiente não identificado"
fi
