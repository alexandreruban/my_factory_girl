module FactoryGirl
  module Syntax
    module Sham
      module Sham
        def self.method_missing(name, &block)
          if block_given?
            FactoryGirl.sequences[name] = Sequence.new(&block)
          else
            FactoryGirl.sequences[name].next
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

include FactoryGirl::Syntax::Sham
