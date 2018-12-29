module FactoryGirl
  class DefinitionProxy
    def initialize(factory)
      @factory = factory
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

      @factory.define_attribute(attribute)
    end

    def method_missing(name, *args, &block)
      if args.empty? && block.nil?
        association(name)
      else
        add_attribute(name, *args, &block)
      end
    end

    def association(name, options = {})
      factory_name = options.delete(:factory) ||name
      @factory.define_attribute(
        Attribute::Association.new(name, factory_name, options)
      )
    end

    def sequence(name, start_value = 1, &block)
      sequence = Sequence.new(start_value, &block)
      add_attribute(name) { sequence.next }
    end

    def after_build(&block)
      @factory.add_callback(:after_build, &block)
    end

    def after_create(&block)
      @factory.add_callback(:after_create, &block)
    end

    def after_stub(&block)
      @factory.add_callback(:after_stub, &block)
    end
  end
end
