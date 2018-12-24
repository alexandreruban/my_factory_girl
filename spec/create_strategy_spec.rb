require "spec_helper"

RSpec.describe Factory::Proxy::Create do
  context "the build proxy" do
    before do
      @class = Class.new
      @instance = double("built-instance")
      @association = double("associated-instance")

      allow(@class).to receive(:new).and_return(@instance)
      allow(Factory).to receive(:create).and_return(@association)
      allow(@instance).to receive(:attribute).and_return("value")
      allow(@instance).to receive(:attribute=)
      allow(@instance).to receive(:owner=)
      allow(@instance).to receive(:save!)

      @proxy = Factory::Proxy::Create.new(@class)
    end

    it "calls Factory.create when building the association" do
      association = "association"
      attributes = { name: "Billy" }
      expect(Factory)
        .to receive(:create)
        .with(:user, attributes)
        .and_return(association)

      expect(@proxy.association(:user, attributes)).to eq(association)
    end

    context "when asked to associate with another factory" do
      it "creates the associated instance" do
        expect(Factory).to receive(:create).with(:user, {}).and_return(@association)
        @proxy.associate(:owner, :user, {})
      end

      it "sets the associated instance" do
        expect(@instance).to receive(:owner=).with(@association)
        @proxy.associate(:owner, :user, {})
      end
    end

    context "when asked for the result" do
      it "saves the instance" do
        expect(@instance).to receive(:save!).with(no_args)
        @result = @proxy.result
      end

      it "returns the built instance" do
        expect(@proxy.result).to eq(@instance)
      end
    end

    context "when setting an attribute" do
      it "sets that value" do
        expect(@instance).to receive(:attribute=).with("value")
        @proxy.set(:attribute, "value")
      end
    end

    context "when getting an attribute" do
      it "returns the value" do
        expect(@instance).to receive(:attribute).and_return("value")
        @proxy.get(:attribute)
      end
    end
  end
end
