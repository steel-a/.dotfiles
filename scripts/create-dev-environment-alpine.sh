FILE=/etc/os-release 
if ! grep -q alpine "$FILE"; then
    echo "This script was created to run just in Alpine distribution"
    exit 1
fi

sudo apk --update add --no-cache bash-completion starship eza git git-lfs \
     nerd-fonts tmux neovim python3

# Install VimPlug
if [ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]; then
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
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




