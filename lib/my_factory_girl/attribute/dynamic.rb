module FactoryGirl
  class Attribute
    class Dynamic < Attribute
      def initialize(name, block)
        super(name)
        @block = block
      end

      def add_to(proxy)
        value = proxy.instance_eval(&@block)
        raise SequenceAbuseError if FactoryGirl::Sequence === value
        proxy.set(name, value)
      end
    end
  end
end
