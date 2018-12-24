class Factory
  class Attribute
    class Association < Attribute
      def initialize(name, factory, overrides)
        super(name)
        @factory = factory
        @overrides = overrides
      end

      def add_to(proxy)
        proxy.associate(name, @factory, @overrides)
      end
    end
  end
end
