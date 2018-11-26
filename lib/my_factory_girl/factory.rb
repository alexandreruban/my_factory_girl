class Factory
  @factories = {}
  attr_reader :factory_name

  class << self
    attr_accessor :factories

    def define(name, options = {})
      instance = Factory.new(name, options)
      yield(instance)
      factories[name] = instance
    end
  end

  def initialize(factory_name, options = {})
    @factory_name = factory_name
    @options = options
    @static_attributes = {}
    @lazy_attributes = {}
  end
end
