MASTER_COUNT        = 1
NODE_COUNT          = 0
INSTALL_K3S_VERSION = 'v1.19.4+k3s1'

IMAGE_PER_VM        = "ubuntu/bionic64"
MEMORY_PER_VM       = "4096"               # "2048" "4096"
CPU_PER_VM          = 2

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |vb|
    vb.linked_clone = true
    vb.cpus = CPU_PER_VM
    vb.memory = MEMORY_PER_VM
  end

  (1..MASTER_COUNT).each do |i|
    config.vm.define "kubemaster#{i}" do |kubemasters|
      kubemasters.vm.box = IMAGE_PER_VM
      kubemasters.vm.hostname = "kubemaster#{i}"
      kubemasters.vm.network  :private_network, ip: "10.0.0.#{i+10}"
      kubemasters.vm.provision "file", source: "./.ssh/id_rsa.pub", destination: "/tmp/id_rsa.pub"
      kubemasters.vm.provision "file", source: "./.ssh/id_rsa", destination: "/tmp/id_rsa"
      kubemasters.vm.provision "shell", privileged: true,  path: "scripts/master_install.sh", env: 
        { INSTALL_K3S_VERSION:INSTALL_K3S_VERSION, 
          K3S_MASTER_ADDITIONAL_OPTS: ENV['K3S_MASTER_ADDITIONAL_OPTS'].to_s
        }
    end
  end

  (1..NODE_COUNT).each do |i|
    config.vm.define "kubenode#{i}" do |kubenodes|
      kubenodes.vm.box = IMAGE_PER_VM
      kubenodes.vm.hostname = "kubenode#{i}"
      kubenodes.vm.network  :private_network, ip: "10.0.0.#{i+20}"
      kubenodes.vm.provision "file", source: "./.ssh/id_rsa.pub", destination: "/tmp/id_rsa.pub"
      kubenodes.vm.provision "file", source: "./.ssh/id_rsa", destination: "/tmp/id_rsa"
      kubenodes.vm.provision "shell", privileged: true,  path: "scripts/node_install.sh", env: {INSTALL_K3S_VERSION:INSTALL_K3S_VERSION}
    end
  end

# config.vm.define "front_lb" do |traefik|
#     traefik.vm.box = IMAGE_PER_VM
#     traefik.vm.hostname = "traefik"
#     traefik.vm.network  :private_network, ip: "10.0.0.30"   
#     traefik.vm.provision "file", source: "./scripts/traefik/dynamic_conf.toml", destination: "/tmp/traefikconf/dynamic_conf.toml"
#     traefik.vm.provision "file", source: "./scripts/traefik/static_conf.toml", destination: "/tmp/traefikconf/static_conf.toml"
#     traefik.vm.provision "shell", privileged: true,  path: "scripts/lb_install.sh"
#     traefik.vm.network "forwarded_port", guest: 6443, host: 6443
# end
end
