module FactoryGirl
  module Syntax
    module Methods
      def attributes_for(name, overrides = {})
        FactoryGirl.factory_by_name(name).run(Proxy::AttributesFor, overrides)
      end

      def build(name, overrides = {})
        FactoryGirl.factory_by_name(name).run(Proxy::Build, overrides)
      end

      def create(name, overrides = {})
        FactoryGirl.factory_by_name(name).run(Proxy::Create, overrides)
      end

      def stub(name, overrides = {})
        FactoryGirl.factory_by_name(name).run(Proxy::Stub, overrides)
      end
    end
  end
end
