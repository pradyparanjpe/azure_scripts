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

function aptBasics() {
    date
    echo "Updating APT"
    sudo apt -y update
}

function debInAzure() {
    # Ready-made recipe
    aptBasics
    curl -sL "https://aka.ms/InstallAzureCLIDeb" | sudo bash
    [[ $? -ne 0 ]] \
        && echo "Could not install AzureCLI, aborting..." \
        && exit 5
}

function rpmInAzure() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
    sudo yum -y install azure-cli
    [[ $? -ne 0 ]] \
        && echo "Could not install AzureCLI, aborting..." \
        && exit 5
}

function installAzureCLI() {
    date
    echo "Install AzureCLI API to deallocate vm after commands are complete"
    distrib="$(hostnamectl | grep "Operating" | cut -d ":" -f 2 |cut -d " " -f 2)"
    case "$distrib" in
        [Ff]ed* )
            rpmInAzure
            ;;
        [Cc]ent* )
            rpmInAzure
            ;;
        [Rr]ed* )
            rpmInAzure
            ;;
        *[Uu]bunt* )
            debInAzure
            ;;
        [Dd]ebian* )
            debInAzure
            ;;
        *)
            echo "Could not guess Linux Distribution, aborting..."
            exit 5
    esac
}

function firstRun() {
    echo "AzureCLI Is now installed"
    hash az 2>/dev/null \
        && echo "AzureCLI already installed. \
If not already done, login as below."\
            || installAzureCLI
    echo "Now issue the command..."
    echo ""
    echo "az login"
    echo ""
    echo "...and follow instructions"
    updateRC
    exit 0
}

function argParse() {
    date
    AZUREGIT="${HOME}/azure_scripts"
    while test $# -gt 0; do
        case "$1" in
            -h|--help)
                echo ""
                echo "usage: psub [-h|--help] [-a [-n VMN] [-g VMG] [-p PATH]]"
                echo ""
                echo "Optional arguments:"
                echo "-h|--help Display this help and exit"
                echo "-a        install AzureCLI API and exit"
                echo "-n VMN    Name of virtual machine, used for deallocation"
                echo "-g VMG    Group of virtual machine, used for deallocation"
                echo "-p PATH   PATH to azure_scripts directory if not in ~"
                echo ""
                shift
                ;;
            -a)
                firstRun
                shift
                ;;
            -n)
                shift
                VM_NAME=$1
                shift
                ;;
            -g)
                shift
                VM_GROUP=$1
                shift
                ;;
            -p)
                shift
                AZUREGIT=$1
                shift
                ;;
            *)
                firsRun
                shift
                ;;
        esac
    done
}

function updateRC() {
    # declare AZUREGIT PATH
    if [[ -d "${AZUREGIT}" ]]; then
        true
    else
        AZUREGIT="$(find ${HOME} -name "azure_scripts"|tail -1)"
    fi
    if [[ -z "${AZUREGIT}" ]]; then
        echo "Can't find azure_scripts directory..."
        echo "Please provide correct path with -p option"
        exit 5
    else
        sed -i -e "s|^export AZUREGIT=.*$|export AZUREGIT=\"${AZUREGIT}\"|g" \
            "${AZUREGIT}/.bashrc"
    fi

    # declare VM_NAME in azure_scripts/.bashrc
    if [[ -z "${VM_NAME}" ]]; then
        echo "VM_NAME must be declared for successful deallocation."
        echo "You may now declare it in the bashrc file"
    else
        sed -i -e "s|^export VM_NAME=.*$||g" \
            "${AZUREGIT}/.bashrc"
        echo "export VM_NAME=\"${VM_NAME}\"" >> "${AZUREGIT}/.bashrc"
    fi

    # declare VM_GROUP in azure_scripts/.bashrc
    if [[ -z "${VM_GROUP}" ]]; then
        echo "VM_GROUP must be declared for successful deallocation."
        echo "You may now declare it in the bashrc file"
    else
        sed -i -e "s|^export VM_GROUP=.*$||g" \
            "${AZUREGIT}/.bashrc"
        echo "export VM_GROUP=\"${VM_GROUP}\"" >> "${AZUREGIT}/.bashrc"
    fi

    # add azure_scripts/.bashrc to ~/.bashrc
    if [[ "$(cat ${HOME}/.bashrc)" =~ ". ${AZUREGIT}/.bashrc" ]]; then
        true
    else
        echo "[[ -f ${AZUREGIT}/.bashrc ]] && . ${AZUREGIT}/.bashrc" \
             >> ${HOME}/.bashrc
    fi
}

function main() {
    argParse "$@"
}

main "$@"
