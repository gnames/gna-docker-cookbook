def install_ubuntu
  include_recipe "apt"
  package "apt-transport-https"
  package "ca-certificates"

  apt_package "lxc-docker" do
    action :purge
  end

  apt_repository "docker" do
    uri "http://get.docker.com/ubuntu"
    uri "https://apt.dockerproject.org/repo"
    distribution "ubuntu-trusty"
    #distribution node["lsb"]["codename"]
    components ["main"]
    keyserver "hkp://p80.pool.sks-keyservers.net:80"
    key "58118E89F3A912897C070ADBF76221572C52609D"
  end

  package "docker-engine"

end

def install_rhel
  include_recipe "yum-epel"
  # This can cause docker daemon to restart, which is BAD:
  # package "docker-io" do
  #   action :upgrade
  # end

  service "docker" do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :start ]
  end
end

if platform?("ubuntu")
  install_ubuntu
elsif platform?("redhat", "centos")
  install_rhel
else
  raise("#{node['platform']} is not supported")
end
