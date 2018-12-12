class Factory
  class AttributeProxy
    attr_accessor :strategy, :current_values

    def initialize(strategy, values)
      @strategy = strategy
      @current_values = values
    end

    def association(factory_name, attributes = {})
      if strategy == :attributes_for
        nil
      else
        Factory.create(factory_name, attributes)
      end
    end

    def value_for(attribute)
      current_values[attribute]
    end

    def method_missing(name, *args, &block)
      value_for(name)
    end
  end
end
