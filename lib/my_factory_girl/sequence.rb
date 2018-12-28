module FactoryGirl
  @sequences = {}

  class << self
    attr_accessor :sequences
  end

  # Raised when calling Factory.sequence from a dynamic attribute block
  class SequenceAbuseError < StandardError
  end

  class Sequence
    def initialize(value = 1, &proc)
      @proc = proc
      @value = value
    end

    def next
      @proc.call(@value)
    ensure
      @value = @value.next
    end
  end
end
