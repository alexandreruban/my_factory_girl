require "spec_helper"

RSpec.describe FactoryGirl::Attribute::Dynamic do
  it "raises an error when defining an attribute writer" do
    expect { FactoryGirl::Attribute.new(:content=) }
      .to raise_error(FactoryGirl::AttributeDefinitionError)
  end

  it "raises an error when returning a sequence" do
    allow(Factory).to receive(:sequence).and_return(FactoryGirl::Sequence.new)
    block = -> (proxy) { Factory.sequence(:email) }
    attr = FactoryGirl::Attribute::Dynamic.new(:email, block)
    proxy = double("proxy")
    expect { attr.add_to(proxy) }.to raise_error(FactoryGirl::SequenceAbuseError)
  end

  it "converts names to symbols" do
    expect(FactoryGirl::Attribute.new("name").name).to eq(:name)
  end

  it "evaluates the block in the context of the proxy without an argument" do
    name = :email
    block = proc { "#{first_name}.#{last_name}@email.com".downcase }
    dynamic_attribute = described_class.new(name, block)
    proxy = double("proxy", first_name: "John", last_name: "Lenon")
    expect(proxy).to receive(:set).with(:email, "john.lenon@email.com")
    dynamic_attribute.add_to(proxy)
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
