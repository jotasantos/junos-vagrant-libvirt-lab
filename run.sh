#!/bin/bash
echo "!!!!! Bringing up vmx with Vagrant !!!!!"
echo ""
vagrant up 
sleep 5
echo "!!!!! Populating hosts file 4 ansible !!"
echo ""
./genhost.sh
echo "!!!!! Ansible configures the routers!!!!"
echo ""
# LOAD CONFIGURATION
# ansible-playbook --private-key=~/.vagrant.d/insecure_private_key -u vagrant -i ini/hosts -l VMX playbook-push-vmx.yml
# ansible-playbook --private-key=~/.vagrant.d/insecure_private_key -u vagrant -i ini/hosts -l CSR -e 'ansible_python_interpreter=/usr/bin/python3.6' playbook-push-csr.yml

# SAVE CONFIGURATION
# ansible-playbook --private-key=~/.vagrant.d/insecure_private_key -u vagrant -i ini/hosts -l VMX  playbook-retrieve-vmx.yml
# ansible-playbook --private-key=~/.vagrant.d/insecure_private_key -u vagrant -i ini/hosts -l CSR -e 'ansible_python_interpreter=/usr/bin/python3.6' playbook-retrieve-csr.yml


# ANSIBLE TO 'CREATE' VANILLA L3 CONFIGURATION
ansible-playbook --private-key=~/.vagrant.d/insecure_private_key -u vagrant -i ini/hosts -l VMX playbook-vmx.yml
# ansible-playbook --private-key=~/.vagrant.d/insecure_private_key -u vagrant -i ini/hosts -l VMX -e 'ansible_python_interpreter=/usr/bin/python3.6' playbook-vmx.yml
# ansible-playbook --private-key=~/.vagrant.d/insecure_private_key -u vagrant -i ini/hosts -l CSR -e 'ansible_python_interpreter=/usr/bin/python3.6' playbook-csr.yml
