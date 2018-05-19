Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"
  config.disksize.size = "20GB"
  config.vm.network "forwarded_port", guest: 8080, host: 8080

  config.vm.provider "virtualbox" do |v|
       v.memory = 2048
  end

  config.vm.define "legadasa-wordpress" do |m|
        m.vm.network "private_network", ip: "172.42.42.11"
  end
end
