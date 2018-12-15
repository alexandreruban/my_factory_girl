require "spec_helper"

RSpec.describe Factory::AttributeProxy do
  context "an association proxy" do
    before do
      @strategy = double("strategy")
      @proxy = Factory::AttributeProxy.new(@strategy)
    end

    it "has a strategy" do
      expect(@proxy.strategy).to eq(@strategy)
    end

    it "returns a value from the strategy for an attribute's value" do
      allow(@strategy).to receive(:get).with(:name).and_return("Alex")
      expect(@proxy.value_for(:name)).to eq("Alex")
    end

    it "it returns a value from the strategy for an undefined method" do
      allow(@strategy).to receive(:get).with(:name).and_return("Alex")
      expect(@proxy.value_for(:name)).to eq("Alex")
    end
  end

  context "building an association using the AttributesFor strategy" do
    before do
      @strategy = Factory::Strategy::AttributesFor
      @proxy = Factory::AttributeProxy.new(@strategy)
    end

    it "does not build the association" do
      expect(Factory).not_to receive(:create)
      @proxy.association(:user)
    end

    it "returns nil for the association" do
      expect(@proxy.association(:user)).to be_nil
    end
  end

  [Factory::Strategy::Build, Factory::Strategy::Create].each do |strategy_class|
    context "an association usign the #{strategy_class.name} strategy" do
      before do
        @strategy = strategy_class.new(Object)
        @proxy = Factory::AttributeProxy.new(@strategy)
      end

      it "calls Factory.create when building the association" do
        attribs = { first_name: "Billy" }
        expect(Factory).to receive(:create).with(:user, attribs)
        @proxy.association(:user, attribs)
      end

      it "returns the built association" do
        association = double("built-user")
        allow(Factory).to receive(:create).and_return(association)
        expect(@proxy.association(:user)).to eq(association)
      end
    end
  end
end
