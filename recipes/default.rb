#
# Cookbook Name:: virtualbox-install
# Recipe:: default
#
# Copyright 2011-2013, Joshua Timberman
# Copyright 2018, Kyle McGovern
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

vbox_package_name = "Oracle VM VirtualBox #{node['virtualbox']['version']}-#{node['virtualbox']['releasever']}"

vbox_sha256sum = vbox_sha256sum(node['virtualbox']['url'])
extpack_sha256sum = vbox_sha256sum(node['virtualbox']['ext_pack_url'])
case node['platform_family']
when 'mac_os_x'
  dmg_package vbox_package_name do
    source node['virtualbox']['url']
    checksum vbox_sha256sum
    type 'pkg'
  end

when 'windows'
  win_pkg_version = node['virtualbox']['version']
  Chef::Log.debug("Inspecting windows package version: #{win_pkg_version.inspect}")

  windows_package vbox_package_name do
    action :install
    source node['virtualbox']['url']
    checksum vbox_sha256sum
    installer_type :custom
    options "-s"
  end

when 'debian'
  include_recipe "apt"
  include_recipe "build-essential"
  
  package get_packages_dependencies do
     action :install
  end

  remote_file '/tmp/virtualbox.deb' do
    source node['virtualbox']['url']
    action :create
    checksum vbox_sha256sum
  end

  dpkg_package vbox_package_name do
    action :install
    source "/tmp/virtualbox.deb"
  end
  package 'dkms'

  remote_file "/tmp/#{node['virtualbox']['ext_pack_name']}" do
    source node['virtualbox']['ext_pack_url']
    action :create
    checksum extpack_sha256sum
  end
  execute 'Install Oracle VM VirtualBox Extension Pack' do
    command "echo 'y' | /usr/bin/vboxmanage extpack install /tmp/#{node['virtualbox']['ext_pack_name']}"
    not_if is_extpack_installed?("Oracle VM VirtualBox Extension Pack").to_s
  end

  execute 'Loading kernel' do
    command '/sbin/vboxconfig'
    not_if is_vbox_kernel_loaded?.to_s
  end

when 'rhel', 'fedora', 'suse'
  rpm_package vbox_package_name do
    checksum vbox_sha256sum
    action :install
    source node['virtualbox']['url']
  end
end
