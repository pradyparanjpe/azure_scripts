# azure_scripts

## CAUTION
_*NOTING HERE IS TESTED*_

## Application:
Install _packages_ on Azure linux Virtual Machine instance.
Save money by deallocating the VM instance after installation.

Run a script with psub and forget. psub will deallocate once script is over

## Installation:

### Pull to local machine
On your _real_ local machine pull:

`git pull https://github.com/pradyparanjpe/azure_scripts.git`

### Modifications
Add _your packages_ in the folder [packages](./packages/) inside your local machine

### Copy
Start Azure virtual machine and copy the contents of the git folder to the Azure virtual machine using a command such as

`rsync -auvz ./azure_scripts uname@azure.ip:~/.`

### Fulfil [Requirements](#Requirements)
See *Requirements* section

### Run script
On Azure virtual machine,

`nohup linux_cuda_installation.sh <PACKAGE_FOLDER_NAME> 2>&1 >> installation.log`

### psub

run command of the form

`psub [-e <PACKAGE_FOLDER_NAME>] <command> &`

## Requirements

On the Azure VM, issue the following commands with necessary modifications:

1. Let bash read rc file in this project

```echo "[[ -f $\{HOME\}/azure_scripts/.bashrc ]] \
    && . $\{HOME\}/azure_scripts/.bashrc" >> ${HOME}/.bashrc
```



2. Declare virtual machine name and group in [bashrc](bashrc) file


3. Azure CLI installation: PROCEED WITH CAUTION, read [ALL related documentation](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
  - Run the raw script without without arguments. It will install AzureCLI.

  `linux_cuda_installation.sh -a`

  - Login to azure virtual machine:

  `az login`

  - Follow instuctions (Open a link in web-browser and supply the displayed `KEY`)

  - Now, the AzureCLI API has been granted access to manage your Azure virtual machines.
  

## Package requirements:
1. Python:
   - Package should be pip3 compatible.
   - setup.py must be present in the parent package folder, I do not look recursively.
   - Only pip3 dependencies will be installed
2. C/Cpp:
   - Package should be generally installable by issuing `./configure; make; make install`
   - This feature is planned, and may be added in future.
