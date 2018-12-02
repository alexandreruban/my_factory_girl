require "active_support"
require "my_factory_girl/factory"
require "my_factory_girl/attribute_proxy"
require "my_factory_girl/sequence"

def Factory(name, attrs = {})
  Factory.create(name, attrs)
end
