#!/bin/sh

# Initial verification.
# 1) Is Alpine distro
# 2) Is not root
FILE=/etc/os-release 
if ! grep -q alpine "$FILE"; then
    echo "This script was created to run just in Alpine distribution"
    exit 1
fi
if ! [[ "$USER" == root ]]; then
    echo "Please run this script as root"
    exit 1
fi


# Parse parameters
userToCreate="abc"
userPassword=""
UID=1000
TZ="America/Sao_Paulo"
InstallSSH=0
InstallDev=0
pubKeyUrl=https://gist.githubusercontent.com/steel-a/74a1c9bcbdf54a673031aaeeddcd484a/raw/11770b12293043cb06c48ea4314f2b7ee054ba6f/k.txt

varToFill=""
for param in $0 $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10}; do
    if [[ "$param" == "-u" ]]; then
        varToFill="userToCreate"
    elif [[ "$param" == "-p" ]]; then
        varToFill="userPassword"
    elif [[ "$param" == "-tz" ]]; then
        varToFill="TZ"
    elif [[ "$param" == "-rcType" ]]; then
        varToFill="rcType"
    elif [[ "$param" == "-rcUser" ]]; then
        varToFill="rcUser"
    elif [[ "$param" == "-rcPass" ]]; then
        varToFill="rcPass"
    elif [[ "$param" == "-ssh" ]]; then
        InstallSSH=1
    elif [[ "$param" == "-dev" ]]; then
        InstallDev=1
    elif [[ "$varToFill" == "userToCreate" ]]; then
        userToCreate="$param"
        varToFill=""
    elif [[ "$varToFill" == "userPassword" ]]; then
        userPassword="$param"
        varToFill=""
    elif [[ "$varToFill" == "TZ" ]]; then
        TZ="$param"
        varToFill=""
    elif [[ "$varToFill" == "rcType" ]]; then
        rcType="$param"
        varToFill=""
    elif [[ "$varToFill" == "rcUser" ]]; then
        rcUser="$param"
        varToFill=""
    elif [[ "$varToFill" == "rcPass" ]]; then
        rcPass="$param"
        varToFill=""
    fi
done

# Verify rcType, rcUser and rcPass if '-dev' is passed
if [[ "$InstallDev" == 1 ]]; then
    FILE=${userDir}/.config/rclone/rclone.conf
    if ! grep -s -q secrets "$FILE"; then
        if [[ "$rcType" == "" ]]; then echo "Missed parameter '-rcType'"; exit 1; fi
        if [[ "$rcUser" == "" ]]; then echo "Missed parameter '-rcUser'"; exit 1; fi
        if [[ "$rcPass" == "" ]]; then echo "Missed parameter '-rcPass'"; exit 1; fi
    fi
fi

# Get Current Timezone
FILE=/etc/timezone
if [ -f "$FILE" ]; then
    CURRENT_TZ=$(cat /etc/timezone)
else
    CURRENT_TZ=""
    if [[ "$TZ" == "" ]]; then
        echo "Timezone must be set with '-tz' parameter"
        exit 1
    fi
fi
# Install Timezone Data
if ! [[ "$CURRENT_TZ" == "$TZ" ]]; then
    apk add --no-cache --update tzdata 1>/dev/null
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo "$TZ" > /etc/timezone
fi


# If there is a specific version of alpine in repositories, change to latest-stable
sed -i 's/\/v[0-9]\.[0-9]*\//\/latest-stable\//g' /etc/apk/repositories


# Verify if the user exists and create it if necessary
U=$userToCreate
UD=/home/${userToCreate}
if id "$U" >/dev/null 2>&1; then
    echo "User "$U" will not be created because already exists"
else
    echo "User to create: "$U
    if [[ "$userPassword" == "" ]]; then
        echo "User password must to be set with '-p' parameter"
        exit 1
    fi
    adduser \
        --disabled-password \
        --gecos "" \
        --uid "$UID" \
        "$U" \
    && mkdir -p $UD \
    && chown -R $U:$U $UD \
    && echo "$U:${userPassword}" | chpasswd
fi


# Change root password
rootPassword=$(< /dev/random tr -dc _A-Z-a-z-0-9 | head -c 120;echo;)
echo "root:${rootPassword}" | chpasswd

