# azure_scripts

## CAUTION
_*NOTING HERE IS TESTED*_

## Application:
Install _packages_ on Azure linux Virtual Machine instance.
Install CUDA toolkit because you'll use this typically on a CUDA-Machine
Save money by deallocating the VM instance after installation.

Run a [python] script with psub and forget. psub will deallocate resources once script is over.

## Installation:

### Pull to local machine
  - On your _real_ local machine pull:

`git pull https://github.com/pradyparanjpe/azure_scripts.git`

### Modifications
  1. See [Package requirements](Package requirements)

  2. Add _your packages_ in the [packages](./packages/) folder's copy inside your local machine


### Copy
  - Start Azure virtual machine and copy the contents of this modified git folder to the Azure virtual machine using a command such as

`rsync -auvz ./azure_scripts uname@azure.ip:~/.`

### Initiate azurecli [Requirements](#Requirements)
  - See *Requirements* section

### Run script
  - On Azure virtual machine,

`nohup linux_cuda_installation.sh [<PACKAGE_FOLDER_NAME>] 2>&1 >> installation.log`

## Usage

  - run psub command of the form

`psub [-e <PACKAGE_FOLDER_NAME>] <command> &`

  - NOTE THE TRAILING '&'

## Requirements

After copying azure_scripts to the Azure VM,
1. Read [ALL related documentation](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)

2. Run [linus_install_azurecli.sh](bin/linux_install_azurecli.sh) with modifications

  `bash ~/azure_scripts/linux_install_azure.sh -n <VMN> -g <VMG> -p <AZUREGITPATH>`

  - Login to azure virtual machine:

  `az login`

  - Follow instuctions (Open a link in web-browser and supply the displayed `KEY`)

  - Now, the AzureCLI API has been granted access to manage your Azure virtual machines.
  

## Package requirements
1. Python:
   - Package should be pip3 compatible.
   - setup.py must be present in the parent package folder, I do not look recursively.
   - Only pip3 dependencies will be installed
2. C/Cpp:
   - Package should be generally installable by issuing `./configure; make; make install`
   - This feature is planned, and may be added in future.
