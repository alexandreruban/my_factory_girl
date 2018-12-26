require "spec_helper"

RSpec.describe Factory::Attribute do
  it "raises an error when defining an attribute writer" do
    expect { Factory::Attribute.new(:content=) }
      .to raise_error(Factory::AttributeDefinitionError)
  end

  it "raises an error when returning a sequence" do
    allow(Factory).to receive(:sequence).and_return(Factory::Sequence.new)
    block = -> (proxy) { Factory.sequence(:email) }
    attr = Factory::Attribute::Dynamic.new(:email, block)
    proxy = double("proxy")
    expect { attr.add_to(proxy) }.to raise_error(Factory::SequenceAbuseError)
  end

  it "converts names to symbols" do
    expect(Factory::Attribute.new("name").name).to eq(:name)
  end

  context "an attribute" do
    before do
      @name = :user
      @attr = Factory::Attribute.new(@name)
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