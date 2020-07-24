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
variableDeclaration() {
    date
    echo "checking variables"

    [[ -z ${1} ]] && echo "Package Name not supplied, aborting..." && exit 5
    AZUREGIT="${HOME}/azure_scripts"
    PYPKGENV="${AZUREGIT}/.virtualenvs/${1}ENV"
    PYPKGSRC="${AZUREGIT}/packages/${1}"

    [[ -z ${VM_NAME} ]] \
        && echo "Script can't exit automatically, export $VM_NAME, aborting" \
        && exit 5
    [[ -z ${VM_GROUP} ]] \
        && echo "Script can't exit automatically, export $VM_GROUP, aborting" \
        && exit 5
    echo "We are on ${VM_NAME} in the group ${VM_GROUP}"
}

aptBasics() {
    date
    echo "Updating APT"
    sudo apt -y update
}

installAzureCLI() {
    # Ready-made recipe
    date
    aptBasics
    echo "Install AzureCLI API to deallocate vm after commands are complete"

    curl -sL "https://aka.ms/InstallAzureCLIDeb" | sudo bash
    [[ $? -ne 0 ]] \
        && echo "Could not install Azure commands, aborting..." \
        && exit 5
}

vmDeallocate() {
    # Done, don't waste any more system time...
    hash az \
        || echo "could not deactivate vm: az AzureCLI API not found. Idle:"
    date
    echo "Trying to power off and deallocate vm"
    sudo az vm deallocate -g ${VM_GROUP} -n ${VM_NAME} --no-wait
    # We shouldn't have really reach here
    exit 5
}

installCUDA() {
    date
    aptBasics
    echo "APT Installing nvidia-cuda-toolkit"
    sudo apt -y install nvidia-cuda-toolkit
    [[ $? -ne 0 ]] \
        && echo "Could not install cuda toolkit, aborting..." \
        && vmDeallocate
}

venvBasics() {
    date
    echo "Creating PYPKGENV"
    mkdir -p "${PYPKGENV}"
    python3 -m "virtualenv" "${PYPKGENV}" -p `which python3`

    [[ $? -ne 0 ]] \
        && echo "Could not activate create environment, aborting..." \
        && vmDeallocate
}

installPython() {
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

pipRequires() {
    date
    echo "installing PIP requrements"

    # activate PYPKG
    hash deactivate && deactivate
    source "${PYPKGENV}/bin/activate"

    pip3 install numpy
    pip3 install pygmo
    [[ ${VM_NAME} -ne "DH5A" ]] && pip3 install cupy
}

installProg() {
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

    echo "PIP installing ${1}"
    pip3 install "."  # Assume that it contains setup.py
}

# main program
main() {
    variableDeclaration
    hash az || installAzureCLI
    hash nvidia-smi || installCUDA
    hash pip3 || installPython
    [[ -f "${PYPKGVENV}/bin/activate" ]] || venvBasics
    pipRequires
    installProg
    vmDeallocate
}

main
# Shouldn't reach here
echo "Idle since"
date
exit 0
