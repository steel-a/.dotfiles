#!/bin/sh

if ! [ $USER = "root" ] || [ $SUDO_USER = "root" ] || [ $SUDO_USER = "" ]; then
  echo "Please run this script with sudo with a non root user"
  exit 1
fi

create_simlink()
{
FILE=$2
DOTFILE=$1
if ! [[ $(readlink $FILE) ]]; then rm -rf $FILE; ln -s $DOTFILE $FILE 2> /dev/null; fi
}

is_rclone_installed()
{
  if rclone --version 2>/dev/null |grep -q rclone; then
    return 0
  else
    return 1
  fi
}

test_secret()
{
  if rclone size secrets: 2>/dev/null |grep -q "Total\ size"; then
    return 0
  else
    return 1
  fi
}

mount_secret()
{
  local TYPE=$1
  local USER=$2
  local PASS=$3
  rclone config create secrets $TYPE user $USER pass $PASS

  test_secret
  return $?
}

getParamsFromUser()
{
  read -p "Enter cloud service type for rclone [mega]: " type
  type=${type:-mega}
  read -p "Enter user for this drive: " user
  read -p "Enter password for this drive: " pass
}

# Start of main script

userScope()
{

  # Test. If already confgured, skip this block
  test_secret
  if [ $? = 0 ]; then
    echo "Secrets drive already set. Skipp this step..."
  else
    # If params are not passed, call function to get them from user
    if ! ( [ ! -z "${1}" ] && [ ! -z "${2}" ] && [ ! -z "${3}" ] ); then
      getParamsFromUser
    else
      type=${1}
      user=${2}
      pass=${3}
    fi 
    mount_secret $type $user $pass
    [ $? = 1 ] && exit 1

    # Create directory
    mkdir -p ~/.secrets
    rclone copy secrets:/secrets/ ~/.secrets
    if [ ! -f ~/.secrets/id_rsa ]; then echo "Missing [id_rsa]!" && return 1; fi
    if [ ! -f ~/.secrets/.gitconfig ]; then echo "Missing [.gitconfig]!" && return 1; fi
    # Copy ID_RSA
    rm ~/.ssh/id_rsa 2> /dev/null
    cp ~/.secrets/id_rsa ~/.ssh/
    chmod 600 ~/.ssh/id_rsa
    # Link gitconfig
    create_simlink ~/.secrets/.gitconfig ~/.gitconfig

    return 0
  fi
}

is_rclone_installed
[ $? = 1 ] && echo "Instalar rclone"
is_rclone_installed
[ $? = 1 ] && echo "Error installing Rclone" && exit 1
echo $?

exit 0





exit 0


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
fi
