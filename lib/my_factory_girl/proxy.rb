module FactoryGirl
  class Proxy
    attr_reader :callbacks

    def initialize(klass)
    end

    def get(attribute)
      nil
    end

    def set(attribute, value)
    end

    def associate(name, factory, attributes)
    end

    def association(name, overrides = {})
      nil
    end

    def add_callback(name, block)
      @callbacks ||= {}
      @callbacks[name] ||= []
      @callbacks[name] << block
    end

    def run_callbacks(name)
      if @callbacks && @callbacks[name]
        @callbacks[name].each do |block|
          block.arity.zero? ? block.call : block.call(@instance)
        end
      end
    end

    def method_missing(method, *args, &block)
      get(method)
    end

    def result
      raise NotImplementedError, "Proxies must return a result"
    end
  end
end
