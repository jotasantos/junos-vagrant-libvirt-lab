# -*- mode: ruby -*-
# vi: set ft=ruby :

def get_mac(oui="28:b7:ad")
  "Generate a MAC address"
  nic = (1..3).map{"%0.2x"%rand(256)}.join(":")
  return "#{oui}:#{nic}"
end

def get_mac_cisco(oui="a0:00:00:00:00")
  "Generate a MAC address"
  nic = (1..1).map{"%0.2x"%rand(256)}.join(":")
  return "#{oui}:#{nic}"
end

cwd = Dir.pwd.split("/").last
username = ENV['USER']
domain_prefix = "#{username}_#{cwd}"

Vagrant.configure("2") do |config|

  config.vm.define "R1-vcp" do |node|
    guest_name = "R1-vcp"
    node.vm.box = "juniper/vmx-18.2R1.9-vcp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 1
      domain.memory = 1024
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2", :size => "196870144", :type => "qcow2", :bus => "ide", :device => "hdb", :allow_existing => true
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img", :size => "16777216", :type => "raw", :bus => "ide", :device => "hdc", :allow_existing => true
    end
    add_volumes = [
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 196870144",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 /opt/vagrant/storage/vmx-vcp-hdb-18.2R1.9-base.qcow2",
      "sleep 1",
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img 16777216",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img /opt/vagrant/storage/vmx-vcp-hdc-18.2R1.9-base.img",
      "sleep 1"
    ]
    add_volumes.each do |i|
      node.trigger.before :up do |trigger|
        trigger.name = "add-volumes"
        trigger.info = "Adding Volumes"
        trigger.run = {inline: i}
      end
    end

    delete_volumes = [
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 default",
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img default"
    ]
    delete_volumes.each do |i|
      node.trigger.after :destroy do |trigger|
        trigger.name = "remove-volumes"
        trigger.info = "Removing Volumes"
        trigger.run = {inline: i}
      end
    end

    node.vm.network :private_network,
      # Link: R1-vcp-int1 <--> R1-vfp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.247.1",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "127.255.247.2",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

  end
  config.vm.define "R1-vfp" do |node|
    guest_name = "R1"
    node.vm.box = "juniper/vmx-18.2R1.9-vfp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false
    node.ssh.username = "root"

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 8
      domain.memory = 8192
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
    end

    node.vm.network :private_network,
      # Link: R1-vfp-int1<--> R1-vfp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.247.2",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "127.255.247.1",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

    node.vm.network :private_network,
      # Link: R1-vfp-ge-0/0/0 <--> R2-vfp-ge-0/0/5
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.247.2",
      :libvirt__tunnel_local_port => 10002,
      :libvirt__tunnel_ip => "127.255.246.2",
      :libvirt__tunnel_port => 10002,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R1-vfp-ge-0/0/1 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.247.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R1-vfp-ge-0/0/2 <--> R8-vfp-ge-0/0/3
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.247.2",
      :libvirt__tunnel_local_port => 10004,
      :libvirt__tunnel_ip => "127.255.244.2",
      :libvirt__tunnel_port => 10004,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R1-vfp-ge-0/0/3 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.233.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      # node.vm.network :private_network,
      # # Link: R1-vfp-ge-0/0/3
      # :libvirt__network_name => "access1",
      # :libvirt__iface_name => "client-access2",
      # :mode => "none",
      # :libvirt__dhcp_enabled => false,
      # :autostart => true

      node.vm.network :private_network,
      # Link: R1-vfp-ge-0/0/4 <--> R4-vfp-ge-0/0/4
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.247.2",
      :libvirt__tunnel_local_port => 10003,
      :libvirt__tunnel_ip => "127.255.251.2",
      :libvirt__tunnel_port => 10003,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R1-vfp-ge-0/0/5
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.247.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R1-vfp-ge-0/0/6
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.247.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R1-vfp-ge-0/0/7
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.247.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false
  end






  config.vm.define "R2-vcp" do |node|
    guest_name = "R2-vcp"
    node.vm.box = "juniper/vmx-18.2R1.9-vcp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 1
      domain.memory = 1024
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2", :size => "196870144", :type => "qcow2", :bus => "ide", :device => "hdb", :allow_existing => true
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img", :size => "16777216", :type => "raw", :bus => "ide", :device => "hdc", :allow_existing => true
    end
    add_volumes = [
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 196870144",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 /opt/vagrant/storage/vmx-vcp-hdb-18.2R1.9-base.qcow2",
      "sleep 1",
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img 16777216",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img /opt/vagrant/storage/vmx-vcp-hdc-18.2R1.9-base.img",
      "sleep 1"
    ]
    add_volumes.each do |i|
      node.trigger.before :up do |trigger|
        trigger.name = "add-volumes"
        trigger.info = "Adding Volumes"
        trigger.run = {inline: i}
      end
    end

    delete_volumes = [
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 default",
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img default"
    ]
    delete_volumes.each do |i|
      node.trigger.after :destroy do |trigger|
        trigger.name = "remove-volumes"
        trigger.info = "Removing Volumes"
        trigger.run = {inline: i}
      end
    end

    node.vm.network :private_network,
      # Link: R2-vcp-int1 <--> R2-vfp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.246.1",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "127.255.246.2",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

  end
  config.vm.define "R2-vfp" do |node|
    guest_name = "R2"
    node.vm.box = "juniper/vmx-18.2R1.9-vfp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false
    node.ssh.username = "root"

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 8
      domain.memory = 16384
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
    end

    node.vm.network :private_network,
      # Link: R2-vfp-int1 <--> R2-vcp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.246.2",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "127.255.246.1",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

    node.vm.network :private_network,
      # Link: R2-vfp-ge-0/0/0 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.246.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R2-vfp-ge-0/0/1 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.246.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R2-vfp-ge-0/0/2 <--> R3-vfp-ge-0/0/2
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.246.2",
      :libvirt__tunnel_local_port => 10005,
      :libvirt__tunnel_ip => "127.255.255.2",
      :libvirt__tunnel_port => 10005,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R2-vfp-ge-0/0/3 <--> R7-vfp-ge-0/0/0
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.246.2",
      :libvirt__tunnel_local_port => 10006,
      :libvirt__tunnel_ip => "127.255.250.2",
      :libvirt__tunnel_port => 10006,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R2-vfp-ge-0/0/4 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.246.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      # node.vm.network :private_network,
      # # Link: R2-vfp-ge-0/0/4 <-->
      # :libvirt__network_name => "access1",
      # :libvirt__iface_name => "client-access",
      # :mode => "none",
      # :libvirt__dhcp_enabled => false,
      # :autostart => true

      node.vm.network :private_network,
      # Link: R2-vfp-ge-0/0/5 <--> R1-vfp-ge-0/0/0
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.246.2",
      :libvirt__tunnel_local_port => 10002,
      :libvirt__tunnel_ip => "127.255.247.2",
      :libvirt__tunnel_port => 10002,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R2-vfp-ge-0/0/6 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.246.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R2-vfp-ge-0/0/7 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.246.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false
  end

  config.vm.define "T1" do |node|
    #guest_name = "csr1k"
    guest_name = "T1"
    node.vm.box = "cisco/csr1000v"
    node.vm.guest = :freebsd
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true
    node.ssh.insert_key = false
    node.vm.boot_timeout = 180

  node.vm.provider :libvirt do |domain|
    domain.nic_adapter_count = 8
    domain.nic_model_type = "virtio"
    domain.memory = 4096
    domain.cpus = 2
    domain.driver = "kvm"
  end

  node.vm.network :private_network,
    # Link: T1 Gi2 <-->
    #:mac => "a0:00:00:00:00:21",
    :mac => "#{get_mac_cisco()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.253.2",
    :libvirt__tunnel_local_port => 88888,
    :libvirt__tunnel_ip => "169.69.69.69",
    :libvirt__tunnel_port => 88888,
    :libvirt__iface_name => "Gig2",
    auto_config: false
  end

  config.vm.define "C2" do |node|
    guest_name = "C2"
    node.vm.box = "cisco/csr1000v"
    node.vm.guest = :freebsd
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true
    node.ssh.insert_key = false
    node.vm.boot_timeout = 180

  node.vm.provider :libvirt do |domain|
    domain.nic_adapter_count = 8
    domain.nic_model_type = "virtio"
    domain.memory = 4096
    domain.cpus = 2
    domain.driver = "kvm"
  end

    node.vm.network :private_network,
      # Link: C2 Gi2 <-->
      #:mac => "a0:00:00:00:00:22",
      :mac => "#{get_mac_cisco()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.252.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "Gig2",
      auto_config: false
  end



  config.vm.define "C1" do |node|
    #guest_name = "csr1k"
    guest_name = "C1"
    node.vm.box = "cisco/csr1000v"
    node.vm.guest = :freebsd
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true
    node.ssh.insert_key = false
    node.vm.boot_timeout = 180

  node.vm.provider :libvirt do |domain|
    domain.nic_adapter_count = 8
    domain.nic_model_type = "virtio"
    domain.memory = 4096
    domain.cpus = 2
    domain.driver = "kvm"
  end

  node.vm.network :private_network,
    # Link: C1 Gi2 <-->
    #:mac => "a0:00:00:00:00:23",
    :mac => "#{get_mac_cisco()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.248.2",
    :libvirt__tunnel_local_port => 88888,
    :libvirt__tunnel_ip => "169.69.69.69",
    :libvirt__tunnel_port => 88888,
    :libvirt__iface_name => "Gig2",
    auto_config: false

  node.vm.network :private_network,
    # Link: C1 Gi3 <-->
    #:mac => "a0:00:00:00:00:24",
    :mac => "#{get_mac_cisco()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.248.2",
    :libvirt__tunnel_local_port => 88888,
    :libvirt__tunnel_ip => "169.69.69.69",
    :libvirt__tunnel_port => 88888,
    :libvirt__iface_name => "Gig3",
    auto_config: false
  end




  config.vm.define "R3-vcp" do |node|
    guest_name = "R3-vcp"
    node.vm.box = "juniper/vmx-18.2R1.9-vcp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 1
      domain.memory = 1024
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2", :size => "196870144", :type => "qcow2", :bus => "ide", :device => "hdb", :allow_existing => true
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img", :size => "16777216", :type => "raw", :bus => "ide", :device => "hdc", :allow_existing => true
    end
    add_volumes = [
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 196870144",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 /opt/vagrant/storage/vmx-vcp-hdb-18.2R1.9-base.qcow2",
      "sleep 1",
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img 16777216",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img /opt/vagrant/storage/vmx-vcp-hdc-18.2R1.9-base.img",
      "sleep 1"
    ]
    add_volumes.each do |i|
      node.trigger.before :up do |trigger|
        trigger.name = "add-volumes"
        trigger.info = "Adding Volumes"
        trigger.run = {inline: i}
      end
    end

    delete_volumes = [
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 default",
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img default"
    ]
    delete_volumes.each do |i|
      node.trigger.after :destroy do |trigger|
        trigger.name = "remove-volumes"
        trigger.info = "Removing Volumes"
        trigger.run = {inline: i}
      end
    end

    node.vm.network :private_network,
      # Link: R3-vcp-int1 <--> R3-vfp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.255.1",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "127.255.255.2",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

  end
  config.vm.define "R3-vfp" do |node|
    guest_name = "R3"
    node.vm.box = "juniper/vmx-18.2R1.9-vfp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false
    node.ssh.username = "root"

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 8
      domain.memory = 4096
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
    end

    node.vm.network :private_network,
      # Link: R3-vfp-int1 <--> R3-vcp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.255.2",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "127.255.255.1",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

    node.vm.network :private_network,
      # Link: R3-vfp-ge-0/0/0 <--> R4-vfp-ge-0/0/2
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.255.2",
      :libvirt__tunnel_local_port => 10006,
      :libvirt__tunnel_ip => "127.255.251.2",
      :libvirt__tunnel_port => 10006,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R3-vfp-ge-0/0/1 <-->
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.255.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R3-vfp-ge-0/0/2 <--> R2-vfp-ge-0/0/2
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.255.2",
      :libvirt__tunnel_local_port => 10005,
      :libvirt__tunnel_ip => "127.255.246.2",
      :libvirt__tunnel_port => 10005,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R3-vfp-ge-0/0/3 <--> R6-vfp-ge-0/0/3
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.255.2",
      :libvirt__tunnel_local_port => 10007,
      :libvirt__tunnel_ip => "127.255.254.2",
      :libvirt__tunnel_port => 10007,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R3-vfp-ge-0/0/4 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.255.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R3-vfp-ge-0/0/5 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.255.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R3-vfp-ge-0/0/6 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.255.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R3-vfp-ge-0/0/7 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.255.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false
  end

  config.vm.define "R4-vcp" do |node|
    guest_name = "R4-vcp"
    node.vm.box = "juniper/vmx-18.2R1.9-vcp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 1
      domain.memory = 1024
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2", :size => "196870144", :type => "qcow2", :bus => "ide", :device => "hdb", :allow_existing => true
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img", :size => "16777216", :type => "raw", :bus => "ide", :device => "hdc", :allow_existing => true
    end
    add_volumes = [
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 196870144",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 /opt/vagrant/storage/vmx-vcp-hdb-18.2R1.9-base.qcow2",
      "sleep 1",
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img 16777216",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img /opt/vagrant/storage/vmx-vcp-hdc-18.2R1.9-base.img",
      "sleep 1"
    ]
    add_volumes.each do |i|
      node.trigger.before :up do |trigger|
        trigger.name = "add-volumes"
        trigger.info = "Adding Volumes"
        trigger.run = {inline: i}
      end
    end

  delete_volumes = [
    "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 default",
    "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img default"
  ]
  delete_volumes.each do |i|
    node.trigger.after :destroy do |trigger|
      trigger.name = "remove-volumes"
      trigger.info = "Removing Volumes"
      trigger.run = {inline: i}
    end
  end

  node.vm.network :private_network,
    # Link: R4-vcp-int1 <--> R4-vfp-int1
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.251.1",
    :libvirt__tunnel_local_port => 10001,
    :libvirt__tunnel_ip => "127.255.251.2",
    :libvirt__tunnel_port => 10001,
    :libvirt__iface_name => "internal",
    auto_config: false

  end


  config.vm.define "R4-vfp" do |node|
    guest_name = "R4-vfp"
    node.vm.box = "juniper/vmx-18.2R1.9-vfp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false
    node.ssh.username = "root"

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 8
      domain.memory = 4096
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
    end

    node.vm.network :private_network,
      # Link: R4-vfp-int1 <--> R4-vcp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.251.2",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "127.255.251.1",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

    node.vm.network :private_network,
      # Link: R4-vfp-ge-0/0/0 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.251.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R4-vfp-ge-0/0/1 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.251.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R4-vfp-ge-0/0/2 <--> R3-vfp-ge-0/0/0 
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.251.2",
      :libvirt__tunnel_local_port => 10006,
      :libvirt__tunnel_ip => "127.255.255.2",
      :libvirt__tunnel_port => 10006,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R4-vfp-ge-0/0/3 <--> R5-vfp-ge-0/0/3
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.251.2",
      :libvirt__tunnel_local_port => 10008,
      :libvirt__tunnel_ip => "127.255.252.2",
      :libvirt__tunnel_port => 10008,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
        # Link: R4-vfp-ge-0/0/4 <--> R1-vfp-ge-0/0/4
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.251.2",
      :libvirt__tunnel_local_port => 10003,
      :libvirt__tunnel_ip => "127.255.247.2",
      :libvirt__tunnel_port => 10003,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R4-vfp-ge-0/0/5 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.251.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R4-vfp-ge-0/0/6 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.251.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R4-vfp-ge-0/0/7 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.251.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false
    end


  config.vm.define "R5-vcp" do |node|
    guest_name = "R5-vcp"
    node.vm.box = "juniper/vmx-18.2R1.9-vcp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 1
      domain.memory = 1024
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2", :size => "196870144", :type => "qcow2", :bus => "ide", :device => "hdb", :allow_existing => true
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img", :size => "16777216", :type => "raw", :bus => "ide", :device => "hdc", :allow_existing => true
    end
    add_volumes = [
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 196870144",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 /opt/vagrant/storage/vmx-vcp-hdb-18.2R1.9-base.qcow2",
      "sleep 1",
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img 16777216",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img /opt/vagrant/storage/vmx-vcp-hdc-18.2R1.9-base.img",
      "sleep 1"
    ]
    add_volumes.each do |i|
      node.trigger.before :up do |trigger|
        trigger.name = "add-volumes"
        trigger.info = "Adding Volumes"
        trigger.run = {inline: i}
      end
    end

    delete_volumes = [
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 default",
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img default"
    ]
    delete_volumes.each do |i|
      node.trigger.after :destroy do |trigger|
        trigger.name = "remove-volumes"
        trigger.info = "Removing Volumes"
        trigger.run = {inline: i}
      end
    end

    node.vm.network :private_network,
      # Link: R5-vcp-int1 <--> R5-vfp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.252.1",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "127.255.252.2",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

  end

  config.vm.define "R5-vfp" do |node|
    guest_name = "R5-vfp"
    node.vm.box = "juniper/vmx-18.2R1.9-vfp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false
    node.ssh.username = "root"

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 8
      domain.memory = 4096
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
    end

    node.vm.network :private_network,
      # Link: R5-vfp-int1 <--> R5-vcp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.252.2",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "127.255.252.1",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

    node.vm.network :private_network,
      # Link: R5-vfp-ge-0/0/0 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.252.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "127.255.254.2",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R5-vfp-ge-0/0/1 <--> R6-vfp-ge-0/0/1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.252.2",
      :libvirt__tunnel_local_port => 10009,
      :libvirt__tunnel_ip => "127.255.254.2",
      :libvirt__tunnel_port => 10009,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R5-vfp-ge-0/0/2 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.252.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R5-vfp-ge-0/0/3 <--> R4-vfp-ge-0/0/3
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.252.2",
      :libvirt__tunnel_local_port => 10008,
      :libvirt__tunnel_ip => "127.255.251.2",
      :libvirt__tunnel_port => 10008,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
        # Link: R5-vfp-ge-0/0/4 <--> R8-vfp-ge-0/0/5
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.252.2",
      :libvirt__tunnel_local_port => 10010,
      :libvirt__tunnel_ip => "127.255.244.2",
      :libvirt__tunnel_port => 10010,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R5-vfp-ge-0/0/5 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.252.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R5-vfp-ge-0/0/6 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.252.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R5-vfp-ge-0/0/7 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.252.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false
    end


    config.vm.define "R6-vcp" do |node|
    guest_name = "R6-vcp"
    node.vm.box = "juniper/vmx-18.2R1.9-vcp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 1
      domain.memory = 1024
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2", :size => "196870144", :type => "qcow2", :bus => "ide", :device => "hdb", :allow_existing => true
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img", :size => "16777216", :type => "raw", :bus => "ide", :device => "hdc", :allow_existing => true
    end
    add_volumes = [
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 196870144",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 /opt/vagrant/storage/vmx-vcp-hdb-18.2R1.9-base.qcow2",
      "sleep 1",
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img 16777216",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img /opt/vagrant/storage/vmx-vcp-hdc-18.2R1.9-base.img",
      "sleep 1"
    ]
    add_volumes.each do |i|
      node.trigger.before :up do |trigger|
        trigger.name = "add-volumes"
        trigger.info = "Adding Volumes"
        trigger.run = {inline: i}
      end
    end

    delete_volumes = [
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 default",
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img default"
    ]
    delete_volumes.each do |i|
      node.trigger.after :destroy do |trigger|
        trigger.name = "remove-volumes"
        trigger.info = "Removing Volumes"
        trigger.run = {inline: i}
      end
    end

    node.vm.network :private_network,
      # Link: R6-vcp-int1 <--> R6-vfp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.254.1",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "127.255.254.2",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

  end

  config.vm.define "R6-vfp" do |node|
    guest_name = "R6-vfp"
    node.vm.box = "juniper/vmx-18.2R1.9-vfp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false
    node.ssh.username = "root"

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 8
      domain.memory = 4096
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
    end

    node.vm.network :private_network,
      # Link: R6-vfp-int1 <--> R6-vcp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.254.2",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "127.255.254.1",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

    node.vm.network :private_network,
      # Link: R6-vfp-ge-0/0/0 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.253.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R6-vfp-ge-0/0/1 <--> R5-vfp-ge-0/0/1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.254.2",
      :libvirt__tunnel_local_port => 10009,
      :libvirt__tunnel_ip => "127.255.252.2",
      :libvirt__tunnel_port => 10009,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R6-vfp-ge-0/0/2 <--> R7-vfp-ge-0/0/2
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.254.2",
      :libvirt__tunnel_local_port => 10011,
      :libvirt__tunnel_ip => "127.255.250.2",
      :libvirt__tunnel_port => 10011,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R6-vfp-ge-0/0/3 <--> R3-vfp-ge-0/0/3
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.254.2",
      :libvirt__tunnel_local_port => 10007,
      :libvirt__tunnel_ip => "127.255.255.2",
      :libvirt__tunnel_port => 10007,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R6-vfp-ge-0/0/4 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.254.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R6-vfp-ge-0/0/5 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.254.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R6-vfp-ge-0/0/6 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.254.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: R6-vfp-ge-0/0/7 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.254.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false
    end


  config.vm.define "R7-vcp" do |node|
    guest_name = "R7-vcp"
    node.vm.box = "juniper/vmx-18.2R1.9-vcp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 1
      domain.memory = 1024
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2", :size => "196870144", :type => "qcow2", :bus => "ide", :device => "hdb", :allow_existing => true
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img", :size => "16777216", :type => "raw", :bus => "ide", :device => "hdc", :allow_existing => true
    end
    add_volumes = [
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 196870144",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 /opt/vagrant/storage/vmx-vcp-hdb-18.2R1.9-base.qcow2",
      "sleep 1",
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img 16777216",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img /opt/vagrant/storage/vmx-vcp-hdc-18.2R1.9-base.img",
      "sleep 1"
    ]
    add_volumes.each do |i|
      node.trigger.before :up do |trigger|
        trigger.name = "add-volumes"
        trigger.info = "Adding Volumes"
        trigger.run = {inline: i}
      end
    end

    delete_volumes = [
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 default",
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img default"
    ]
    delete_volumes.each do |i|
      node.trigger.after :destroy do |trigger|
        trigger.name = "remove-volumes"
        trigger.info = "Removing Volumes"
        trigger.run = {inline: i}
      end
    end

    node.vm.network :private_network,
      # Link: R7-vcp-int1 <--> R7-vfp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.250.1",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "127.255.250.2",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

  end

