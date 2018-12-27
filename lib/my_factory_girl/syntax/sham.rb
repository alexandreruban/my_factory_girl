class Factory
  module Syntax
    module Sham
      module Sham
        def self.method_missing(name, &block)
          if block_given?
            Factory.sequences[name] = Sequence.new(&block)
          else
            Factory.sequences[name].next
          end
        end

        # overrides name on Module
        def self.name(&block)
          method_missing("name", &block)
        end
      end
    end
  end
end

include Factory::Syntax::Sham
