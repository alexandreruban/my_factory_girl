module FactoryGirl
  class Attribute
    class Static < Attribute
      def initialize(name, value)
        super(name)
        @value = value
      end

      def add_to(proxy)
        proxy.set(name, @value)
      end
    end
  end
end
