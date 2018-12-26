require "spec_helper"

RSpec.describe Factory::Attribute::Static do
  context "a static attribute" do
    before do
      @name = :first_name
      @value = "John"
      @attr = Factory::Attribute::Static.new(@name, @value)
    end

    it "has a name" do
      expect(@attr.name).to eq(@name)
    end

    it "sets its static value on a proxy" do
      @proxy = double("proxy")
      expect(@proxy).to receive(:set).with(@name, @value)
      @attr.add_to(@proxy)
    end

    it "raises an error when defining an attribute writer" do
      expect { Factory::Attribute::Static.new("test=", nil) }
        .to raise_error(Factory::AttributeDefinitionError)
    end

    it "converts names to symbols" do
      expect(Factory::Attribute::Static.new("name", "value").name).to eq(:name)
    end
  end
end
