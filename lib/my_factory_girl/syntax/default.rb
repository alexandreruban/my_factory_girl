module FactoryGirl
  module Syntax
    module Default
      module Factory
        class << self
          def define(name, options = {})
            factory = FactoryGirl::Factory.new(name, options)
            proxy = FactoryGirl::DefinitionProxy.new(factory)
            yield(proxy)
            if parent = options.delete(:parent)
              factory.inherit_from(FactoryGirl.factory_by_name(parent))
            end
            FactoryGirl.register_factory(factory)
          end

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

          def default_strategy(name, overrides = {})
            Factory.send(
              FactoryGirl.factory_by_name(name).default_strategy, name, overrides
            )
          end

          def sequence(name, start_value = 1, &block)
            FactoryGirl.sequences[name] = Sequence.new(start_value, &block)
          end

          def next(sequence)
            unless FactoryGirl.sequences.key?(sequence)
              raise "No such sequence: #{sequence}"
            end
            FactoryGirl.sequences[sequence].next
          end

          def alias(pattern, replace)
            FactoryGirl.aliases << [pattern, replace]
          end
        end
      end

      def Factory(name, attrs = {})
        Factory.default_strategy(name, attrs)
      end
    end
  end
end

include FactoryGirl::Syntax::Default
