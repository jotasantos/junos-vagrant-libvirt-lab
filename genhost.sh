#!/bin/bash
vagrant ssh-config > ssh-config
echo -e "
[VMX]
R1-vcp ansible_host=`egrep -A 1 "Host R1-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R2-vcp ansible_host=`egrep -A 1 "Host R2-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R3-vcp ansible_host=`egrep -A 1 "Host R3-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R4-vcp ansible_host=`egrep -A 1 "Host R4-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R5-vcp ansible_host=`egrep -A 1 "Host R5-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R6-vcp ansible_host=`egrep -A 1 "Host R6-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R7-vcp ansible_host=`egrep -A 1 "Host R7-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R8-vcp ansible_host=`egrep -A 1 "Host R8-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
P1-vcp ansible_host=`egrep -A 1 "Host P1-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
DC1-vcp ansible_host=`egrep -A 1 "Host DC1-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
[CSR]
C1 ansible_host=`egrep -A 1 "Host C1" ssh-config | egrep HostName | cut -d' ' -f 4`
C2 ansible_host=`egrep -A 1 "Host C2" ssh-config | egrep HostName | cut -d' ' -f 4`
T1 ansible_host=`egrep -A 1 "Host T1" ssh-config | egrep HostName | cut -d' ' -f 4`
" > ini/hosts
echo -e "
[VMX]
R1-vcp ansible_host=`egrep -A 1 "Host R1-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R2-vcp ansible_host=`egrep -A 1 "Host R2-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R3-vcp ansible_host=`egrep -A 1 "Host R3-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R4-vcp ansible_host=`egrep -A 1 "Host R4-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R5-vcp ansible_host=`egrep -A 1 "Host R5-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R6-vcp ansible_host=`egrep -A 1 "Host R6-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R7-vcp ansible_host=`egrep -A 1 "Host R7-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
R8-vcp ansible_host=`egrep -A 1 "Host R8-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
P1-vcp ansible_host=`egrep -A 1 "Host P1-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
DC1-vcp ansible_host=`egrep -A 1 "Host DC1-vcp" ssh-config | egrep HostName | cut -d' ' -f 4`
[CSR]
C1 ansible_host=`egrep -A 1 "Host C1" ssh-config | egrep HostName | cut -d' ' -f 4`
C2 ansible_host=`egrep -A 1 "Host C2" ssh-config | egrep HostName | cut -d' ' -f 4`
T1 ansible_host=`egrep -A 1 "Host T1" ssh-config | egrep HostName | cut -d' ' -f 4`
"
