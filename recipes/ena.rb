
include_recipe 'build-essential'

%w[ git
    kernel-devel ].each do |p|
  package p
end

git '/usr/local/src/amzn-drivers' do
  repository 'https://github.com/amzn/amzn-drivers'
  revision 'master'
  action :sync
  depth 1
end

bash 'compile ena kernel module' do
  cwd '/usr/local/src/amzn-drivers/kernel/linux/ena'
  code 'make'
  not_if { File.exist?('/usr/local/src/amzn-drivers/kernel/linux/ena/ena.ko') }
end

bash 'install kernel module' do
  code 'cp /usr/local/src/amzn-drivers/kernel/linux/ena/ena.ko /lib/modules/$(uname -r)/ && depmod'
  not_if 'test -f /lib/modules/$(uname -r)/ena.ko'
end

bash 'load module' do
  code 'modprobe ena'
  not_if 'lsmod |grep -q ena'
end

cookbook_file '/etc/sysconfig/modules/ena.modules' do
  source 'ena.modules'
  mode '0755'
  only_if { node['platform'] == 'centos' }
  only_if { node['platform_version'] >= '7.0' }
end

