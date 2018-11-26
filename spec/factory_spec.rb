require "spec_helper"

RSpec.describe Factory do
  context "defining a factory" do
    before do
      @name = :user
      @factory = double("factory")
      allow(Factory).to receive(:new) { @factory }
    end

    it "creates a new factory" do
      Factory.define(@name) { |f| }

      expect(Factory).to have_received(:new)
    end

    it "adds the factory to the factories list" do
      Factory.define(@name) { |f| }

      expect(Factory.factories[@name]).to eq(@factory)
    end

    it "yields the instance to the block" do
      yielded = nil
      Factory.define(@name) do |f|
        yielded = f
      end

      expect(yielded).to eq(@factory)
    end
  end
end
