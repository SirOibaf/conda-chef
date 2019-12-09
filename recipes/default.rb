include_recipe "java"

# User anaconda needs access to bin/hadoop to install Pydoop
# This is a hack to get the hadoop group.
# Hadoop group is created in hops::install *BUT*
# Karamel does NOT respect dependencies among install recipies
# so it has to be here and it has to be dirty (Antonis)
hops_group = "hadoop"
if node.attribute?("hops")
  if node['hops'].attribute?("group")
    hops_group = node['hops']['group']
  end
end

group hops_group do
  action :modify
  members ["#{node['conda']['user']}"]
  append true
  not_if { node['install']['external_users'].casecmp("true") == 0 }
end

#
# Install libraries into the root environment
#
for lib in node["conda"]["default_libs"] do
  bash "install_anconda_default_libs" do
    user node['conda']['user']
    group node['conda']['group']
    umask "022"
    environment ({'HOME' => "/home/#{node['conda']['user']}"})
    cwd "/home/#{node['conda']['user']}"
    code <<-EOF
      #{node['conda']['base_dir']}/bin/conda install -q -y #{lib}
    EOF
# The guard checks if the library is installed. Be careful with library names like 'sphinx' and 'sphinx_rtd_theme' - add space so that 'sphinx' doesnt match both.
    not_if  "#{node['conda']['base_dir']}/bin/conda list | grep \"#{lib}\"", :user => node['conda']['user']
  end
end


bash "create_base" do
  user node['conda']['user']
  group node['conda']['group']
  umask "022"
  environment ({'HOME' => "/home/#{node['conda']['user']}"})
  cwd "/home/#{node['conda']['user']}"
  code <<-EOF
    #{node['conda']['base_dir']}/bin/conda create -n #{node['conda']['user']}
  EOF
  not_if "test -d #{node['conda']['base_dir']}/envs/#{node['conda']['user']}", :user => node['conda']['user']
end

## First we delete the current hops-system Anaconda environment, if it exists
bash "remove_hops-system_env" do
  user 'root'
  group 'root'
  umask "022"
  cwd "/home/#{node['conda']['user']}"
  code <<-EOF
    #{node['conda']['base_dir']}/bin/conda env remove -y -q -n hops-system
  EOF
  only_if "test -d #{node['conda']['base_dir']}/envs/hops-system", :user => node['conda']['user']
end

remote_file "/tmp/chef-solo/hops-system.tar.gz" do
  source "http://snurran.sics.se/hops/base_envs/hops-system.tar.gz" 
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# TODO(Fabio): call conda-unpack
bash "extrac_base_envs" do 
  user "root"
  group "root" 
  code <<-EOF
    set -e
    mkdir /srv/hops/anaconda/envs/hops-system
    mv /tmp/chef-solo/hops-system.tar.gz /srv/hops/anaconda/envs/hops-system
    cd /srv/hops/anaconda/envs/hops-system
    tar xf hops-system.tar.gz
    rm hops-system.tar.gz
    chown -R anaconda:anaconda /srv/hops/anaconda/envs/hops-system
  EOF
end