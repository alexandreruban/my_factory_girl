class Factory
  class AttributeProxy
    attr_accessor :strategy

    def initialize(strategy)
      @strategy = strategy
    end

    def association(factory_name, attributes = {})
      if strategy == Strategy::AttributesFor
        nil
      else
        Factory.create(factory_name, attributes)
      end
    end

    def value_for(attribute)
      strategy.get(attribute)
    end

    def method_missing(name, *args, &block)
      value_for(name)
    end
  end
end
