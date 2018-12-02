class Factory
  @factories = {}
  @sequences = {}
  attr_reader :factory_name

  class << self
    attr_accessor :factories, :sequences

    def define(name, options = {})
      instance = Factory.new(name, options)
      yield(instance)
      factories[name] = instance
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
      factories[name] or raise ArgumentError.new("No such factory: #{name.inspect}")
    end
  end

  def initialize(factory_name, options = {})
    @factory_name = factory_name
    @options = options
    @static_attributes = {}
    @lazy_attribute_blocks = {}
    @lazy_attribute_names = []
  end

  def build_class
    @options[:class] || factory_name.to_s.camelize.constantize
  end

  def add_attribute(name, value = nil, &block)
    if block_given?
      unless value.nil?
        raise ArgumentError, "Both value and block given"
      end

      @lazy_attribute_blocks[name] = block
      @lazy_attribute_names << name
    else
      @static_attributes[name] = value
    end
  end

  def method_missing(name, *args, &block)
    add_attribute(name, *args, &block)
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

  def build_attributes_hash(override, strategy)
    result = @static_attributes.merge(override)
    @lazy_attribute_names.each do |name|
      proxy = AttributeProxy.new(self, name, strategy, result)
      unless override.key?(name)
        result[name] = @lazy_attribute_blocks[name].call(proxy)
      end
    end
    result
  end

  def build_instance(override, strategy)
    instance = build_class.new
    attrs = build_attributes_hash(override, strategy)
    attrs.each do |attr, value|
      instance.send("#{attr}=", value)
    end
    instance
  end
end
