class Factory
  @factories = {}
  attr_reader :factory_name

  class << self
    attr_accessor :factories

    def define(name, options = {})
      instance = Factory.new(name, options)
      yield(instance)
      factories[name] = instance
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
      factories[name] or raise ArgumentError.new("No such factory: #{name.inspect}")
    end
  end

  def initialize(factory_name, options = {})
    @factory_name = factory_name
    @options = options
    @static_attributes = {}
    @lazy_attributes = {}
  end

  def build_class
    @options[:class] || factory_name.to_s.camelize.constantize
  end

  def add_attribute(name, value = nil, &block)
    if block_given?
      unless value.nil?
        raise ArgumentError, "both value and block given"
      end

      @lazy_attributes[name] = block
    else
      @static_attributes[name] = value
    end
  end

  def method_missing(name, *args, &block)
    add_attribute(name, *args, &block)
  end

  def attributes_for(override = {})
    result = @static_attributes.merge(override)
    @lazy_attributes.each do |name, block|
      result[name] = block.call unless override.keys.include?(name)
    end
    result
  end

  def build(override = {})
    instance = build_class.new
    attributes_for(override).each do |attr, value|
      instance.send("#{attr}=", value)
    end
    instance
  end

  def create(override = {})
    instance = build(override)
    instance.save!
    instance
  end
end
