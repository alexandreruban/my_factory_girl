class Factory
  class AttributeDefinitionError < RuntimeError
  end

  class Attribute
    attr_reader :name

    def initialize(name)
      @name = name.to_sym

      if name.to_s =~ /=$/
        raise Factory::AttributeDefinitionError, "factory_girl uses" +
        "#{name.to_s.chop} value syntax rather than #{name} value."
      end
    end

    def add_to(proxy)
    end
  end
end
