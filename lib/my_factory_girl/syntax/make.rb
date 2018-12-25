class Factory
  module Syntax
    module Make
      module ActiveRecord
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def make(overrides = {})
            Factory.create(name.underscore, overrides)
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Factory::Syntax::Make::ActiveRecord)
