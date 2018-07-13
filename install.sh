#!/bin/bash
# @file		install.sh
# @author	Sebastien LEGRAND
# @date		2010-07-11
#
# @brief	Install the new BASH profile
# @history
#			2010-07-11 - 1.0.0 - SLE
#			Initial Version

#------ globals

ROOT_DIR=${HOME}/.bashrc.d

DATE=$(date "+%Y%m%d-%H%M%S")
BACKUP_DIR=${HOME}/.save/${DATE}

#------ begin

# special case to create the archive
if [ "$1" == "create" ]; then
    if [ ! -x /usr/bin/zip ]; then
        echo "Cannot create the archive. zip not found!"
        exit 1
    fi
    [[ -e bashrc.zip ]] && rm -f bashrc.zip
    /usr/bin/zip -r bashrc.zip .bashrc .bashrc.d install.sh
    exit
fi

# create the backup directory
echo "Backup files will be stored in [${BACKUP_DIR}]"
mkdir -p ${BACKUP_DIR}

# copy the files
echo "Creating a backup of the files ..."
[[ -e ${HOME}/.bashrc ]] && cp ${HOME}/.bashrc ${BACKUP_DIR}
[[ -e ${HOME}/.bash_logout ]] && cp ${HOME}/.bash_logout ${BACKUP_DIR}
[[ -e ${HOME}/.bash_profile ]] && cp ${HOME}/.bash_profile ${BACKUP_DIR}
[[ -e ${HOME}/.profile ]] && cp ${HOME}/.profile ${BACKUP_DIR}
[[ -d ${HOME}/.bashrc.d ]] && cp -R ${HOME}/.bashrc.d/ ${BACKUP_DIR}

# install the new files
echo "Installing new files ..."
[[ -d ${HOME}/.bashrc.d ]] && rm -rf ${HOME}/.bashrc.d
cp -R .bashrc.d ${HOME}
cp .bashrc ${HOME}
cd ${HOME}
ln -sf .bashrc .bash_profile
rm -f .profile
mkdir ${ROOT_DIR}/extra

echo "Done."
