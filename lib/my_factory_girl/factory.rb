module FactoryGirl
  @factories = {}

  class << self
    attr_accessor :factories

    def factory_by_name(name)
      factories[name.to_sym] or raise ArgumentError.new("No such factory: #{name.to_s}")
    end

    def register_factory(factory, options = {})
      if options[:as]
        name = options[:as]
      else
        name = factory.name
        factory.aliases.each do |alias_name|
          register_factory(factory, as: alias_name)
        end
      end
      if self.factories[name]
        raise DuplicateDefinitionError, "Factory already defined: #{name}"
      end

      factories[name] = factory
    end
  end

  # Raised when a factory is defined that attempts to instantiate itself.
  class AssociationDefinitionError < RuntimeError
  end

  # Raised when a callback is defined that has an invalid name
  class InvalidCallbackNameError < RuntimeError
  end

  # Raised when a factory is defined with the same name as a previously-defined factory.
  class DuplicateDefinitionError < RuntimeError
  end

  class Factory
    attr_reader :name, :attributes

    def factory_name
      puts "WARNING: factory.factory_name is deprecated. Use factory.name instead."
      name
    end

    def class_name
      @options[:class] || name
    end

    def build_class
      @build_class ||= class_for(class_name)
    end

    def default_strategy
      @options[:default_strategy] || :create
    end

    def initialize(name, options = {})
      assert_valid_options(options)
      @name = factory_name_for(name)
      @options = options
      @attributes = []
    end

    def inherit_from(parent)
      @options[:class] ||= parent.class_name
      @options[:default_strategy] ||= parent.default_strategy

      new_attributes = []
      parent.attributes.each do |attribute|
        unless attribute_defined?(attribute.name)
          new_attributes << attribute.clone
        end
      end

      @attributes.unshift *new_attributes
    end

    def define_attribute(attribute)
      name = attribute.name
      if attribute_defined?(name)
        raise AttributeDefinitionError, "Attribute already defined: #{name}"
      end
      if attribute.respond_to?(:factory) && attribute.factory == self.name
        raise AssociationDefinitionError, "Self-referencing association '#{name}'"
      end
      @attributes << attribute
    end

    def add_callback(name, &block)
      unless [:after_build, :after_create, :after_stub].include?(name.to_sym)
        raise InvalidCallbackNameError, "#{name} is not a valid callback"
      end
      @attributes << Attribute::Callback.new(name.to_sym, block)
    end

    def run(proxy_class, overrides)
      proxy = proxy_class.new(build_class)
      overrides = symbolize_keys(overrides)
      overrides.each { |attr, val| proxy.set(attr, val) }
      passed_keys = overrides.keys.map { |key| FactoryGirl.aliases_for(key) }.flatten
      @attributes.each do |attribute|
        unless passed_keys.include?(attribute.name)
          attribute.add_to(proxy)
        end
      end
      proxy.result(@to_create_block)
    end


    def associations
      attributes.select { |attr| attr.is_a?(Attribute::Association) }
    end

    def aliases
      @options[:aliases] || []
    end

    def to_create(&block)
      @to_create_block = block
    end

    private

    def class_for(class_or_to_s)
      if class_or_to_s.respond_to?(:to_sym)
        class_name = variable_name_to_class_name(class_or_to_s)
        class_name.split("::").inject(Object) do |object, string|
          object.const_get(string)
        end
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
      !@attributes.detect do |attribute|
        attribute.name == name && !attribute.is_a?(Attribute::Callback)
      end.nil?
    end

    def assert_valid_options(options)
      invalid_keys = options.keys - [:class, :parent, :default_strategy, :aliases]
      unless invalid_keys == []
        raise ArgumentError, "Unknown arguments: #{invalid_keys.inspect}"
      end

      if options[:default_strategy]
        assert_valid_strategy(options[:default_strategy])
        puts "WARNING: default_strategy is deprecated"
        puts "Override to_create if you need to prevent a call to #save!"
      end
    end

    def assert_valid_strategy(strategy)
      unless FactoryGirl::Proxy.const_defined? variable_name_to_class_name(strategy)
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
end
