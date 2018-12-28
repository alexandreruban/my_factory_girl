module FactoryGirl
  class Attribute
    class Callback < Attribute
      def initialize(name, block)
        @name = name.to_sym
        @block = block
      end

      def add_to(proxy)
        proxy.add_callback(name, @block)
      end
    end
  end
end
