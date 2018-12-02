require "spec_helper"

RSpec.describe Factory::AttributeProxy do
  context "an association proxy" do
    before do
      @factory = double("factory")
      @attr = :user
      @strategy = :create
      @proxy = Factory::AttributeProxy.new(@factory, @attr, @strategy)
    end

    it "has a factory" do
      expect(@proxy.factory).to eq(@factory)
    end

    it "has an attribute name" do
      expect(@proxy.attribute_name).to eq(@attr)
    end

    it "has a strategy" do
      expect(@proxy.strategy).to eq(@strategy)
    end

    context "building an association" do
      before do
        @association = double("build user")
        @factory_name = :user
        @attribs = { first_name: "Billy" }

        allow(Factory).to receive(@strategy).and_return(@association)
      end

      it "delegates to the appropriate method on Factory" do
        expect(Factory).to receive(@strategy).with(@factory_name, @attribs)
        @proxy.association(@factory_name, @attribs)
      end

      it "returns the built association" do
        expect(@proxy.association(@factory_name)).to eq(@association)
      end
    end
  end
end
