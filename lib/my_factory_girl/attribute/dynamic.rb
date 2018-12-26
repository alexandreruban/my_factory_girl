class Factory
  class Attribute
    class Dynamic < Attribute
      def initialize(name, block)
        super(name)
        @block = block
      end

      def add_to(proxy)
        value = @block.call(proxy)
        raise SequenceAbuseError if Factory::Sequence === value
        proxy.set(name, value)
      end
    end
  end
end
