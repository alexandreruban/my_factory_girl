module FactoryGirl
  class Proxy
    class AttributesFor < Proxy
      def initialize(klass)
        @hash = {}
      end

      def get(attribute)
        @hash[attribute]
      end

      def set(attribute, value)
        @hash[attribute] = value
      end

      def result(to_create)
        @hash
      end
    end
  end
end
