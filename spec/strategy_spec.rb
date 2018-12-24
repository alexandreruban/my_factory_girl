require "spec_helper"

RSpec.describe Factory::Strategy do
  context "a strategy" do
    before do
      @strategy = Factory::Strategy.new(Class.new)
    end

    it "does nothing when asked to set an attribute to a value" do
      expect(@strategy.set(:name, "a name")).to be_nil
    end

    it "returns nil when asked for an attribute" do
      expect(@strategy.get(:name)).to be_nil
    end

    it "calls get for a missing method" do
      expect(@strategy).to receive(:get).with(:name).and_return("A name")
      expect(@strategy.name).to eq("A name")
    end

    it "does nothing when asked to associate with another factory" do
      expect(@strategy.associate(:owner, :user, {})).to be_nil
    end

    it "raises an error when asked for the result" do
      expect { @strategy.result }.to raise_error(NotImplementedError)
    end
  end
end
