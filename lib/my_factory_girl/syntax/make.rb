class Factory
  module Syntax
    module Make
      module ActiveRecord
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def make(overrides = {})
            factory = Factory.factory_by_name(name.underscore)
            factory.run(Proxy::Create, overrides)
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Factory::Syntax::Make::ActiveRecord)
