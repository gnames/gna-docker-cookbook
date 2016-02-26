define :docker_container, config: nil do

  conf = params[:config]
  params = conf["params"]
  shared_files = []
  shared_config_files = []
  shared_ports = []
  env_files = []

  log "params"
  log params

  directory "/opt/gna/#{conf["name"]}" do
    user "root"
    action :delete
    recursive true
  end

  ef = conf["env_files"]
  if ef
    ef.each do |env_file|
      env_files << env_file
    end
  end

  cf = conf["config_files"]
  if cf
    cf.each do |f|
      directory File.dirname(f["host"]) do
        recursive true
        user "root"
        group "docker"
        mode "775"
      end
      template f["host"] do
        user "root"
        group "docker"
        mode "664"
        source f["template"]
        variables params: params
        action :create
      end
      shared_config_files << [f["host"],f["container"]]
    end
  end

  volumes = conf["volumes"]
  if volumes
    volumes.each do |volume|
      dir = volume["host"]
      if dir =~ /\.[a-z]{2,4}$/
        file_path = dir
        dir = File.dirname(dir)
        file file_path do
          user volume["user"] || "root"
          group volume["group"] || "docker"
        end
      end
      directory dir do
        recursive true
        user volume["user"] || "root"
        group volume["group"] || "docker"
        mode "775"
      end
      shared_files << [volume["host"], volume["container"]]
    end
  end

  ports = conf["ports"]
  if ports
    ports.each do |port|
      shared_ports << [port["host"], port["container"]]
    end
  end

  sf = conf["service_files"]
  %w(start stop restart bash).each do |actn|
    file_name = "#{conf['name']}-#{actn}"
    template "/usr/local/bin/#{file_name}" do
      source sf[actn + "_template"]
      variables params: params,
                name: conf["name"],
                env_files: env_files,
                shared_files: shared_files,
                shared_config_files: shared_config_files,
                shared_ports: shared_ports
      mode "775"
      user "root"
      group "docker"
    end
  end

  execute "/usr/local/bin/#{conf['name']}_restart" do
    user "root"
    not_if "/usr/bin/docker ps | grep #{conf['name']}"
  end
end
