require "my_factory_girl/proxy"
require "my_factory_girl/proxy/attributes_for"
require "my_factory_girl/proxy/build"
require "my_factory_girl/proxy/create"
require "my_factory_girl/proxy/stub"
require "my_factory_girl/factory"
require "my_factory_girl/attribute"
require "my_factory_girl/attribute/static"
require "my_factory_girl/attribute/dynamic"
require "my_factory_girl/attribute/association"
require "my_factory_girl/sequence"
require "my_factory_girl/aliases"

def Factory(name, attrs = {})
  Factory.create(name, attrs)
end
