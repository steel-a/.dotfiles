# Other options
who am i | awk '{print $1}' # return user tha has called sudo
echo $USER # return root when called as sudo and original user otherwise
echo $SUDO_USER # return original user when called as sudo, otherwise ""
logname # always  return user that makes the login
