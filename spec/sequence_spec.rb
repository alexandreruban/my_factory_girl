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
end
