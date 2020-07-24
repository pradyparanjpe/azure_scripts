# azure_scripts

## CAUTION
_*NOTING HERE IS TESTED*_

## Application:
Install _packages_ on Azure Ubuntu >= 18.04LTS Virtual Machine instance.
Saves money by deallocating the VM instance.

## Installation:

### Pull to local machine
On your _real_ local machine pull:

`git pull https://github.com/pradyparanjpe/azure_scripts.git`

### Modifications
Add your packages in the folder [[packages][packages]] inside your local machine

### Copy
Start the virtual machine and copy the contents of the git folder to the Azure virtual machine using a command such as

`rsync ./azure_scripts uname@azure.ip:~/.`

### Run script

`nohup ./${HOME}/azure_scripts/ubuntu_cuda_installation.sh <PACKAGE_FOLDER_NAME> > install.sh`

## Requirements
On the Azure VM, issue the following commands after modification:

`$ echo "[[ -f $\{HOME\}/azure_scripts/bashrc ]] && . $\{HOME\}/azure_scripts/bashrc" >> ${HOME}/.bashrc`
`$ echo "VM_NAME=<YOUR VIRTUAL MACHINE NAME>" >> ${HOME}/.bashrc`
`$ echo "VM_GROUP=<YOUR VIRTUAL MACHINE GROUP>" >> ${HOME}/.bashrc`

## Package requirements:
1. Python:
   - Package should be pip3 compatible.
   - setup.py must be present in the parent package folder, I do not look recursively.
   - only pip3 dependencies will be installed
2. C/Cpp:
   - Package should be generally installable by issuing `./configure; make; make install`
   - This feature is planned, and may be added in future.
