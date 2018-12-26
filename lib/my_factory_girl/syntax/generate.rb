class Factory
  module Syntax
    module Generate
      module ActiveRecord
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def generate(overrides = {}, &block)
            instance = Factory.build(name.underscore, overrides)
            instance.save
            yield(instance) if block_given?
            instance
          end

          def generate!(overrides = {}, &block)
            instance = Factory.create(name.underscore, overrides)
            yield(instance) if block_given?
            instance
          end

          def spawn(overrides = {}, &block)
            instance = Factory.build(name.underscore, overrides)
            yield(instance) if block_given?
            instance
          end
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Factory::Syntax::Generate::ActiveRecord)
