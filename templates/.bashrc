## .bashrc

## if not interactive; return
[[ $- != *i* ]] && return

## Tilix VTE issue fix
if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
        source /etc/profile.d/vte.sh
fi

## Source global definitions
[[ -f /etc/bashrc ]] && . /etc/bashrc

## Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

## User specific aliases and functions

RUNCOM="${HOME}/.runcom"

for rcfile in colorlibrc bashrc networkingrc aliasrc functionrc templatevarsrc emacsrc; do
    [[ -f ${RUNCOM}/${rcfile} ]] && . ${RUNCOM}/$rcfile
done

## Defined By Pradyumna Paranjape

## Environment variables

[[ -f /home/pradyumna/azure_scripts/.bashrc ]] && . /home/pradyumna/azure_scripts/.bashrc
