require "spec_helper"

RSpec.describe Factory::Strategy::AttributesFor do
  context "the build strategy" do
    before do
      @strategy = Factory::Strategy::AttributesFor.new(@class)
    end

    it "returns a hash when asked for the result" do
      expect(@strategy.result).to be_a_kind_of(Hash)
    end

    context "when asked to associate with another factory" do
      before do
        allow(Factory).to receive(:create)
        @strategy.associate(:owner, :user, {})
      end

      it "should not set a value for the association" do
        expect(@strategy.result).not_to have_key(:owner)
      end
    end

    context "after setting an attribute" do
      before do
        @strategy.set(:attribute, "value")
      end

      it "sets that value in the result hash" do
        expect(@strategy.result[:attribute]).to eq("value")
      end

      it "returns that value when asked for that attribute" do
        expect(@strategy.get(:attribute)).to eq("value")
      end
    end
  end
end
