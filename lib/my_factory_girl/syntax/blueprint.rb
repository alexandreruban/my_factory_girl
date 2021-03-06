module FactoryGirl
  module Syntax
    module Blueprint
      module ActiveRecord
        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods
          def blueprint(&block)
            instance = Factory.new(name.underscore, class: self)
            proxy = FactoryGirl::DefinitionProxy.new(instance)
            proxy.instance_eval(&block)
            FactoryGirl.factories[instance.name] = instance
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, FactoryGirl::Syntax::Blueprint::ActiveRecord)
