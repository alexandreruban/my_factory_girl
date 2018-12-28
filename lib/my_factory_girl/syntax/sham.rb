module FactoryGirl
  module Syntax
    module Sham
      module Sham
        def self.method_missing(name, *args, &block)
          if block_given?
            start_value = args.first
            FactoryGirl.sequences[name] = Sequence.new(start_value || 1, &block)
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
