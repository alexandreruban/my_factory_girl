class Factory
  @factories = {}
  @sequences = {}
  attr_reader :factory_name

  class << self
    attr_accessor :factories, :sequences

    def define(name, options = {})
      instance = Factory.new(name, options)
      yield(instance)
      factories[instance.factory_name] = instance
    end

    def sequence(name, &block)
      self.sequences[name] = Sequence.new(&block)
    end

    def next(sequence)
      unless self.sequences.key?(sequence)
        raise "no such sequence: #{sequence}"
      end

      self.sequences[sequence].next
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
    options = options.symbolize_keys
    association_factory = options[:factory] || name

    add_attribute(name) { |a| a.association(association_factory) }
  end

  def attributes_for(override = {})
    build_attributes_hash(override, :attributes_for)
  end

  def build(override = {})
    build_instance(override, :build)
  end

  def create(override = {})
    instance = build(override)
    instance.save!
    instance
  end

  private

  def build_attributes_hash(values, strategy)
    values = values.symbolize_keys
    @attributes.each do |attribute|
      unless values.key?(attribute.name)
        proxy = AttributeProxy.new(self, attribute.name, strategy, values)
        values[attribute.name] = attribute.value(proxy)
      end
    end
    values
  end

  def build_instance(override, strategy)
    instance = build_class.new
    attrs = build_attributes_hash(override, strategy)
    attrs.each do |attr, value|
      instance.send("#{attr}=", value)
    end
    instance
  end

  def class_for(class_or_to_s)
    if class_or_to_s.respond_to?(:to_sym)
      class_or_to_s.to_s.camelize.constantize
    else
      class_or_to_s
    end
  end

  def factory_name_for(class_or_to_s)
    if class_or_to_s.respond_to?(:to_sym)
      class_or_to_s.to_sym
    else
      class_or_to_s.to_s.underscore.to_sym
    end
  end

  def attribute_defined?(name)
    !@attributes.detect { |attribute| attribute.name == name }.nil?
  end
end
