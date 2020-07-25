#!/usr/bin/env bash
# -*- coding: utf-8; mode:shell-script -*-
#
# Copyright 2020 Pradyumna Paranjape
#
# This file is part of Prady_AzScripts.
#
# Prady_AzScripts is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Prady_AzScripts is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Prady_AzScripts.  If not, see <https://www.gnu.org/licenses/>.
#


date
echo "Started script"


# Functions
function variableDeclaration() {
    date
    while test $# -gt 0; do
        case "$1" in
            -h|--help)
                echo ""
                echo "usage: psub [-e package_name] <cli command> &"
                echo ""
                echo "Optional arguments:"
                echo "-e    package name as supplied during installation"
                echo "      environment will be guessed from this name"
                echo ""
                echo "Positional arguments:"
                echo "<cli command>    Command to be executed"
                echo ""
                exit 0
                ;;
            -e)
                shift
                PKG_NAME=$1
                shift
                ;;
            *)
                PROG_CLI="${PROG_CLI} $1"
                shift
                ;;
        esac
    done
    PKG_NAME="$1"
    shift
    AZUREGIT="${HOME}/azure_scripts"
    PYPKGENV="${AZUREGIT}/.virtualenvs/${PKG_NAME}ENV"
    PIDREC_D="${AZUREGIT}/pid_recs"
    [[ ! -d PYPKGENV ]] && PYPKGENV=""
    [[ -z ${VM_NAME} ]] \
        && echo "Script can't exit automatically, export $VM_NAME, aborting" \
        && exit 5
    [[ -z ${VM_GROUP} ]] \
        && echo "Script can't exit automatically, export $VM_GROUP, aborting" \
        && exit 5
    echo "We are on ${VM_NAME} in the group ${VM_GROUP}"
}

function vmDeallocate() {
    # Done, don't waste any more system time...
    hash az \
        || echo "could not deactivate vm: az AzureCLI API not found. Idle:"
    date
    echo "Trying to power off and deallocate vm"
    sudo az vm deallocate -g ${VM_GROUP} -n ${VM_NAME} --no-wait
    # We shouldn't have really reach here
    exit 5
}

function runProg() {
    date
    # activate PYPKG if exists
    hash deactivate && deactivate
    [[ -n "${PYPKGENV}" ]] && source "${PYPKGENV}/bin/activate"

    stime="$(date "+%Y%m%d%H%M%S")"
    echo "Running command"
    echo "${PROG_CLI}"
    nohup $(${PROG_CLI}) 2>&1 >> "./${stime}.run.${PKG_NAME}.log" &
    pid="$!"
    echo "${pid}" > "${PIDREC_D}/${stime}.pid"
}

function watchProg() {
    while [[ -d /proc/${pid} ]]; do
        sleep 1
    done && rm "${PIDREC_D}/${stime}.pid" && vmDeallocate
}

function main() {
    # main program
    variableDeclaration $@
    hash az || \
        echo "AZURE CLI NOT INSTALLED, resource deallocation not possible"
    runProg
    watchProg
    # Shouldn't have to run this:
    vmDeallocate
}

main $@
# Shouldn't reach here
echo "Idle since"
date
exit 0
