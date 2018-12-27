class Factory
  module Syntax
    module Generate
      module ActiveRecord
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def generate(overrides = {}, &block)
            factory = Factory.factory_by_name(name.underscore)
            instance = factory.run(Proxy::Build, overrides)
            instance.save
            yield(instance) if block_given?
            instance
          end

          def generate!(overrides = {}, &block)
            factory = Factory.factory_by_name(name.underscore)
            instance = factory.run(Proxy::Create, overrides)
            yield(instance) if block_given?
            instance
          end

          def spawn(overrides = {}, &block)
            factory = Factory.factory_by_name(name.underscore)
            instance = factory.run(Proxy::Build, overrides)
            yield(instance) if block_given?
            instance
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Factory::Syntax::Generate::ActiveRecord)
