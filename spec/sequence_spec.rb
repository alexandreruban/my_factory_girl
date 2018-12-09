require "spec_helper"

RSpec.describe Factory::Sequence do
  context "a sequence" do
    before do
      @sequence = Factory::Sequence.new { |n| "=#{n}"}
    end

    it "starts with the value of 1" do
      expect(@sequence.next).to eq("=1")
    end

    context "after being called" do
      before do
        @sequence.next
      end

      it "uses the next value" do
        expect(@sequence.next).to eq("=2")
      end
    end
  end

  context "defining a sequence" do
    before do
      @sequence = double("sequence")
      @name = :count
      allow(Factory::Sequence) .to receive(:new).and_return(@sequence)
    end

    it "creates a new sequence" do
      expect(Factory::Sequence).to receive(:new).with(no_args).and_return(@sequence)
      Factory.sequence(@name)
    end

    it "uses the supplied block as the sequence generator" do
      allow(Factory::Sequence).to receive(:new).and_yield(1)
      yielded = false
      Factory.sequence(@name) { |n| yielded = true }
      expect(yielded).to be true
    end
  end

  context "after defining a sequence" do
    before do
      @sequence = double("sequence")
      @name = :test
      @value = "1 2 5"

      allow(@sequence).to receive(:next).and_return(@value)
      allow(Factory::Sequence).to receive(:new).and_return(@sequence)

      Factory.sequence(@name) {}
    end

    it "calls next on the sequence when sent next" do
      expect(@sequence).to receive(:next)
      Factory.next(@name)
    end

    it "returns the value of the sequence" do
      expect(Factory.next(@name)).to eq(@value)
    end
  end
end
