#!/bin/bash
# @file     .bashrc
# @author   Sebastien LEGRAND
# @date     2010-07-09
#
# @brief    BASH configuration file
# @history
#           2010-07-09 - 1.0.0 - SLE
#           Initial Version

#------ Global Variables

# directories definition
ROOT_DIR=${HOME}/.bashrc.d
ALIAS_DIR=${ROOT_DIR}/alias                 # aliases
COMPL_DIR=${ROOT_DIR}/completion            # auto-completion 
ENV_DIR=${ROOT_DIR}/environment             # environment variables
FUNCT_DIR=${ROOT_DIR}/functions             # custom functions directory
PATH_DIR=${ROOT_DIR}/path                   # path / ld_library_path definition
EXTRA_DIR=${ROOT_DIR}/extra                 # extra directory for 3rd parties

# temporary directory
TMP_DIR=${ROOT_DIR}/tmp

# system & hostname
SYSTEM=$(uname -s)
HOSTNAME=$(hostname -s)


#------ Functions

# list all files (*.run) from a directory and execute a function on it (by default "source")
# $1 : the directory
# $2 : the function to execute (source)
function sourceFiles
{
    # check if the directory exists
    [[ ! -d $1 ]] && return

    # command to execute
    local COMMAND=${2:-"source"}

    for FILE in $(ls $1/*.run 2>/dev/null)
    do
        # retrieve dirname/filename
        DIRNAME=$(dirname ${FILE})
        FILENAME=$(basename ${FILE} | cut -d. -f1)

        # FILENAME.<hostname>.run
        if [ -e ${DIRNAME}/${FILENAME}.${HOSTNAME}.run ]; then
            LOADFILE=${FILENAME}.${HOSTNAME}.run
        else
            # FILENAME.<system>.run
            if [ -e ${DIRNAME}/${FILENAME}.${SYSTEM}.run ]; then
                LOADFILE=${FILENAME}.${SYSTEM}.run
            else
                LOADFILE=${FILENAME}.run
            fi
        fi

        # load the file
        eval "${COMMAND} ${DIRNAME}/${LOADFILE}"
    done
}

# parse the path file and create a *PATH variable
# $1 : the file to parse
function parsePathFile
{
    local regex='^#|^$'

    # check if the file exists
    [[ ! -e $1 ]] && return

    # filename & variable name (deducted from the filename)
    VARNAME=$(basename $1 | cut -d. -f1 | tr "[:lower:]" "[:upper:]")

    # create the variable
    MYPATH=""
    while read LINE
    do
        # remove empty lines and comments
        [[ $LINE =~ $regex ]] && continue

        # expand the vars 
        TEMP=$(eval echo $LINE)
        [[ ! -d ${TEMP} ]] && continue

        # add it to the path
        if [ "${MYPATH}" == "" ]; then
            MYPATH=${TEMP}
        else
            MYPATH="${MYPATH}:${TEMP}"
        fi
    done < $1

    # create the value
    eval "export ${VARNAME}=${MYPATH}"
}

# parse a file and create aliases (format = name:alias)
# $1 : the file to parse
function parseAliasFile
{
    local regex1='^#|^$'
    local regex2='^(.*):(.*)$'

    # check if the file exists
    [[ ! -e $1 ]] && return

    # read the file
    while read LINE
    do
        # remove comments & empty lines
        [[ $LINE =~ $regex1 ]] && continue

        # create alias
        [[ $LINE =~ $regex2 ]]
        alias ${BASH_REMATCH[1]}="${BASH_REMATCH[2]}"
    done < $1
}


#------ Begin

# check if the temp directory is created
mkdir -p ${TMP_DIR}

# load the functions
sourceFiles ${FUNCT_DIR}

# load the environment variables
sourceFiles ${ENV_DIR}

# load the path values
sourceFiles ${PATH_DIR} "parsePathFile"

# determine if the shell is non-interactive or not
if [ -z ${NON_INTERACTIVE} ]; then
    case "$-" in
        *i*)
            NON_INTERACTIVE="no"
            ;;
        *)
            NON_INTERACTIVE="yes"
            ;;
    esac
fi

# non-interactive shell stops here
if [ "${NON_INTERACTIVE}" != "yes" ]; then
    # load the aliases
    sourceFiles ${ALIAS_DIR} "parseAliasFile"

    # activate bash completion
    [[ -f /etc/bash_completion ]] && source /etc/bash_completion

    # load user completion functions
    sourceFiles ${COMPL_DIR}

    # load extra files
    sourceFiles ${EXTRA_DIR}
fi


#------ End

# remove old files
/usr/bin/find ${TMP_DIR} -type f -mtime +7 -exec rm -f {} \; 

# remove functions from user space
unset -f sourceFiles
unset -f parsePathFile
unset -f parseAliasFile
