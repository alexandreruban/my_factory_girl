class Factory
  class << self
    def define(name, options = {})
      factory = Factory.new(name, options)
      proxy = Factory::DefinitionProxy.new(factory)
      yield(proxy)
      if parent = options.delete(:parent)
        factory.inherit_from(Factory.factory_by_name(parent))
      end
      register_factory(factory)
    end

    def attributes_for(name, overrides = {})
      factory_by_name(name).run(Proxy::AttributesFor, overrides)
    end

    def build(name, overrides = {})
      factory_by_name(name).run(Proxy::Build, overrides)
    end

    def create(name, overrides = {})
      factory_by_name(name).run(Proxy::Create, overrides)
    end

    def stub(name, overrides = {})
      factory_by_name(name).run(Proxy::Stub, overrides)
    end

    def default_strategy(name, overrides = {})
      self.send(factory_by_name(name).default_strategy, name, overrides)
    end
  end
end

def Factory(name, attrs = {})
  Factory.default_strategy(name, attrs)
end
