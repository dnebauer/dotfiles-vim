#!/usr/bin/env bash

# File: ${filename}.sh
# Author: ${author}
# Purpose: 
# Created: ${date}


# ERROR HANDLING

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace

# VARIABLES

msg="Loading libraries" ; echo -ne "\\033[1;37;41m${msg}\\033[0m"
source "@lib_dir@/libdncommon-bash/liball"  # supplies functions
dnEraseText "${msg}"
# provided by libdncommon-bash: dn_self,dn_divider[_top|_bottom]
# shellcheck disable=SC2154
system_conf="@pkgconf_dir@/${dn_self}rc"
local_conf="${HOME}/.${dn_self}rc"
usage="Usage:"
# shellcheck disable=SC2034
param_pad="$( dnRightPad "$( dnStrLen "${usage} ${dn_self}" )" )"
parameters=""  # **
#parameters="${parameters}\n${param_pad}"
#parameters="${parameters} ..."
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
	local system_conf
    system_conf="$( dnNormalisePath "${1}" )"
	local local_conf
    local_conf="$( dnNormalisePath "${2}" )"
	# process config files
	for conf in "${system_conf}" "${local_conf}" ; do
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
# Process command line options
#   params: all command line parameters
#   prints: feedback
#   return: nil
#   note:   after execution variable ARGS contains
#           remaining command line args (after options removed)
processOptions () {
	# read the command line options
    local OPTIONS="$(                             \
        getopt                                    \
            --options hvdx:                       \
            --long    xoption:,help,verbose,debug \
            --name    "${BASH_SOURCE[0]}"         \
            -- "${@}"                             \
    )"
    [[ ${?} -eq 0 ]] || {
        echo 'Invalid command line options' 1>&2
        exit 1
    }
    eval set -- "${OPTIONS}"
	while true ; do
		case "${1}" in
        -x | --xoption ) varx="${2}"    ; shift 2 ;;
        -h | --help    ) displayUsage   ; exit 0  ;;
        -v | --verbose ) set -o verbose ; shift 1 ;;
        -d | --debug   ) set -o xtrace  ; shift 1 ;;
        --             ) shift ; break ;;
        *              ) break ;;
		esac
	done
	ARGS="${@}"  # remaining arguments
}


# MAIN

# Process configuration files
msg="Reading configuration files" ; echo -ne "$( dnRedReverseText "${msg}" )"
processConfigFiles "${system_conf}" "${local_conf}"
dnEraseText "${msg}"
unset system_conf local_conf msg

# Process command line options
# - results in $ARGS holding remaining non-option command line arguments
processOptions "${@}"

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

# vim:foldmethod=marker:
