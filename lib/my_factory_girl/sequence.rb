module FactoryGirl
  @sequences = {}

  class << self
    attr_accessor :sequences
  end

  # Raised when calling Factory.sequence from a dynamic attribute block
  class SequenceAbuseError < StandardError
  end

  class Sequence
    def initialize(&proc)
      @proc = proc
      @value = 0
    end

    def next
      @value += 1
      @proc.call(@value)
    end
  end
end
