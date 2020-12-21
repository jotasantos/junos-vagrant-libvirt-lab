# under root
cd inetzero_lab01
vagrant up 
run.sh

# This loads the vanilla configuration to work on the document 'iZ-JNCIE-SP-WB-v1.1.pdf' :
ansible-playbook --private-key=~/.vagrant.d/insecure_private_key -u vagrant -i ini/hosts -l VMX playbook-vmx.yml


# This retrieves and pushes full (display set) configurations
ansible-playbook --private-key=~/.vagrant.d/insecure_private_key -u vagrant -i ini/hosts -l VMX playbook-retrieve-vmx.yml
ansible-playbook --private-key=~/.vagrant.d/insecure_private_key -u vagrant -i ini/hosts -l VMX playbook-push-vmx.yml 

----

# current diagram (in oradocs):
-  https://oradocs-prodapp.cec.ocp.oraclecloud.com/documents/fileview/D42880679CA790AB66E82549F6C3FF17C1177A968060/_vmx-lab1.vsd
-  diagram-1.odg


# PLAN
In the baseline Vagrant file (no links are connected except the internal vcp to vfp links):
:libvirt__tunnel_ip => "169.69.69.69",  # This is a placeholder address, to be changed to make connections
:libvirt__tunnel_port => 88888,  # This is a placeholder port, to be changed to make connections

AND I PICK UP AN AVAILABLE PORT FROM A 10002 to 10099
10002
10003
10004

# Changelog:
- Configured all links in R3. Nothing on the other 
- Finished configuring R5
- Finished configuring R5, last port2 p4
10002-12