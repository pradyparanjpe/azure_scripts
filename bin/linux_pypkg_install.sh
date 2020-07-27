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

function argParse() {
    date
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                echo ""
                echo "usage: linux_cuda_installation [-h|--help] [PKG]"
                echo ""
                echo "Optional arguments:"
                echo "-h|--help   Display this help and exit"
                echo ""
                echo "Optional Positional arguments:"
                echo "PKG      Name of Python Package to be installed"
                echo "         It must have been copied in ${AZUREGIT}/packages"
                echo "         Default: All packages will be installed afresh"
                echo ""
                exit 0
                shift
                ;;
            *)
                PKG_NAME=$1
                shift
                ;;
        esac
    done
}

function preInstallCheck() {
    # Pre installation Checks
    hash az 2>/dev/null
    [[ $? -ne 0 ]] \
        && echo "Please run linux_install_azurecli.sh form bin directory" \
        && exit 5
    [[ -z "${AZUREGIT}" ]] \
        && echo "Please run linux_install_azurecli.sh form bin directory" \
        && exit 5
    [[ -z "${VM_NAME}" ]] \
        && echo "Script can't exit automatically, export $VM_NAME, aborting" \
        && exit 5
    [[ -z "${VM_GROUP}" ]] \
        && echo "Script can't exit automatically, export $VM_GROUP, aborting" \
        && exit 5
    echo "We're working on ${VM_NAME} in the group ${VM_GROUP}"

    # Packages
    if [[ -n "$PKG_NAME" ]]; then
        PYPKGLIST="PKG_NAME"
    else
        # Discover packages
        PYPKGLIST="$(ls -d ${AZUREGIT}/packages/*/ |rev| cut -d "/" -f 2 |rev)"
    fi
}

function vmDeallocate() {
    # Done, don't waste any more system time...
    hash az 2>/dev/null \
        || echo "could not deactivate vm: az AzureCLI API not found. Idle:"
    date
    echo "Trying to power off and deallocate vm"
    sudo az vm deallocate -g ${VM_GROUP} -n ${VM_NAME} --no-wait
    # We shouldn't have really reach here
    exit 5
}

function rpmCUDA() {
    sudo dnf -y install kernel-devel-$(uname -r) kernel-headers-$(uname -r)
    sudo dnf -y install gcc
    sudo dnf -y config-manager --add-repo \
         http://developer.download.nvidia.com/compute/cuda/repos/rhel8/x86_64/cuda-rhel8.repo
    sudo dnf -y module install nvidia-driver:latest-dkms
    sudo dnf -y install cuda
    echo "Propreitary nvidia-cuda installation attempted"
    }

function installCUDA() {
    date
    hash apt 2>/dev/null && aptBasics
    hash apt 2>/dev/null && sudo apt -y install nvidia-cuda-toolkit && \
        echo "installed cuda-toolkit"
    hash dnf 2>/dev/null && rpmCUDA
}

function venvCreate() {
    date
    mkdir -p "${AZUREGIT}/.virtualenvs"
    for PYPKG in $PYPKGLIST; do
        echo "Installing package ${PYPKG}"
        PYPKGENV="${AZUREGIT}/.virtualenvs/${PYPKG}ENV"
        if [[ ! -f "${AZUREGIT}/packages/${PYPKG}/setup.py" ]]; then
            echo "${PYPKG} lacks the file 'setup.py', skipping"
            continue;
        fi
        echo "Creating ${PYPKGENV}"
        mkdir -p "${PYPKGENV}"
        [[ -f "${PYPKGVENV}/bin/activate" ]] \
            || python3 -m "venv" "${PYPKGENV}"
        if [[ $? -ne 0 ]]; then
            echo "Could not create environment, skipping..."
            continue
        fi
    done
}

function installPython() {
    date
    echo "APT Installing pip"
    aptBasics
    hash apt 2>/dev/null && sudo apt -y install python3-pip python3-venv
    hash dnf 2>/dev/null && sudo dnf -y install python3-pip python3-venv
}

function installProg() {
    date
    for PYPKG in $PYPKGLIST; do
        PYPKGENV="${AZUREGIT}/.virtualenvs/${PYPKG}ENV"
        PYPKGSRC="${AZUREGIT}/packages/${PYPKG}"
        if [[ ! -d "${PYPKGSRC}" ]]; then
            echo "Package Directory ${PYPKGSRC} not found, exitting..."
            continue
        fi
        echo "installing Program"

        # activate PYPKG
        hash 2>/dev/null deactivate && deactivate
        source "${PYPKGENV}/bin/activate"

        # Enter Package directory

        cd "${PYPKGSRC}"
        echo "Entered ${PWD}"

        # Link virtual environment to package
        # This helps automatic switching
        ln -s "${PYPKGENV}" "${PYPKGSRC}/.venv"

        echo "PIP installing ${PKG_NAME}"
        pip3 install "."  # Assume that it contains setup.py
    done
}

function main() {
    # main program
    argParse "$@"
    preInstallCheck
    hash 2>/dev/null nvidia-smi || installCUDA
    hash 2>/dev/null pip3 || installPython
    venvCreate
    installProg
    vmDeallocate
}

main $@
# Shouldn't reach here
echo "Idle since"
date
exit 0