# SSH
if [[ "$InstallSSH" == 1 ]]; then
    apk add --no-cache --update openssh openssh-keygen curl runuser 1>/dev/null
    rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key
    ssh-keygen -A
    mkdir -p /var/run/sshd
    echo "Subsystem       sftp    internal-sftp"    > /etc/ssh/sshd_config.d/ssh
    echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config.d/ssh
    echo "AcceptEnv LANG LC_*"                     >> /etc/ssh/sshd_config.d/ssh
    echo "GatewayPorts no"                         >> /etc/ssh/sshd_config.d/ssh
    echo "ChallengeResponseAuthentication no"      >> /etc/ssh/sshd_config.d/ssh
    echo "KerberosAuthentication no"               >> /etc/ssh/sshd_config.d/ssh
    echo "GSSAPIAuthentication no"                 >> /etc/ssh/sshd_config.d/ssh
    echo "PermitUserEnvironment no"                >> /etc/ssh/sshd_config.d/ssh
    echo "KbdInteractiveAuthentication no"         >> /etc/ssh/sshd_config.d/ssh
    echo "UsePAM no"                               >> /etc/ssh/sshd_config.d/ssh
    echo "PrintMotd no"                            >> /etc/ssh/sshd_config.d/ssh
    echo "PrintLastLog yes"                        >> /etc/ssh/sshd_config.d/ssh
    echo "Protocol 2"                              >> /etc/ssh/sshd_config.d/ssh
    echo "MaxStartups 1:90:10"                     >> /etc/ssh/sshd_config.d/ssh
    echo "LoginGraceTime 20"                       >> /etc/ssh/sshd_config.d/ssh
    echo "MaxSessions 3"                           >> /etc/ssh/sshd_config.d/ssh
    echo "MaxAuthTries 3"                          >> /etc/ssh/sshd_config.d/ssh
    echo "AllowAgentForwarding no"                 >> /etc/ssh/sshd_config.d/ssh
    echo "PermitTunnel no"                         >> /etc/ssh/sshd_config.d/ssh
    echo "X11Forwarding no"                        >> /etc/ssh/sshd_config.d/ssh
    echo "PermitRootLogin no"                      >> /etc/ssh/sshd_config.d/ssh
    echo "PasswordAuthentication no"               >> /etc/ssh/sshd_config.d/ssh
    echo "PermitEmptyPasswords no"                 >> /etc/ssh/sshd_config.d/ssh
    echo "AllowTcpForwarding yes"                  >> /etc/ssh/sshd_config.d/ssh
    echo "AllowUsers $userToCreate"                >> /etc/ssh/sshd_config.d/ssh

    runuser -l $U -c "mkdir -p ${UD}/.ssh && chmod 700 ${UD}/.ssh"
    runuser -l $U -c "curl -o ${UD}/.ssh/authorized_keys $pubKeyUrl 1>/dev/null"
    runuser -l $U -c "chmod 600 ${UD}/.ssh/authorized_keys"
fi

