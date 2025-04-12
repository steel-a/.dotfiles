#!/bin/sh

# Must be USER = root and SUDO_USER != root
[ $USER = "root" ] && ! [ $SUDO_USER = "root" ] && exit 0
exit 1

# The 2 options bellow worked in Debian and Alpine
# echo $USER # return root when called as sudo and original user otherwise
# echo $SUDO_USER # return original user when called as sudo, otherwise ""

# The 2 options bellow worked in Debian but not in Alpine
# who am i | awk '{print $1}' # return user tha has called sudo
# logname # always  return user that makes the login

