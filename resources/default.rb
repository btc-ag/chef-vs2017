property :version, String, default: '15.9'
property :edition, String, default: 'community'
property :source, String
property :workloads, Array, default: []
property :all_workloads, [true, false], default: false
property :include_recommended, [true, false], default: true
property :include_optional, [true, false], default: false
property :product_key, String, sensitivy: true

action :install do
  source = if property_is_set?(:source)
             new_resource.source
           else
             VS2017.download_url(new_resource.edition, new_resource.version)
           end

  options = '--wait --norestart --passive'
  options = "#{options} --add #{new_resource.workloads.join(' --add ')}" unless new_resource.workloads.empty?
  options = "#{options} --includeRecommended" if new_resource.include_recommended
  options = "#{options} --includeOptional" if new_resource.include_optional
  options = "#{options} --allWorkloads" if new_resource.all_workloads
  options = "#{options} --productKey #{new_resource.product_key}" if property_is_set?(:product_key)

  windows_package "Install Visual Studio 2017 #{new_resource.edition} (#{new_resource.version})" do
    source source
    installer_type :custom
    options options
    timeout 10_800
    returns [0, 3010]
    not_if { VS2017.installed?(new_resource.edition) }
  end
end

action :update do
  source = if property_is_set?(:source)
             new_resource.source
           else
             VS2017.download_url(new_resource.edition, new_resource.version)
           end

  log "Installed Version:  #{VS2017.installed_version(new_resource.edition)}. Requested Version: #{new_resource.version}"
  windows_package "Update Visual Studio 2017 #{new_resource.edition} (#{new_resource.version})" do
    source source
    installer_type :custom
    options 'update --wait --norestart --passive'
    timeout 10_800
    returns [0, 3010]
    only_if { VS2017.installed?(new_resource.edition) && (VS2017.installed_version(new_resource.edition) < new_resource.version.to_f) }
  end
end

action :remove do
  source = if property_is_set?(:source)
             new_resource.source
           else
             VS2017.download_url(new_resource.edition, new_resource.version)
           end

  windows_package "Remove Visual Studio 2017 #{new_resource.edition} (#{new_resource.version})" do
    source source
    installer_type :custom
    options "uninstall --wait --norestart --passive --installPath \"#{VS2017.install_path(new_resource.edition)}\""
    only_if { VS2017.installed?(new_resource.edition) }
  end
end