config.vm.define "R7-vfp" do |node|
  guest_name = "R7-vfp"
  node.vm.box = "juniper/vmx-18.2R1.9-vfp"
  node.vm.box_version = "18.2R1.9"
  node.vm.guest = :tinycore
  node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

  node.ssh.insert_key = false
  node.ssh.username = "root"

  node.vm.provider :libvirt do |domain|
    domain.default_prefix = "#{domain_prefix}"
    domain.cpus = 8
    domain.memory = 4096
    domain.disk_bus = "ide"
    domain.nic_adapter_count = 11
  end

  node.vm.network :private_network,
    # Link: R7-vfp-int1 <--> R7-vcp-int1
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.250.2",
    :libvirt__tunnel_local_port => 10001,
    :libvirt__tunnel_ip => "127.255.250.1",
    :libvirt__tunnel_port => 10001,
    :libvirt__iface_name => "internal",
    auto_config: false

  node.vm.network :private_network,
    # Link: R7-vfp-ge-0/0/0 <--> R2-vfp-ge-0/0/3
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.250.2",
    :libvirt__tunnel_local_port => 10006,
    :libvirt__tunnel_ip => "127.255.246.2",
    :libvirt__tunnel_port => 10006,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R7-vfp-ge-0/0/1 <-->
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.250.2",
    :libvirt__tunnel_local_port => 88888,
    :libvirt__tunnel_ip => "169.69.69.69",
    :libvirt__tunnel_port => 88888,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R7-vfp-ge-0/0/2 <--> R6-vfp-ge-0/0/2
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.250.2",
    :libvirt__tunnel_local_port => 10011,
    :libvirt__tunnel_ip => "127.255.254.2",
    :libvirt__tunnel_port => 10011,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R7-vfp-ge-0/0/3 <-->
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.250.2",
    :libvirt__tunnel_local_port => 88888,
    :libvirt__tunnel_ip => "169.69.69.69",
    :libvirt__tunnel_port => 88888,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R7-vfp-ge-0/0/4 <--> R8-vfp-ge-0/0/1
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.250.2",
    :libvirt__tunnel_local_port => 10012,
    :libvirt__tunnel_ip => "127.255.244.2",
    :libvirt__tunnel_port => 10012,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R7-vfp-ge-0/0/5 <-->
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.250.2",
    :libvirt__tunnel_local_port => 88888,
    :libvirt__tunnel_ip => "169.69.69.69",
    :libvirt__tunnel_port => 88888,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R7-vfp-ge-0/0/6 <-->
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.250.2",
    :libvirt__tunnel_local_port => 88888,
    :libvirt__tunnel_ip => "169.69.69.69",
    :libvirt__tunnel_port => 88888,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R7-vfp-ge-0/0/7 <-->
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.250.2",
    :libvirt__tunnel_local_port => 88888,
    :libvirt__tunnel_ip => "169.69.69.69",
    :libvirt__tunnel_port => 88888,
    :libvirt__iface_name => "external",
    auto_config: false
  end


  config.vm.define "R8-vcp" do |node|
    guest_name = "R8-vcp"
    node.vm.box = "juniper/vmx-18.2R1.9-vcp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 1
      domain.memory = 1024
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2", :size => "196870144", :type => "qcow2", :bus => "ide", :device => "hdb", :allow_existing => true
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img", :size => "16777216", :type => "raw", :bus => "ide", :device => "hdc", :allow_existing => true
    end
    add_volumes = [
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 196870144",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 /opt/vagrant/storage/vmx-vcp-hdb-18.2R1.9-base.qcow2",
      "sleep 1",
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img 16777216",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img /opt/vagrant/storage/vmx-vcp-hdc-18.2R1.9-base.img",
      "sleep 1"
    ]
    add_volumes.each do |i|
      node.trigger.before :up do |trigger|
        trigger.name = "add-volumes"
        trigger.info = "Adding Volumes"
        trigger.run = {inline: i}
      end
    end

    delete_volumes = [
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 default",
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img default"
    ]
    delete_volumes.each do |i|
      node.trigger.after :destroy do |trigger|
        trigger.name = "remove-volumes"
        trigger.info = "Removing Volumes"
        trigger.run = {inline: i}
      end
    end

    node.vm.network :private_network,
      # Link: R8-vcp-int1 <--> R8-vfp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.244.1",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "127.255.244.2",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

  end

