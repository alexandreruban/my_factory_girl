class Factory
  class Attribute
    attr_reader :name
    attr_writer :static_value, :lazy_block

    def initialize(name)
      @name = name
    end

    def value(proxy)
      if @lazy_block.nil?
        @static_value
      else
        @lazy_block.call(proxy)
      end
    end
  end
end
