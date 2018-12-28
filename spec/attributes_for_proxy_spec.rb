require "spec_helper"

RSpec.describe FactoryGirl::Proxy::AttributesFor do
  context "the build proxy" do
    before do
      @proxy = FactoryGirl::Proxy::AttributesFor.new(@class)
    end

    it "returns a hash when asked for the result" do
      expect(@proxy.result).to be_a_kind_of(Hash)
    end

    context "when asked to associate with another factory" do
      before do
        allow(Factory).to receive(:create)
        @proxy.associate(:owner, :user, {})
      end

      it "should not set a value for the association" do
        expect(@proxy.result).not_to have_key(:owner)
      end
    end

    context "after setting an attribute" do
      before do
        @proxy.set(:attribute, "value")
      end

      it "sets that value in the result hash" do
        expect(@proxy.result[:attribute]).to eq("value")
      end

      it "returns that value when asked for that attribute" do
        expect(@proxy.get(:attribute)).to eq("value")
      end
    end
  end
end