# Dev = Bash Git Tmux Neovim
if [[ "$InstallDev" == 1 ]]; then
    apk --update add --no-cache bash bash-completion shadow starship eza 1>/dev/null
    chsh -s /bin/bash $U
    apk --update add --no-cache tmux neovim python3 py3-pynvim rclone 1>/dev/null
    apk --update add --no-cache git git-lfs nerd-fonts \
        font-jetbrains-mono-vf fontconfig 1>/dev/null
    # Just for Mutt apk --update add --no-cache gpg gpg-agent links mutt

    # Create rclone secrets drive if necessary and copy files to ~/.secrets
    #'    Mandatory files in this drive:'
    #'        /secrets/id_rsa '
    #'        /secrets/.gitconfig'
    FILE=${UD}/.config/rclone/rclone.conf
    if ! grep -s -q secrets "$FILE"; then
        rcCmd="rclone config create secrets ${rcType} user ${rcUser} pass ${rcPass}"
        runuser -l $U -c "touch $FILE && ${rcCmd} 1> /dev/null"
        secDir=${UD}/.secrets
        runuser -l $U -c "mkdir -p $secDir"
        runuser -l $U -c "rclone copy secrets:/secrets/ $secDir"

        # Verify if there are all needed files
        if [ ! -f ${secDir}/id_rsa ]; then echo "Missing [id_rsa]!" && exit 1; fi
        if [ ! -f ${secDir}/.gitconfig ]; then
            echo "Missing [.gitconfig]!"
            exit 1
        fi
        # Copy ID_RSA
        runuser -l $U -c "mv ${UD}/.ssh/id_rsa ${UD}/.ssh/id_rsa.old 2> /dev/null"
        runuser -l $U -c "cp ${secDir}/id_rsa ${UD}/.ssh/"
        runuser -l $U -c "chmod 600 ${UD}/.ssh/id_rsa"
        # Link gitconfig
        runuser -l $U -c "mv ${UD}/.gitconfig ${UD}/.gitconfig.old 2> /dev/null"
        runuser -l $U -c "ln -s ${secDir}/.gitconfig ${UD}/.gitconfig"
    fi

    # Install my dot files
    dotDir=${UD}/.dotfiles
    cfgDir=${UD}/.config

    # Clone my dotFiles from github
    if [ ! -d "$dotDir" ]; then
        runuser -l $U -c "git clone -q git@github.com:steel-a/.dotfiles.git $dotDir"
    fi

    # Link tmux configuration file
    runuser -l $U -c "mkdir -p ${cfgDir}/tmux"
    rm -rf ${cfgDir}/tmux/tmux.conf
    runuser -l $U -c "ln -s ${dotDir}/tmux/tmux.conf ${cfgDir}/tmux/tmux.conf"
    
    # Link nvim configuration file
    runuser -l $U -c "mkdir -p ${cfgDir}/nvim"
    rm -rf ${cfgDir}/nvim/init.vim
    runuser -l $U -c "ln -s ${dotDir}/nvim/init.vim ${cfgDir}/nvim/init.vim"
        
    # Link starship configuration file
    rm -rf ${cfgDir}/starship.toml
    runuser -l $U -c "ln -s ${dotDir}/starship.toml ${cfgDir}/starship.toml"

    # Install VimPlug if plug.vim file doesn't exist
    if [ ! -f ${UD}/.local/share/nvim/site/autoload/plug.vim ]; then
        runuser -l $U -c "curl -fLo ${UD}/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 2> /dev/null"
    fi
    echo "Please run :PlugInstall command inside nvim"

    # Install Tmux Plugins
    tpmURL="https://github.com/tmux-plugins/tpm"
    DIRECTORY=${cfgDir}/tmux/plugins/tpm
    if [ ! -d "$DIRECTORY" ]; then
        runuser -l $U -c "git clone -q $tpmURL ${cfgDir}/tmux/plugins/tpm"
    fi
    echo "Please run 'prefix + I' command inside Tmux"


    # Create alias
    FILE=${UD}/.bashrc 
    if ! grep -q alias "$FILE"; then
        echo "alias ls='eza -l --icons --git -a'" >> $FILE
        echo "alias lt='eza --tree --level=2 --long --icons --git'" >> $FILE
        echo "alias vim='nvim'" >> $FILE
        echo "alias gs='git status'" >> $FILE
        echo "alias ga='git add'" >> $FILE
        echo "alias gc='git commit -m'" >> $FILE
        echo "alias gu='git push'" >> $FILE
        echo "alias gd='git pull'" >> $FILE
    fi

    # Install Starchip Prompt
    if ! grep -q starship "$FILE"; then
        echo 'eval "$(starship init bash)"' >> $FILE
    fi

    # Remove duplicated line in .bash_history
    if ! grep -q .bash_history "$FILE"; then
        echo "sed -i -n 'G; s/\n/&&/; /^\([ -~]*\n\).*\n\1/d; s/\n//; h; P' ~/.bash_history" >> $FILE
    fi

    # Install bash-completion
    if ! grep -q bash_completion.sh "$FILE"; then
        echo 'source /etc/bash/bash_completion.sh' >> $FILE
    fi

    FILE=${UD}/.inputrc 
    if ! grep -q history-search-backward "$FILE"; then
        echo '"\e[A": history-search-backward' >> $FILE
        echo '"\e[B": history-search-forward'  >> $FILE
    fi


    # Call .bashrc in .bash_profile
    FILE=${UD}/.bash_profile 
    if ! grep -q .bashrc "$FILE"; then
        echo 'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' >> $FILE
    fi

    # Make user own all files in user directory
    chown -R $U:$U $UD
fi
