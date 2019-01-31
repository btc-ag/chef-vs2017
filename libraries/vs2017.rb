include Chef::Mixin::ShellOut

class VS2017
  def self.vswhere(edition, property)
    # make first character uppercase
    product = edition.sub(/\S/, &:upcase)
    shell_out!("\"C:\\Program Files (x86)\\Microsoft Visual Studio\\Installer\\vswhere.exe\" -all -version [15.0,16.0) -property #{property} -products Microsoft.VisualStudio.Product.#{product}", returns: [0, 1])
  end

  def self.install_path(edition)
    cmd = vswhere(edition, 'InstallationPath')
    cmd.stdout.strip
  end

  def self.installed?(edition)
    cmd = vswhere(edition, 'installationVersion')
    cmd.stderr.empty? && (cmd.stdout =~ /^15./)
  end

  def self.installed_version(edition)
    cmd = vswhere(edition, 'installationVersion')
    cmd.stdout.to_f
  end

  def self.download_url(type, version)
    urls = {
      '15.9' => {
        'community' => 'https://download.visualstudio.microsoft.com/download/pr/7494c18c-fa5c-4114-a0b1-a2afb6548dfd/34eec042fdf7ced448c3ec340f220198/vs_community.exe',
        'professional' => 'https://download.visualstudio.microsoft.com/download/pr/5a04193a-98c0-48bb-9375-0222afbcd7cc/ea634ab8ea6a07519fc7029f95f87263/vs_professional.exe',
        'enterprise' => 'https://download.visualstudio.microsoft.com/download/pr/1fd2d58d-585d-435c-9883-f73a14fbbb91/42b3ce50718f75deacbb9a01dd459672/vs_enterprise.exe',
      },
      '15.8' => {
        'community' => 'https://download.visualstudio.microsoft.com/download/pr/5df30b3f-9db2-4195-bce3-c5518277da5d/18edc9dd7697111f993c5c06f18b51e5/vs_community.exe',
        'professional' => 'https://download.visualstudio.microsoft.com/download/pr/9022845d-ba6c-4270-9d1b-64273be35d18/8f8e32b27ff15231e8e7ac7bd0df1f69/vs_professional.exe',
        'enterprise' => 'https://download.visualstudio.microsoft.com/download/pr/24ab35a0-e506-4a86-a2bf-d17632c60343/194d426e34461f21a778bc6c5a76a71b/vs_enterprise.exe',
      },
      '15.7' => {
        'community' => 'https://download.visualstudio.microsoft.com/download/pr/56bbbbee-ca8b-4494-81ee-88ecc27302b3/22df558a9345cfc0b343a67fdde847ec/vs_community.exe',
        'professional' => 'https://download.visualstudio.microsoft.com/download/pr/215a0823-5d01-432c-bd17-aa706c007b19/e7f7fcb9bd800c7b00f822df4548ac37/vs_professional.exe',
        'enterprise' => 'https://download.visualstudio.microsoft.com/download/pr/56bbbbee-ca8b-4494-81ee-88ecc27302b3/22df558a9345cfc0b343a67fdde847ec/vs_community.exe',
      },
      '15.6' => {
        'community' => 'https://download.visualstudio.microsoft.com/download/pr/12135679/9c6995f2b181f91c891fcb80b2ea9900/vs_Community.exe',
        'professional' => 'https://download.visualstudio.microsoft.com/download/pr/12135717/203c15dc97b95ca09af2ab37e15d4320/vs_Professional.exe',
        'enterprise' => 'https://download.visualstudio.microsoft.com/download/pr/12135702/6190530128c1014deff48203735ec888/vs_Enterprise.exe',
      },
    }
    unless urls.key?(version)
      raise "No installer present for version #{version}. Installers available for (#{urls.keys.join(',')})"
    end
    unless urls[version].key?(type)
      raise "Edition '#{type}' not found for version #{version}. Possible editions: '#{urls[version].keys.join("', '")}'."
    end

    urls[version][type]
  end
end