config.vm.define "R8-vfp" do |node|
  guest_name = "R8-vfp"
  node.vm.box = "juniper/vmx-18.2R1.9-vfp"
  node.vm.box_version = "18.2R1.9"
  node.vm.guest = :tinycore
  node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

  node.ssh.insert_key = false
  node.ssh.username = "root"

  node.vm.provider :libvirt do |domain|
    domain.default_prefix = "#{domain_prefix}"
    domain.cpus = 8
    domain.memory = 4096
    domain.disk_bus = "ide"
    domain.nic_adapter_count = 11
  end

  node.vm.network :private_network,
    # Link: R8-vfp-int1 <--> R8-vcp-int1
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.244.2",
    :libvirt__tunnel_local_port => 10001,
    :libvirt__tunnel_ip => "127.255.244.1",
    :libvirt__tunnel_port => 10001,
    :libvirt__iface_name => "internal",
    auto_config: false

  node.vm.network :private_network,
    # Link: R8-vfp-ge-0/0/0 <-->
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.244.2",
    :libvirt__tunnel_local_port => 88888,
    :libvirt__tunnel_ip => "169.69.69.69",
    :libvirt__tunnel_port => 88888,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R8-vfp-ge-0/0/1 <--> R7-vfp-ge-0/0/4
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.244.2",
    :libvirt__tunnel_local_port => 10012,
    :libvirt__tunnel_ip => "127.255.250.2",
    :libvirt__tunnel_port => 10012,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R8-vfp-ge-0/0/2 <-->
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.244.2",
    :libvirt__tunnel_local_port => 88888,
    :libvirt__tunnel_ip => "169.69.69.69",
    :libvirt__tunnel_port => 88888,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R8-vfp-ge-0/0/3 <--> R1-vfp-ge-0/0/2
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.244.2",
    :libvirt__tunnel_local_port => 10004,
    :libvirt__tunnel_ip => "127.255.247.2",
    :libvirt__tunnel_port => 10004,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R8-vfp-ge-0/0/4 <-->
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.244.2",
    :libvirt__tunnel_local_port => 88888,
    :libvirt__tunnel_ip => "169.69.69.69",
    :libvirt__tunnel_port => 88888,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R8-vfp-ge-0/0/5 <--> R5-vfp-ge-0/0/4
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.244.2",
    :libvirt__tunnel_local_port => 10010,
    :libvirt__tunnel_ip => "127.255.252.2",
    :libvirt__tunnel_port => 10010,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R8-vfp-ge-0/0/6 <-->
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.244.2",
    :libvirt__tunnel_local_port => 88888,
    :libvirt__tunnel_ip => "169.69.69.69",
    :libvirt__tunnel_port => 88888,
    :libvirt__iface_name => "external",
    auto_config: false

    node.vm.network :private_network,
    # Link: R8-vfp-ge-0/0/7 <-->
    :mac => "#{get_mac()}",
    :libvirt__tunnel_type => "udp",
    :libvirt__tunnel_local_ip => "127.255.244.2",
    :libvirt__tunnel_local_port => 88888,
    :libvirt__tunnel_ip => "169.69.69.69",
    :libvirt__tunnel_port => 88888,
    :libvirt__iface_name => "external",
    auto_config: false
  end


          config.vm.define "DC1-vcp" do |node|
            guest_name = "DC1-vcp"
            node.vm.box = "juniper/vmx-18.2R1.9-vcp"
            node.vm.box_version = "18.2R1.9"
            node.vm.guest = :tinycore
            node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

            node.ssh.insert_key = false

            node.vm.provider :libvirt do |domain|
              domain.default_prefix = "#{domain_prefix}"
              domain.cpus = 1
              domain.memory = 1024
              domain.disk_bus = "ide"
              domain.nic_adapter_count = 11
              domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2", :size => "196870144", :type => "qcow2", :bus => "ide", :device => "hdb", :allow_existing => true
              domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img", :size => "16777216", :type => "raw", :bus => "ide", :device => "hdc", :allow_existing => true
            end
            add_volumes = [
              "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 196870144",
              "sleep 1",
              "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 /opt/vagrant/storage/vmx-vcp-hdb-18.2R1.9-base.qcow2",
              "sleep 1",
              "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img 16777216",
              "sleep 1",
              "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img /opt/vagrant/storage/vmx-vcp-hdc-18.2R1.9-base.img",
              "sleep 1"
            ]
            add_volumes.each do |i|
              node.trigger.before :up do |trigger|
                trigger.name = "add-volumes"
                trigger.info = "Adding Volumes"
                trigger.run = {inline: i}
              end
            end

            delete_volumes = [
              "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 default",
              "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img default"
            ]
            delete_volumes.each do |i|
              node.trigger.after :destroy do |trigger|
                trigger.name = "remove-volumes"
                trigger.info = "Removing Volumes"
                trigger.run = {inline: i}
              end
            end

            node.vm.network :private_network,
              # Link: DC1-vcp-int1 <--> DC1-vfp-int1
              :mac => "#{get_mac()}",
              :libvirt__tunnel_type => "udp",
              :libvirt__tunnel_local_ip => "127.255.249.1",
              :libvirt__tunnel_local_port => 10001,
              :libvirt__tunnel_ip => "169.69.69.69",
              :libvirt__tunnel_port => 10001,
              :libvirt__iface_name => "internal",
              auto_config: false

          end

          config.vm.define "DC1-vfp" do |node|
            guest_name = "DC1-vfp"
            node.vm.box = "juniper/vmx-18.2R1.9-vfp"
            node.vm.box_version = "18.2R1.9"
            node.vm.guest = :tinycore
            node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

            node.ssh.insert_key = false
            node.ssh.username = "root"

            node.vm.provider :libvirt do |domain|
              domain.default_prefix = "#{domain_prefix}"
              domain.cpus = 8
              domain.memory = 4096
              domain.disk_bus = "ide"
              domain.nic_adapter_count = 11
            end

            node.vm.network :private_network,
              # Link: DC1-vfp-int1 <--> DC1-vcp-int1
              :mac => "#{get_mac()}",
              :libvirt__tunnel_type => "udp",
              :libvirt__tunnel_local_ip => "127.255.249.2",
              :libvirt__tunnel_local_port => 10001,
              :libvirt__tunnel_ip => "169.69.69.69",
              :libvirt__tunnel_port => 10001,
              :libvirt__iface_name => "internal",
              auto_config: false

            node.vm.network :private_network,
              # Link: DC1-vfp-ge-0/0/0 <-->
              :mac => "#{get_mac()}",
              :libvirt__tunnel_type => "udp",
              :libvirt__tunnel_local_ip => "127.255.249.2",
              :libvirt__tunnel_local_port => 88888,
              :libvirt__tunnel_ip => "169.69.69.69",
              :libvirt__tunnel_port => 88888,
              :libvirt__iface_name => "external",
              auto_config: false

              node.vm.network :private_network,
              # Link: DC1-vfp-ge-0/0/1 <-->
              :mac => "#{get_mac()}",
              :libvirt__tunnel_type => "udp",
              :libvirt__tunnel_local_ip => "127.255.249.2",
              :libvirt__tunnel_local_port => 88888,
              :libvirt__tunnel_ip => "169.69.69.69",
              :libvirt__tunnel_port => 88888,
              :libvirt__iface_name => "external",
              auto_config: false

              node.vm.network :private_network,
              # Link: DC1-vfp-ge-0/0/2 <-->
              :mac => "#{get_mac()}",
              :libvirt__tunnel_type => "udp",
              :libvirt__tunnel_local_ip => "127.255.249.2",
              :libvirt__tunnel_local_port => 88888,
              :libvirt__tunnel_ip => "169.69.69.69",
              :libvirt__tunnel_port => 88888,
              :libvirt__iface_name => "external",
              auto_config: false

              node.vm.network :private_network,
              # Link: DC1-vfp-ge-0/0/3 <-->
              :mac => "#{get_mac()}",
              :libvirt__tunnel_type => "udp",
              :libvirt__tunnel_local_ip => "127.255.249.2",
              :libvirt__tunnel_local_port => 88888,
              :libvirt__tunnel_ip => "169.69.69.69",
              :libvirt__tunnel_port => 88888,
              :libvirt__iface_name => "external",
              auto_config: false

              node.vm.network :private_network,
                # Link: DC1-vfp-ge-0/0/4 <-->
              :mac => "#{get_mac()}",
              :libvirt__tunnel_type => "udp",
              :libvirt__tunnel_local_ip => "127.255.249.2",
              :libvirt__tunnel_local_port => 88888,
              :libvirt__tunnel_ip => "169.69.69.69",
              :libvirt__tunnel_port => 88888,
              :libvirt__iface_name => "external",
              auto_config: false

              node.vm.network :private_network,
              # Link: DC1-vfp-ge-0/0/5 <-->
              :mac => "#{get_mac()}",
              :libvirt__tunnel_type => "udp",
              :libvirt__tunnel_local_ip => "127.255.249.2",
              :libvirt__tunnel_local_port => 88888,
              :libvirt__tunnel_ip => "169.69.69.69",
              :libvirt__tunnel_port => 88888,
              :libvirt__iface_name => "external",
              auto_config: false

              node.vm.network :private_network,
              # Link: DC1-vfp-ge-0/0/6 <-->
              :mac => "#{get_mac()}",
              :libvirt__tunnel_type => "udp",
              :libvirt__tunnel_local_ip => "127.255.249.2",
              :libvirt__tunnel_local_port => 88888,
              :libvirt__tunnel_ip => "169.69.69.69",
              :libvirt__tunnel_port => 88888,
              :libvirt__iface_name => "external",
              auto_config: false

              node.vm.network :private_network,
              # Link: DC1-vfp-ge-0/0/7 <-->
              :mac => "#{get_mac()}",
              :libvirt__tunnel_type => "udp",
              :libvirt__tunnel_local_ip => "127.255.249.2",
              :libvirt__tunnel_local_port => 88888,
              :libvirt__tunnel_ip => "169.69.69.69",
              :libvirt__tunnel_port => 88888,
              :libvirt__iface_name => "external",
              auto_config: false
            end


  config.vm.define "P1-vcp" do |node|
    guest_name = "P1-vcp"
    node.vm.box = "juniper/vmx-18.2R1.9-vcp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 1
      domain.memory = 1024
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2", :size => "196870144", :type => "qcow2", :bus => "ide", :device => "hdb", :allow_existing => true
      domain.storage :file, :path => "#{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img", :size => "16777216", :type => "raw", :bus => "ide", :device => "hdc", :allow_existing => true
    end
    add_volumes = [
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 196870144",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 /opt/vagrant/storage/vmx-vcp-hdb-18.2R1.9-base.qcow2",
      "sleep 1",
      "virsh vol-create-as default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img 16777216",
      "sleep 1",
      "virsh vol-upload --pool default #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img /opt/vagrant/storage/vmx-vcp-hdc-18.2R1.9-base.img",
      "sleep 1"
    ]
    add_volumes.each do |i|
      node.trigger.before :up do |trigger|
        trigger.name = "add-volumes"
        trigger.info = "Adding Volumes"
        trigger.run = {inline: i}
      end
    end

    delete_volumes = [
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdb-18.2R1.9-base.qcow2 default",
      "virsh vol-delete #{username}-#{guest_name}-vmx-vcp-hdc-18.2R1.9-base.img default"
    ]
    delete_volumes.each do |i|
      node.trigger.after :destroy do |trigger|
        trigger.name = "remove-volumes"
        trigger.info = "Removing Volumes"
        trigger.run = {inline: i}
      end
    end

    node.vm.network :private_network,
      # Link: P1-vcp-int1 <--> P1-vfp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.245.1",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

  end
  config.vm.define "P1-vfp" do |node|
    guest_name = "P1"
    node.vm.box = "juniper/vmx-18.2R1.9-vfp"
    node.vm.box_version = "18.2R1.9"
    node.vm.guest = :tinycore
    node.vm.synced_folder ".", "/vagrant", id: "vagrant-root", disabled: true

    node.ssh.insert_key = false
    node.ssh.username = "root"

    node.vm.provider :libvirt do |domain|
      domain.default_prefix = "#{domain_prefix}"
      domain.cpus = 8
      domain.memory = 4096
      domain.disk_bus = "ide"
      domain.nic_adapter_count = 11
    end

    node.vm.network :private_network,
      # Link: P1-vfp-int1 <--> P1-vcp-int1
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.245.2",
      :libvirt__tunnel_local_port => 10001,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 10001,
      :libvirt__iface_name => "internal",
      auto_config: false

    node.vm.network :private_network,
      # Link: P1-vfp-ge-0/0/0 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.245.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: P1-vfp-ge-0/0/1 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.245.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: P1-vfp-ge-0/0/2 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.245.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: P1-vfp-ge-0/0/3 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.245.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: P1-vfp-ge-0/0/4 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.245.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      # node.vm.network :private_network,
      # # Link: P1-vfp-ge-0/0/4 <-->
      # :libvirt__network_name => "access1",
      # :libvirt__iface_name => "client-access3",
      # :mode => "none",
      # :libvirt__dhcp_enabled => false,
      # :autostart => true

      node.vm.network :private_network,
      # Link: P1-vfp-ge-0/0/5 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.245.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link: P1-vfp-ge-0/0/6 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.245.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false

      node.vm.network :private_network,
      # Link:P1-vfp-ge-0/0/7 <-->
      :mac => "#{get_mac()}",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.255.245.2",
      :libvirt__tunnel_local_port => 88888,
      :libvirt__tunnel_ip => "169.69.69.69",
      :libvirt__tunnel_port => 88888,
      :libvirt__iface_name => "external",
      auto_config: false
  end

#    config.vm.provision "ansible" do |ansible|
#          ansible.groups = {
#              "all" => ["all"]
#          }
#          ansible.playbook = "playbook.yml"
#        end


end
