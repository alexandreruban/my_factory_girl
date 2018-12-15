class Factory
  @factories = {}
  attr_reader :factory_name

  class << self
    attr_accessor :factories

    def define(name, options = {})
      instance = Factory.new(name, options)
      yield(instance)
      factories[instance.factory_name] = instance
    end

    def attributes_for(name, override = {})
      factory_by_name(name).attributes_for(override)
    end

    def build(name, override = {})
      factory_by_name(name).build(override)
    end

    def create(name, override = {})
      factory_by_name(name).create(override)
    end

    private

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

  def build_class
    @build_class ||= class_for(@options[:class] || factory_name)
  end

  def add_attribute(name, value = nil, &block)
    attribute = Attribute.new(name, value, block)

    if attribute_defined?(attribute.name)
      raise AttributeDefinitionError, "Attribute already defined: #{name}"
    end

    @attributes << attribute
  end

  def method_missing(name, *args, &block)
    add_attribute(name, *args, &block)
  end

  def association(name, options = {})
    name = name.to_sym
    options = symbolize_keys(options)
    association_factory = options[:factory] || name

    add_attribute(name) { |a| a.association(association_factory) }
  end

  def attributes_for(overrides = {})
    run_strategy(Strategy::AttributesFor, overrides)
  end

  def build(overrides = {})
    run_strategy(Strategy::Build, overrides)
  end

  def create(overrides = {})
    run_strategy(Strategy::Create, overrides)
  end

  private

  def run_strategy(strategy_class, overrides)
    strategy = strategy_class.new(build_class)
    overrides = symbolize_keys(overrides)
    overrides.each { |attr, val| strategy.set(attr, val) }
    passed_keys = overrides.keys.map { |key| Factory.aliases_for(key) }.flatten
    @attributes.each do |attribute|
      unless passed_keys.include?(attribute.name)
        strategy.set(attribute.name, attribute.value(strategy))
      end
    end
    strategy.result
  end

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
    invalid_keys = options.keys - [:class]
    unless invalid_keys == []
      raise ArgumentError, "Unknown arguments: #{invalid_keys.inspect}"
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
