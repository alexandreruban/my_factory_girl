class Factory
  @aliases = [
    [/(.*)_id/, '\1'],
    [/(.*)/, '\1_id'],
  ]

  class << self
    attr_accessor :aliases

    def alias(pattern, replace)
      aliases << [pattern, replace]
    end

    def aliases_for(attribute)
      aliases.map do |params|
        pattern, replace = *params
        if pattern.match(attribute.to_s)
          attribute.to_s.sub(pattern, replace).to_sym
        else
          nil
        end
      end.compact << attribute
    end
  end
end
