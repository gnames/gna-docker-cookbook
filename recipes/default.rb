include_recipe "gna-docker::docker"

env = node.environment

return unless data_bag("gna-docker").include?(env)

dbag = data_bag_item("gna-docker", env)
node_conf = dbag[node.name]

log "node_conf: %s" % node_conf

group "docker" do
  members dbag["docker_members"]
end

return unless node_conf

directory "/opt/gna/shared" do
  user "root"
  group "docker"
  mode "0775"
  recursive true
end

file "/opt/gna/shared/containers" do
  content node_conf["containers"].map { |c| c["name"] }.join("\n")
  owner "root"
  group "docker"
  mode 00644
end

names = []
node_conf["containers"].each do |c|
  names << c["name"]
  docker_container c["name"] do
    config c
  end
end

%w(docker-clean docker-nuke docker-names).each do |f|
  cookbook_file f do
    path "/usr/local/bin/#{f}"
    mode "0755"
    action :create
  end
end

template "/usr/local/bin/stop-all" do
  source "stop_all.erb"
  variables names: names
  mode "775"
  user "root"
  group "docker"
end

template "/usr/local/bin/restart-all" do
  source "restart_all.erb"
  variables names: names
  mode "775"
  user "root"
  group "docker"
end
