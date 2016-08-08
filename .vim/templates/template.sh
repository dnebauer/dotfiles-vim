#!/bin/bash

# File: ${filename}.sh
# Author: ${author}
# Purpose: 
# Created: ${date}


# VARIABLES

args="${*}"
msg="Loading libraries" ; echo -ne "\\033[1;37;41m${msg}\\033[0m"
source "@lib_dir@/libdncommon-bash/liball"  # supplies functions
dnEraseText "${msg}"
# provided by libdncommon-bash: dn_self,dn_divider[_top|_bottom]
# shellcheck disable=SC2154
global_conf="@pkgconf_dir@/${dn_self}rc"
local_conf="${HOME}/.${dn_self}rc"
usage="Usage:"
# shellcheck disable=SC2034
param_pad="$( dnRightPad "$( dnStrLen "${usage} ${dn_self}" )" )"
parameters=""  # **
#parameters="${parameters}\n${param_pad}"
#parameters="${parameters} ..."
args=""
unset param_pad msg


# PROCEDURES

# Show usage
#   params: nil
#   prints: nil
#   return: nil
displayUsage () {
cat << _USAGE
${dn_self}: <BRIEF>

<LONG>

${usage} ${dn_self} ${parameters}
       ${dn_self} -h

Options: -x OPT   = 
_USAGE
}
# Process configuration files
#   params: 1 - global config filepath (optional)
#           2 - local config filepath (optional)
#   prints: nil
#   return: nil
#   notes:  set variables [  ]
processConfigFiles () {
	# set variables
	local conf name val
	local global_conf
    global_conf="$( dnNormalisePath "${1}" )"
	local local_conf
    local_conf="$( dnNormalisePath "${2}" )"
	# process config files
	for conf in "${global_conf}" "${local_conf}" ; do
		if [ -r "${conf}" ] ; then
			while read name val ; do
				if [ -n "${val}" ] ; then
					# remove enclosing quotes if present
					val="$( dnStripEnclosingQuotes "${val}" )"
					# load vars depending on name
					case ${name} in
					'key' ) key="${val}";;
					'key' ) key="${val}";;
					'key' ) key="${val}";;
					esac
				fi
			done < "${conf}"
		fi
	done
}
# Process command line
#   params: all command line parameters
#   prints: feedback
#   return: nil
processCommandLine () {
	# Read the command line options
	#   - if optstring starts with ':' then error reporting is suppressed
	#     leave ':' at start as '\?' and '\:' error capturing require it
	#   - if option is followed by ':' then it is expected to have an argument
	while getopts ":hx:" opt ; do  # **
		case ${opt} in
			'h' ) displayUsage && exit 0;;
			'x' ) var="${OPTARG}";;
			\?  ) echo -e "Error: Invalid flag '${OPTARG}' detected"
				  echo -e "Usage: ${dn_self} ${parameters}"
				  echo -e "Try '${dn_self} -h' for help"
				  echo -ne "\a"
				  exit 1;;
			\:  ) echo -e "Error: No argument supplied for flag '${OPTARG}'"
				  echo -e "Usage: ${dn_self} ${parameters}"
				  echo -e "Try '${dn_self} -h' for help"
				  echo -ne "\a"
				  exit 1;;
		esac
	done
	shift $(( ${OPTIND} - 1 ))
	args="${@}"  # reset arguments
	unset usage parameters
}


# MAIN

# Process configuration files
msg="Reading configuration files" ; echo -ne "$( dnRedReverseText "${msg}" )"
processConfigFiles "${global_conf}" "${local_conf}"
dnEraseText "${msg}"
unset global_conf local_conf msg

# Process command line
processCommandLine "${@}"
while [ "${*}" != "${args}" ] ; do shift ; done
unset args

# Check arguments
# Check that argument supplied
#[ $# -eq 0 ] && dnFailScript "No wibble supplied"
# Check value of option-set variable
#case ${var} in
#	val ) var2="val2";;
#	*   ) dnFailScript "'${val}' is an inappropriate wibble";;
#esac
# Check for option-set variable
#[ -z "${var}" ] && dnFailScript "You did not specify a wibble"

# Informational message
dnInfo "${dn_self} is running..."

