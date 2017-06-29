set -a
# OSX: chsh -s /usr/local/bin/bash

PATH=/usr/local/bin:${PATH}
export PATH

# Please put all environment variables in .bash_profile
#######################################################
if [ `basename ${SHELL}`"x" != bash"x" ]; then
    SHELL=`which bash`
    exec ${SHELL} --login $*
else
    if [ -x /usr/local/bin/bash ]; then
       exec /usr/local/bin/bash -l
   fi
fi
#######################################################
# EOF
