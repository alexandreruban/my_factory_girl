require "spec_helper"

RSpec.describe Factory::Attribute do
  before do
    @strategy = double("strategy")
  end

  it "raises an error when defining an attribute writer" do
    expect { Factory::Attribute.new(:content=, "writer", nil) }
      .to raise_error(Factory::AttributeDefinitionError)
  end

  it "not allow attributes to be added with both a value parameter and a block" do
    expect { Factory::Attribute.new(:content=, "writer", Proc.new {}) }
      .to raise_error(Factory::AttributeDefinitionError)
  end

  it "converts names to symbols" do
    expect(Factory::Attribute.new("name", nil, nil).name).to eq(:name)
  end

  context "an attribute" do
    before do
      @name = :user
      @attr = Factory::Attribute.new(@name, "test", nil)
    end

    it "has a name" do
      expect(@attr.name).to eq(@name)
    end
  end

  context "an attribute with a statix value" do
    before do
      @value = "test"
      @attr = Factory::Attribute.new(:user, @value, nil)
    end

    it "returns the value without building a proxy" do
      expect(Factory::AttributeProxy).not_to receive(:new)
      expect(@attr.value(@strategy)).to eq(@value)
    end
  end

  context "an attribute with a lazy value" do
    it "calls the block to retrun a value" do
      @block = -> (a) { "value" }
      @attr = Factory::Attribute.new(:user, nil, @block)
      expect(@attr.value(@strategy)).to eq("value")
    end

    it "yields the attribute proxy to the block" do
      @block = -> (a) { a }
      @attr = Factory::Attribute.new(:user, nil, @block)
      proxy = double("attribute-proxy")
      allow(Factory::AttributeProxy)
        .to receive(:new)
        .with(@strategy)
        .and_return(proxy)
      expect(@attr.value(@strategy)).to eq(proxy)
    end
  end
end
