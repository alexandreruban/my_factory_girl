require "spec_helper"

RSpec.describe Factory::AttributeProxy do
  context "an association proxy" do
    before do
      @factory = double("factory")
      @attr = :user
      @attrs = { first_name: "John" }
      @strategy = :create
      @proxy = Factory::AttributeProxy.new(@factory, @attr, @strategy, @attrs)
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

    it "has attributes" do
      expect(@proxy.current_values).to eq(@attrs)
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

    context "fetching the value of an attribute" do
      before do
        @attribute = :beachball
      end

      it "raises ArgumentError when the attribute is not defined" do
        expect { @proxy.value_for(@attribute) }
          .to raise_error(ArgumentError)
      end
    end

    context "building an association using the attributes for strategy" do
      before do
        @strategy = :attributes_for
        @proxy = Factory::AttributeProxy.new(@factory, @attr, @strategy, @attrs)
      end

      it "does not build the association" do
        expect(@factory).not_to receive(@strategy)
        @proxy.association(:user)
      end

      it "returns nil for the association" do
        expect(@proxy.association(:user)).to be_nil
      end
    end
  end
end
