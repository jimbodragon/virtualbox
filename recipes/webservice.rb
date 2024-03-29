#
# Cookbook Name:: virtualbox
# Recipe:: webservice
#
# Copyright 2012, Ringo De Smet
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

extend Vbox::Helpers
include_recipe "#{cookbook_name}::systemservice"

directory 'vboxweb-service log folder' do
  path node[cookbook_name]['webservice']['log']['location']
  owner node[cookbook_name]['user']
  group node[cookbook_name]['group']
  mode '0755'
end

# directory '/var/www' do
#   owner node[cookbook_name]['user']
#   group node[cookbook_name]['group']
#   mode '0755'
# end

# It is very hard to get vboxwebsrv to work correctly with password authentication
# If anyone can get this working, feel free to submit a changed cookbook!
# execute "Disable vboxwebsrv auth library" do
#   command "VBoxManage setproperty websrvauthlibrary null"
#   user "#{node[cookbook_name]['user']}"
#   action :run
#   environment ({'HOME' => "/home/#{node[cookbook_name]['user']}"})
# end

chef_sleep 'Wait a little...' do
  seconds 3
  action :sleep
end

service 'vboxweb-service' do
  action [:enable, :start]
end
