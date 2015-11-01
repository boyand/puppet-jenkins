require 'puppet_x/jenkins/type/cli'

PuppetX::Jenkins::Type::Cli.newtype(:jenkins_jdk) do
  @doc = "Manage Jenkins' JDKs"

  ensurable

  newparam(:name) do
    desc 'Name of the JDK'
    isnamevar
  end

  newproperty(:java_home) do
    desc 'Path to the jdk home'
  end
end # PuppetX::Jenkins::Type::Cli.newtype
