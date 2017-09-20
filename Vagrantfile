Vagrant.configure('2') do |config|
  config.vm.box = 'geerlingguy/ubuntu1604'

  config.vm.provider 'vmware_fusion' do |provider|
    provider.vmx['memsize'] = '1024'
    provider.vmx['numvcpus'] = '4'
    provider.vmx['synctime'] = '1'
  end

  config.vm.network :forwarded_port, guest: 3306, host: 3306
  config.vm.synced_folder '.', '/vagrant'
end
