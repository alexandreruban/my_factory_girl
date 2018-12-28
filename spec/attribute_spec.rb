require "spec_helper"

RSpec.describe FactoryGirl::Attribute do
  it "raises an error when defining an attribute writer" do
    expect { FactoryGirl::Attribute.new(:content=) }
      .to raise_error(FactoryGirl::AttributeDefinitionError)
  end

  it "converts names to symbols" do
    expect(FactoryGirl::Attribute.new("name").name).to eq(:name)
  end

  context "an attribute" do
    before do
      @name = :user
      @attr = FactoryGirl::Attribute.new(@name)
    end

    it "has a name" do
      expect(@attr.name).to eq(@name)
    end

    it "does nothing when being added to a proxy" do
      @proxy = double("proxy")
      expect(@proxy).not_to receive(:set)
      @attr.add_to(@proxy)
    end
  end
end
