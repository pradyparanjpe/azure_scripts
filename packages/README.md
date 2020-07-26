# Packages folder

## Requirements
1. _Packages to be installed_ should be placed in **THIS** folder
2. The exact same name should be supplied as an argument while running the [linux_pypkg_install script](../bin/linux_pypkg_install.sh) and [psub script](../bin/psub).
3. Currently, only supports Python3
4. Alternatively create a ghost package with setup.py and add pip3 installations in `install_requires=[]` list or do any such python trickery.
