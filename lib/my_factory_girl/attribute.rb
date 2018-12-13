class Factory
  class AttributeDefinitionError < RuntimeError
  end

  class Attribute
    attr_reader :name
    attr_writer :static_value, :lazy_block

    def initialize(name, static_value, lazy_block)
      name = name.to_sym

      if name.to_s =~ /=$/
        raise Factory::AttributeDefinitionError, "Factory girl uses" +
        "#{name.to_s.chop} value syntax rather than #{name} value."
      end

      unless static_value.nil? || lazy_block.nil?
        raise ArgumentError, "Both value and block given"
      end

      @name = name
      @lazy_block = lazy_block
      @static_value = static_value
    end

    def value(strategy)
      if @lazy_block.nil?
        @static_value
      else
        @lazy_block.call(AttributeProxy.new(strategy))
      end
    end
  end
end
