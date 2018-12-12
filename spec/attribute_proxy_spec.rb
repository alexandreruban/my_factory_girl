require "spec_helper"

RSpec.describe Factory::AttributeProxy do
  context "an association proxy" do
    before do
      @attrs = { first_name: "John" }
      @strategy = :create
      @proxy = Factory::AttributeProxy.new(@strategy, @attrs)
    end

    it "has a build strategy" do
      expect(@proxy.strategy).to eq(@strategy)
    end

    it "has attributes" do
      expect(@proxy.current_values).to eq(@attrs)
    end

    it "returns the correct value for an attribute" do
      expect(@proxy.value_for(:first_name)).to eq(@attrs[:first_name])
    end

    it "calls value_for for undefined methods" do
      expect(@proxy.first_name).to eq(@attrs[:first_name])
    end

    context "building an association using the AttributesFor strategy" do
      before do
        @strategy = :attributes_for
        @proxy = Factory::AttributeProxy.new(@strategy, @attrs)
      end

      it "does not build the association" do
        expect(Factory).not_to receive(@strategy)
        @proxy.association(:user)
      end

      it "returns nil for the association" do
        expect(@proxy.association(:user)).to be_nil
      end
    end

    ["build", "create"].each do |strategy|
      context "an association usign the #{strategy} strategy" do
        before do
          @strategy = strategy.to_sym
          @attrs = { first_name: "John" }
          @proxy = Factory::AttributeProxy.new(@strategy, @attrs)
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
end
