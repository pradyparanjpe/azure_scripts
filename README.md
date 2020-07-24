# azure_scripts

## CAUTION
_*NOTING HERE IS TESTED*_

## Application:
Install _packages_ on Azure Ubuntu >= 18.04LTS Virtual Machine instance.
Save money by deallocating the VM instance after installation.

## Installation:

### Pull to local machine
On your _real_ local machine pull:

`git pull https://github.com/pradyparanjpe/azure_scripts.git`

### Modifications
Add _your packages_ in the folder [packages](./packages/) inside your local machine

### Copy
Start Azure virtual machine and copy the contents of the git folder to the Azure virtual machine using a command such as

`rsync ./azure_scripts uname@azure.ip:~/.`

### Fulfil Requirements
See *Requirements* section

### Run script
On Azure virtual machine,

`nohup ${HOME}/azure_scripts/ubuntu_cuda_installation.sh <PACKAGE_FOLDER_NAME> 2>&1 > installation.log`

## Requirements
On the Azure VM, issue the following commands with necessary modifications:

1. Let bash read rc file in this project

`$ echo "[[ -f $\{HOME\}/azure_scripts/bashrc ]] && . $\{HOME\}/azure_scripts/bashrc" >> ${HOME}/.bashrc`

2. Declare virtual machine name that is to be deallocated after the installation

`$ echo "VM_NAME=<YOUR VIRTUAL MACHINE NAME>" >> ${HOME}/.bashrc`

2. Declare group name of virtual machine that is to be deallocated after the installation

`$ echo "VM_GROUP=<YOUR VIRTUAL MACHINE GROUP>" >> ${HOME}/.bashrc`

## Package requirements:
1. Python:
   - Package should be pip3 compatible.
   - Setup.py must be present in the parent package folder, I do not look recursively.
   - Only pip3 dependencies will be installed
2. C/Cpp:
   - Package should be generally installable by issuing `./configure; make; make install`
   - This feature is planned, and may be added in future.
