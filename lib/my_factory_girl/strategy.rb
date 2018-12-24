class Factory
  class Strategy
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

    def method_missing(method, *args, &block)
      get(method)
    end

    def result
      raise NotImplementedError, "Strategies must return a result"
    end
  end
end
