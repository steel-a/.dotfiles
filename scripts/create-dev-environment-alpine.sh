FILE=/etc/os-release 
if ! grep -q alpine "$FILE"; then
    echo "This script was created to run just in Alpine distribution"
    exit 1
fi

sudo apk --update add --no-cache starship eza git git-lfs nerd-fonts tmux neovim python3

# Create alias
FILE=~/.bashrc 
if ! grep -q alias "$FILE"; then
    echo "alias ls='eza -l --icons --git -a'" >> ~/.bashrc
    echo "alias lt='eza --tree --level=2 --long --icons --git'" >> ~/.bashrc
    echo "alias vim='nvim'" >> ~/.bashrc
fi
# Install Starchip Prompt
FILE=~/.bashrc 
if ! grep -q starship "$FILE"; then
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
fi
FILE=~/.bash_profile 
if ! grep -q .bashrc "$FILE"; then
    echo 'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' >> ~/.bash_profile
fi




