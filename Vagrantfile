Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.network "forwarded_port", guest: 80, host: 8000, auto_correct: true

  config.vm.synced_folder "./", "/var/www", create: true,
    group: "ubuntu",
    owner: "ubuntu",
    mount_options: ["dmode=777,fmode=777"]
        

  config.vm.provider "virtualbox" do |v|
    v.name = "rshs2"
    v.customize ["modifyvm", :id, "--memory", "512"]
  end

  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  config.vm.provision :shell, :path => "provision/setup.sh"
end
