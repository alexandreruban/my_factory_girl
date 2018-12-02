class Factory
  class AttributeProxy
    attr_accessor :factory, :attribute_name, :strategy, :current_values

    def initialize(factory, attribute_name, strategy, values)
      @factory = factory
      @attribute_name = attribute_name
      @strategy = strategy
      @current_values = values
    end

    def association(factory_name, attributes = {})
      if strategy == :attributes_for
        nil
      else
        Factory.send(strategy, factory_name, attributes)
      end
    end

    def value_for(attribute)
      unless current_values.key?(attribute)
        raise ArgumentError, "No such attribute: #{attribute.inspect}"
      end

      current_values[attribute]
    end

    def method_missing(name, *args, &block)
      current_values[name]
    end
  end
end
