#!/bin/bash

# Initial verification.
# 1) Is Alpine distro
# 2) Is not root
FILE=/etc/os-release 
if ! grep -q alpine "$FILE"; then
    echo "This script was created to run just in Alpine distribution"
    exit 1
fi
if [ ! "$EUID" -ne 0 ]; then
    echo "Please don't run this script as root"
    exit 1
fi

# SSH Server
sudo apk --update add --no-cache openssh
# Bash environment
sudo apk --update add --no-cache bash-completion starship eza
# For daily use
sudo apk --update add --no-cache tmux neovim python3 rclone
# For dev
sudo apk --update add --no-cache git git-lfs nerd-fonts \
    font-jetbrains-mono-vf fontconfig
# For Mutt
sudo apk --update add --no-cache gpg gpg-agent links mutt

# Create drive to get the secrets file
# Mount a drive to ~/.secrets folder
# Specified drive must have:
#    - /secrets/id_rsa
#    - /secrets/.gitconfig
FILE=~/.config/rclone/rclone.conf
if ! grep -q secrets "$FILE"; then
    echo 'Creating rclone drive "secrets" to get sensible files.'
    echo '\n'
    echo '    Mandatory files in this drive:'
    echo '        /secrets/id_rsa '
    echo '        /secrets/.gitconfig'
    read -p "Enter cloud service type for rclone [mega]: " type
    type=${type:-mega}
    read -p "Enter user for this drive: " user
    read -p "Enter password for this drive: " pass
    rclone config create secrets mega user ${user} pass ${pass}
    mkdir -p ~/.secrets
    rclone copy secrets:/secrets/ ~/.secrets
    if [ ! -f ~/.secrets/id_rsa ]; then echo "Missing [id_rsa]!" && exit 1; fi
    if [ ! -f ~/.secrets/.gitconfig ]; then echo "Missing [.gitconfig]!" && exit 1; fi
    # Copy ID_RSA
    mv ~/.ssh/id_rsa ~/.ssh/id_rsa.old 2> /dev/null; \
        cp ~/.secrets/id_rsa ~/.ssh/; chmod 600 ~/.ssh/id_rsa
    # Link gitconfig
    mv ~/.gitconfig ~/.gitconfig.old 2> /dev/null; \
        ln -s  ~/.secrets/.gitconfig ~/.gitconfig
fi



# Install VimPlug if plug.vim file doesn't exist
if [ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]; then
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
fi

# Install Tmux Plugins
DIRECTORY=~/.config/tmux/plugins/tpm
if [ ! -d "$DIRECTORY" ]; then
    echo "*****************************"
    echo "*                           *"
    echo "*   Temux: Run prefix + I   *"
    echo "*                           *"
    echo "*****************************"
    git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi

# Create alias
FILE=~/.bashrc 
if ! grep -q alias "$FILE"; then
    echo "alias ls='eza -l --icons --git -a'" >> ~/.bashrc
    echo "alias lt='eza --tree --level=2 --long --icons --git'" >> ~/.bashrc
    echo "alias vim='nvim'" >> ~/.bashrc
    echo "alias gs='git status'" >> ~/.bashrc
    echo "alias ga='git add'" >> ~/.bashrc
    echo "alias gc='git commit -m'" >> ~/.bashrc
    echo "alias gu='git push'" >> ~/.bashrc
    echo "alias gd='git pull'" >> ~/.bashrc
fi

# Install Starchip Prompt
FILE=~/.bashrc 
if ! grep -q starship "$FILE"; then
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
fi

# Remove duplicated line in .bash_history
FILE=~/.bashrc 
if ! grep -q .bash_history "$FILE"; then
  echo "sed -i -n 'G; s/\n/&&/; /^\([ -~]*\n\).*\n\1/d; s/\n//; h; P' ~/.bash_history" >> ~/.bashrc
fi

# Install bash-completion
FILE=~/.bashrc 
if ! grep -q bash_completion.sh "$FILE"; then
    echo 'source /etc/bash/bash_completion.sh' >> ~/.bashrc
fi
FILE=~/.inputrc 
if ! grep -q history-search-backward "$FILE"; then
    echo '"\e[A": history-search-backward' >> ~/.inputrc
    echo '"\e[B": history-search-forward'  >> ~/.inputrc
fi


# Call .bashrc in .bash_profile
FILE=~/.bash_profile 
if ! grep -q .bashrc "$FILE"; then
    echo 'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' >> ~/.bash_profile
fi

