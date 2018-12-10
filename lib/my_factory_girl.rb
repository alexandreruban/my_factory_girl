require "my_factory_girl/strategy"
require "my_factory_girl/strategy/build"
require "my_factory_girl/strategy/create"
require "my_factory_girl/strategy/attributes_for"
require "my_factory_girl/factory"
require "my_factory_girl/attribute_proxy"
require "my_factory_girl/attribute"
require "my_factory_girl/sequence"
require "my_factory_girl/aliases"

def Factory(name, attrs = {})
  Factory.create(name, attrs)
end
