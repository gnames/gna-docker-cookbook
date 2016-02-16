def install_ubuntu
  include_recipe "apt"
  apt_repository "docker" do
    uri "http://get.docker.com/ubuntu"
    distribution "docker"
    #distribution node["lsb"]["codename"]
    components ["main"]
    keyserver "keyserver.ubuntu.com"
    key "36A1D7869245C8950F966E92D8576A8BA88D21E9"
  end
  package "lxc-docker"
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
