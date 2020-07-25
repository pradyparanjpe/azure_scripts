# Packages folder

## Requirements
1. Packages to be installed should be placed in **THIS** folder
2. The exact same name should be supplied as an argument while running the [linux_installation script](../linux_cuda_installation.sh) and [psub script](../psub.sh).
3. Currently, only supports Python3
4. Alternatively create a ghost package with setup.py and add pip3 installations in `install_requires=[]` list