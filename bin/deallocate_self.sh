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


function main() {
    # Done, don't waste any more system time...
    hash az 2>/dev/null \
        || echo "could not deactivate vm: az AzureCLI API not found. Idle:"
    date
    echo "Trying to power off and deallocate vm"
    sudo az vm deallocate -g ${VM_GROUP} -n ${VM_NAME} --no-wait
    # We shouldn't have really reach here
    exit 5
}

main || exit 5
