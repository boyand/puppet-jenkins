require 'puppet_x/jenkins/util'
require 'puppet_x/jenkins/provider/cli'

Puppet::Type.type(:jenkins_jdk).provide(:cli, :parent => PuppetX::Jenkins::Provider::Cli) do

  mk_resource_methods

  def self.instances(catalog = nil)
    all = jdk_all(catalog)

    Puppet.debug("#{sname} instances: #{all.collect {|i| i['name']}}")

    all.collect {|jdk| from_hash(jdk) }
  end

  def flush
    unless resource.nil?
      @property_hash = resource.to_hash
    end

    case self.ensure
    when :present
      jdk_update_json
    when :absent
      delete_jdk
    else
      fail("invalid :ensure value: #{self.ensure}")
    end
  end

  private

  def self.from_hash(jdk)
    # map nil -> :undef
    jdk = PuppetX::Jenkins::Util.undefize(jdk)

    new({
      :name             => jdk['name'],
      :ensure           => :present,
      :java_home        => info['java_home'],
    })
  end
  private_class_method :from_hash

  def to_hash
    jdk = {}

    properties = self.class.resource_type.validproperties
    properties.reject! {|x| x == :ensure }

    properties.each do |prop|
      value = @property_hash[prop]
      unless value.nil?
        info[prop.to_s] = value
      end
    end

    # map :undef -> nil
    PuppetX::Jenkins::Util.unundef(info)
  end

  # array of hashes for multiple jdks
  def self.jdk_all(catalog = nil)
    raw = nil
    unless catalog.nil?
      raw = clihelper(['jdk_all'], :catalog => catalog)
    else
      raw = clihelper(['jdk_all'])
    end

    begin
      JSON.parse(raw)
    rescue JSON::ParserError
      fail("unable to parse as JSON: #{raw}")
    end
  end
  private_class_method :jdk_all

  def jdk_update_json
    input ||= to_hash

    clihelper(['jdk_update_json'], :stdinjson => input)
  end

  def delete_jdk
    clihelper(['delete_jdk', name])
  end
end
