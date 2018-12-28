require "spec_helper"

RSpec.describe FactoryGirl::Attribute::Association do
  context "an association" do
    before do
      @name = :author
      @factory = :user
      @overrides = { first_name: "John" }
      @attr = FactoryGirl::Attribute::Association.new(@name, @factory, @overrides)
    end

    it "has a name" do
      expect(@attr.name).to eq(@name)
    end

    it "tells the proxy to associate when being added to a proxy" do
      proxy = double("proxy")
      expect(proxy).to receive(:associate).with(@name, @factory, @overrides)
      @attr.add_to(proxy)
    end

    it "converts names to symbols" do
      expect(FactoryGirl::Attribute::Association.new("name", "value", {}).name)
        .to eq(:name)
    end
  end
end
