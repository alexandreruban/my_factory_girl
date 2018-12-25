class Factory
  module Syntax
    module Blueprint
      module ActiveRecord
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def blueprint(&block)
            instance = Factory.new(name.underscore, class: self)
            instance.instance_eval(&block)
            Factory.factories[instance.factory_name] = instance
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Factory::Syntax::Blueprint::ActiveRecord)
