class Factory
  module Syntax
    module Sham
      module Sham
        def self.method_missing(name, &block)
          if block_given?
            Factory.sequence(name, &block)
          else
            Factory.next(name)
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
