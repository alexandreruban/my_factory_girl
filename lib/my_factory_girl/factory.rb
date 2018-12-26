class Factory
  @factories = {}
  attr_reader :factory_name
  attr_reader :attributes

  class AssociationDefinitionError < RuntimeError
  end

  class << self
    attr_accessor :factories

    def define(name, options = {})
      instance = Factory.new(name, options)
      yield(instance)
      if parent = options.delete(:parent)
        instance.inherit_from(factory_by_name(parent))
      end
      factories[instance.factory_name] = instance
    end

    def attributes_for(name, overrides = {})
      factory_by_name(name).run(Proxy::AttributesFor, overrides)
    end

    def build(name, overrides = {})
      factory_by_name(name).run(Proxy::Build, overrides)
    end

    def create(name, overrides = {})
      factory_by_name(name).run(Proxy::Create, overrides)
    end

    def stub(name, overrides = {})
      factory_by_name(name).run(Proxy::Stub, overrides)
    end

    def default_strategy(name, overrides = {})
      self.send(factory_by_name(name).default_strategy, name, overrides)
    end

    def factory_by_name(name)
      factories[name.to_sym] or raise ArgumentError.new("No such factory: #{name.to_s}")
    end
  end

  def initialize(factory_name, options = {})
    assert_valid_options(options)
    @factory_name = factory_name_for(factory_name)
    @options = options
    @attributes = []
  end

  def class_name
    @options[:class] || factory_name
  end

  def build_class
    @build_class ||= class_for(class_name)
  end

  def default_strategy
    @options[:default_strategy] || :create
  end

  def add_attribute(name, value = nil, &block)
    if block_given?
      if value
        raise AttributeDefinitionError, "Both value and block given"
      else
        attribute = Attribute::Dynamic.new(name, block)
      end
    else
      attribute = Attribute::Static.new(name, value)
    end

    if attribute_defined?(attribute.name)
      raise AttributeDefinitionError, "Attribute already defined: #{name}"
    end

    @attributes << attribute
  end

  def method_missing(name, *args, &block)
    add_attribute(name, *args, &block)
  end

  def association(name, options = {})
    factory_name = options.delete(:factory) ||name
    if factory_name_for(factory_name) == self.factory_name
      raise AssociationDefinitionError, "self referencing association #{name}" +
                                        "in factory #{self.factory_name}"
    end
    @attributes << Attribute::Association.new(name, factory_name, options)
  end

  def sequence(name, &block)
    sequence = Sequence.new(&block)
    add_attribute(name) { sequence.next }
  end

  def run(proxy_class, overrides)
    proxy = proxy_class.new(build_class)
    overrides = symbolize_keys(overrides)
    overrides.each { |attr, val| proxy.set(attr, val) }
    passed_keys = overrides.keys.map { |key| Factory.aliases_for(key) }.flatten
    @attributes.each do |attribute|
      unless passed_keys.include?(attribute.name)
        attribute.add_to(proxy)
      end
    end
    proxy.result
  end

  def inherit_from(parent)
    @options[:class] ||= parent.class_name
    parent.attributes.each do |attribute|
      unless attribute_defined?(attribute.name)
        @attributes << attribute.clone
      end
    end
  end

  private

  def class_for(class_or_to_s)
    if class_or_to_s.respond_to?(:to_sym)
      Object.const_get(variable_name_to_class_name(class_or_to_s))
    else
      class_or_to_s
    end
  end

  def factory_name_for(class_or_to_s)
    if class_or_to_s.respond_to?(:to_sym)
      class_or_to_s.to_sym
    else
      class_name_to_variable_name(class_or_to_s).to_sym
    end
  end

  def attribute_defined?(name)
    !@attributes.detect { |attribute| attribute.name == name }.nil?
  end

  def assert_valid_options(options)
    invalid_keys = options.keys - [:class, :parent, :default_strategy]
    unless invalid_keys == []
      raise ArgumentError, "Unknown arguments: #{invalid_keys.inspect}"
    end
    assert_valid_strategy(options[:default_strategy]) if options[:default_strategy]
  end

  def assert_valid_strategy(strategy)
    unless Factory::Proxy.const_defined? variable_name_to_class_name(strategy)
      raise ArgumentError, "Unknown strategy: #{strategy}"
    end
  end

  # Based on ActiveSupport's underscore inflector
  def class_name_to_variable_name(name)
    name.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end

  # Based on ActiveSupport's camelize inflector
  def variable_name_to_class_name(name)
    name.to_s.
      gsub(/\/(.?)/) { "::#{$1.upcase}" }.
      gsub(/(?:^|_)(.)/) { $1.upcase }
  end

   # From ActiveSupport
  def symbolize_keys(hash)
    hash.inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end
end
