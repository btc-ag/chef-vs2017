# Visual Studio 2017 cookbook

[![Build Status](https://dev.azure.com/btcag-chef/chef/_apis/build/status/btc-ag.chef-vs2017?branchName=master)](https://dev.azure.com/btcag-chef/chef/_build/latest?definitionId=6&branchName=master)
[![Cookbook version](https://img.shields.io/cookbook/v/vs-2017.svg?style=flat)](https://supermarket.chef.io/cookbooks/vs-2017)


This cookbook can be used to install Visual Studio 2017 and supports the editions Community, Professional and Enterprise. The installation is done by downloading and using the Microsoft Web-Installer of the appropriate version. 

The workloads to be installed can be specified, or all workloads can be installed.

Currently supported versions:

* 15.9
* 15.8
* 15.7
* 15.6

## Simple usage: using the vs-2017::default recipe

For simple usage, you can specify the version, the edition and the workloads to be installed via attributes.

The default attributes are:

```ruby
default['vs2017']['version'] = '15.9'
default['vs2017']['edition'] = 'community'
default['vs2017']['all_workloads'] = true
default['vs2017']['workloads'] = []
```

Then, include the `vs-2017::default` recipe.

* the version can be one of the above defined supported versions.
* The edition can be `community`, `professional` or `enterprise` (case sensitive)
* By default, all workloads are installed. To finetune the workloads, set the `all_workloads` attribute to false and specify the workloads as List. More information about workloads can be found [here](https://docs.microsoft.com/de-de/visualstudio/install/workload-and-component-ids?view=vs-2017).
* This will install vs2017, but only if no other version of this edition is already installed. 


## Usage with wrapper cookbooks and the vc_2017 resource block

More control over the vs installation can be achieved by using the vs_2017 resource block. All parameters are optional. If no parameters are given, Visual Studio community will be installed in the newest supported version without any workloads.

Example of an installation:

```ruby
vs_2017 'Professional' do
  version '15.9' # can be any of the above mentioned versions
  action :install 
  edition 'professional' # can be 'community', 'professional' or 'enterprise' (case sensitive)
  source 'https://.../vs_professional.exe' # Optional. Usually, the source is automatically used from Microsoft if this variable is not given. You can specify the source of the installer. The installer must match the version, otherwise this cookbook might behave strangely. 
  workloads [
    'Microsoft.VisualStudio.Workload.ManagedDesktop',
    'Microsoft.VisualStudio.Workload.NativeDesktop',
    'Microsoft.VisualStudio.Workload.NetCoreTools',
    'Microsoft.VisualStudio.Workload.NetWeb',
    'Microsoft.VisualStudio.Workload.Universal',
  ] # installs multiple workloads and/or components. See https://docs.microsoft.com/de-de/visualstudio/install/workload-and-component-ids?view=vs-2017 for possible workloads
  all_workloads false # set this to false if you specify dedicated workloads
  include_recommended true # defauls to true. If true, the installer will automatically install all recommended packages for the choosen workloads
  include_optional true # Defaults to false. If true, the installer will automatically install all optional packages for the choosen workloads
  product_key 'AAAAA-BBBBB-CCCCC-DDDDDD-EEEEEE' # you can pass a product key during installation. 
end
```

You can upgrade an installed Visual Studio 2017 to a newer minor version.
For example, if you have Version 15.6 installed and want to update to version 15.8, the following resource block can be used:

```ruby
vs_2017 "Update Enterprise to 15.8" do
  action :update
  version: '15.8'
  edition: 'enterprise'
end
```

You can add workloads or components by using modify:
* *Modify will always execute the installer, even if the added workload(s) already exist*
* *It is currently not possible to remove workloads or components*


```ruby
vs_2017 "Add .NET Framework 4.7.2 Targeting pack" do
  action :modify
  version: '15.9'
  edition: 'community'
  workloads ['Microsoft.Net.Component.4.7.2.TargetingPack']
  include_recommended true
  include_optional true
end
```

To bring a node, regardless of an existing older instance to a desired state, you can combine all three actions.
* install will only run if no VS2017 instance of the target edition is installed
* update will only run if the installed VS2017 instance of the target edition is older than the target version
* modify will always run, but will succeed silently if nothing is to be done.

```ruby
vs_2017 'Install/Update/Modify VS2017 Community' do
  version '15.9'
  action [:install, :update, :modify]
  edition 'community'
  workloads [
    'Microsoft.VisualStudio.Workload.ManagedDesktop',
    'Microsoft.Net.Component.4.7.2.TargetingPack'
  ]
  all_workloads false
  include_recommended true
  include_optional true
end
```

You can entirely remove a Instance:

```ruby
vs_2017 "Remove Community" do
  action :remove
end

vs_2017 "Remove Enterprise" do
  action :remove
  edition 'enterprise'
end
```

## Additional information

* Currently, it is not possible to remove workloads or components of an installed edition
* Modify will always run the installer with the modify command, but will succeed silently if nothing was added
* You can install multiple editions simultaneously
* You can have only on version of each edition installed
