class Factory
  # Raised when calling Factory.sequence from a dynamic attribute block
  class SequenceAbuseError < StandardError; end

  @sequences = {}

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

  class << self
    attr_accessor :sequences

    def sequence(name, &block)
      sequences[name] = Sequence.new(&block)
    end

    def next(sequence)
      raise "No such sequence: #{sequence}" unless sequences.key?(sequence)

      sequences[sequence].next
    end
  end
end
