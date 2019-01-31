vs_2017 "Visual Studio 2017 #{node['vs2017']['edition']} (#{node['vs2017']['version']})" do
  action :install
  version node['vs2017']['version']
  edition node['vs2017']['edition']
  all_workloads node['vs2017']['all_workloads']
  workloads node['vs2017']['workloads']
end
