module FactoryGirl
  module Syntax
    module Vintage
      module Factory
        extend Syntax::Methods

        def self.define(name, options = {})
          factory = FactoryGirl::Factory.new(name, options)
          proxy = FactoryGirl::DefinitionProxy.new(factory)
          yield(proxy)
          if parent = options.delete(:parent)
            factory.inherit_from(FactoryGirl.factory_by_name(parent))
          end
          FactoryGirl.register_factory(factory)
        end

        def self.default_strategy(name, overrides = {})
          Factory.send(
            FactoryGirl.factory_by_name(name).default_strategy, name, overrides
          )
        end

        def self.sequence(name, start_value = 1, &block)
          FactoryGirl.sequences[name] = Sequence.new(start_value, &block)
        end

        def self.next(sequence)
          unless FactoryGirl.sequences.key?(sequence)
            raise "No such sequence: #{sequence}"
          end
          FactoryGirl.sequences[sequence].next
        end

        def self.alias(pattern, replace)
          FactoryGirl.aliases << [pattern, replace]
        end
      end

      def Factory(name, attrs = {})
        Factory.default_strategy(name, attrs)
      end
    end
  end
end

include FactoryGirl::Syntax::Vintage
