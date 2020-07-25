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
    hash az \
        && echo "AzureCLI already installed. \
If not already done, login as below."\
            || installAzureCLI
    echo "Now issue the command..."
    echo ""
    echo "az login"
    echo ""
    echo "...and follow instructions"
    exit 0
}

function variableDeclaration() {
    date
    while test $# -gt 0; do
        case "$1" in
            -h|--help)
                echo ""
                echo "usage: psub [-h|--help] [-a] [-p PKG] [-n VMN] [-g VMG]"
                echo ""
                echo "Optional arguments:"
                echo "-h|--help Display this help and exit"
                echo "-a        install AzureCLI API and exit"
                echo "-p PKG    package name as supplied during installation"
                echo "          environment will be guessed from this name"
                echo "-n VMN    Name of virtual machine, used for deallocation"
                echo "-g VMG    Group of virtual machine, used for deallocation"
                echo ""
                exit 0
                ;;
            -a)
                firstRun
                exit 0
                ;;
            -p)
                shift
                PKG_NAME=$1
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
            *)
                echo "Invalid command"
                echo "aborting..."
                vmDeallocate
                ;;
        esac
    done
    AZUREGIT="${HOME}/azure_scripts"
    PYPKGENV="${AZUREGIT}/.virtualenvs/${PKG_NAME}ENV"
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

function installCUDA() {
    date
    aptBasics
    echo "APT Installing nvidia-cuda-toolkit"
    sudo apt -y install nvidia-cuda-toolkit
    [[ $? -ne 0 ]] \
        && echo "Could not install cuda toolkit, aborting..." \
        && vmDeallocate
}

function venvBasics() {
    date
    echo "Creating PYPKGENV"
    mkdir -p "${PYPKGENV}"
    python3 -m "virtualenv" "${PYPKGENV}" -p `which python3`

    [[ $? -ne 0 ]] \
        && echo "Could not activate create environment, aborting..." \
        && vmDeallocate
}

function installPython() {
    date
    echo "APT Installing pip, virtualenv"

    aptBasics
    sudo apt -y install python3-pip
    sudo apt -y install python3-virtualenv
    [[ $? -ne 0 ]] \
        && echo "Could not install Python, pip aborting..." \
        && vmDeallocate

    # Who uses py2 (!) python is always python3
    alias python=python3
    alias pip=pip3
}

function pipRequires() {
    date
    echo "installing PIP requrements"

    # activate PYPKG
    hash deactivate && deactivate
    source "${PYPKGENV}/bin/activate"

    pip3 install numpy
    pip3 install pygmo
    [[ ${VM_NAME} -ne "DH5A" ]] && pip3 install cupy
}

function installProg() {
    date
    [[ ! -d "${PYPKGSRC}" ]] \
        && echo "Package Directory not found, exitting..." \
        && vmDeallocate
    echo "installing Program"

    # activate PYPKG
    hash deactivate && deactivate
    source "${PYPKGENV}/bin/activate"

    # Enter Package directory

    cd "${PYPKGSRC}"
    echo "Entered ${PWD}"

    # Link virtual environment to package
    # This helps automatic switching
    ln -s "${PYPKGENV}" "${PYPKGSRC}/.venv"

    echo "PIP installing ${PKG_NAME}"
    pip3 install "."  # Assume that it contains setup.py
}

function main() {
    # main program
    variableDeclaration $@
    hash az || \
        echo "AZURE CLI NOT INSTALLED, resource deallocation not possible"
    hash nvidia-smi || installCUDA
    hash pip3 || installPython
    [[ -f "${PYPKGVENV}/bin/activate" ]] || venvBasics
    pipRequires
    installProg
    vmDeallocate
}

main $@
# Shouldn't reach here
echo "Idle since"
date
exit 0
