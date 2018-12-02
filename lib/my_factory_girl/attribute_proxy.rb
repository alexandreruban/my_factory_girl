class Factory
  class AttributeProxy
    attr_accessor :factory, :attribute_name, :strategy

    def initialize(factory, attribute_name, strategy)
      @factory = factory
      @attribute_name = attribute_name
      @strategy = strategy
    end

    def association(factory_name, attributes = {})
      Factory.send(strategy, factory_name, attributes)
    end
  end
end
