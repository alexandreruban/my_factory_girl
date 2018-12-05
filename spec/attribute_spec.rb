require "spec_helper"

RSpec.describe Factory::Attribute do
  context "an attribute" do
    before do
      @name = :user
      @proxy = double("attribute-proxy")
      @attr = Factory::Attribute.new(@name)
    end

    it "has a name" do
      expect(@attr.name).to eq(@name)
    end

    context "after setting a static attribute" do
      before do
        @value = "test"
        @attr.static_value = @value
      end

      it "returns the value" do
        expect(@attr.value(@proxy)).to eq(@value)
      end
    end

    context "after setting a lazy value" do
      it "calls the block to retrun a value" do
        @attr.lazy_block = proc { "value" }
        expect(@attr.value(@proxy)).to eq("value")
      end

      it "yields the attribute proxy to the block" do
        @attr.lazy_block = proc { |a| a }
        expect(@attr.value(@proxy)).to eq(@proxy)
      end
    end
  end
end
