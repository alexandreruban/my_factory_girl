require "spec_helper"

RSpec.describe Factory::Proxy do
  context "a proxy" do
    before do
      @proxy = Factory::Proxy.new(Class.new)
    end

    it "does nothing when asked to set an attribute to a value" do
      expect(@proxy.set(:name, "a name")).to be_nil
    end

    it "returns nil when asked for an attribute" do
      expect(@proxy.get(:name)).to be_nil
    end

    it "calls get for a missing method" do
      expect(@proxy).to receive(:get).with(:name).and_return("A name")
      expect(@proxy.name).to eq("A name")
    end

    it "does nothing when asked to associate with another factory" do
      expect(@proxy.associate(:owner, :user, {})).to be_nil
    end

    it "raises an error when asked for the result" do
      expect { @proxy.result }.to raise_error(NotImplementedError)
    end
  end
end
