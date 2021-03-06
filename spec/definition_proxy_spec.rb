require "spec_helper"

RSpec.describe FactoryGirl::DefinitionProxy do
  let(:factory) { FactoryGirl::Factory.new(:object) }
  subject { FactoryGirl::DefinitionProxy.new(factory) }

  it "adds a static attribute for type" do
    subject.type "value"
    expect(factory.attributes.last).to be_a(FactoryGirl::Attribute::Static)
  end

  it "adds a static attribute for id" do
    subject.id "value"
    expect(factory.attributes.last).to be_a(FactoryGirl::Attribute::Static)
  end

  it "adds a static attribute when attribute is defined with a value" do
    attribute = double("attribute")
    allow(attribute).to receive(:name).and_return(:name)
    expect(FactoryGirl::Attribute::Static)
      .to receive(:new)
      .with(:name, "value")
      .and_return(attribute)
    expect(factory).to receive(:define_attribute).and_return(attribute)
    subject.add_attribute(:name, "value")
  end

  it "should add a dynamic attribute when an attribute is defined with a block" do
    attribute = double("attribute")
    block = -> {}
    allow(attribute).to receive(:name).and_return("name")
    expect(FactoryGirl::Attribute::Dynamic)
      .to receive(:new)
      .with(:name, block)
      .and_return(attribute)
    expect(factory).to receive(:define_attribute).and_return(attribute)

    subject.add_attribute(:name, &block)
  end

  it "raises for an attribute with both a value and a block" do
    expect { subject.add_attribute(:name, "value") {} }
      .to raise_error(FactoryGirl::AttributeDefinitionError)
  end

  describe "adding an attribute using an inline sequence" do
    it "creates the sequence" do
      expect(FactoryGirl::Sequence).to receive(:new)
      subject.sequence(:name) {}
    end

    it "adds a dynamic attribute" do
      attribute = double("attribute", name: :name)
      expect(FactoryGirl::Attribute::Dynamic)
        .to receive(:new)
        .with(:name, an_instance_of(Proc))
        .and_return(attribute)

      subject.sequence(:name) {}
      expect(factory.attributes).to include(attribute)
    end
  end

  it "adds a callback when the after_build attribute is defined" do
    expect(FactoryGirl::Attribute::Callback)
      .to receive(:new)
      .with(:after_build, an_instance_of(Proc))
      .and_return("after_build callback")
    subject.after_build {}

    expect(factory.attributes).to include("after_build callback")
  end

  it "adds a callback when the after_create attribute is defined" do
    expect(FactoryGirl::Attribute::Callback)
      .to receive(:new)
      .with(:after_create, an_instance_of(Proc))
      .and_return("after_create callback")
    subject.after_create {}

    expect(factory.attributes).to include("after_create callback")
  end

  it "adds a callback when the after_stub attribute is defined" do
    expect(FactoryGirl::Attribute::Callback)
      .to receive(:new)
      .with(:after_stub, an_instance_of(Proc))
      .and_return("after_stub callback")
    subject.after_stub {}

    expect(factory.attributes).to include("after_stub callback")
  end

  it "adds an association without a factory name or overrides" do
    name = :user
    attr = double("attribute", name: name)
    expect(FactoryGirl::Attribute::Association)
      .to receive(:new)
      .with(name, name, {})
      .and_return(attr)

    subject.association(name)
    expect(factory.attributes).to include(attr)
  end

  it "adds an association with overrides" do
    name = :user
    overrides = { first_name: "Ben" }
    attr = double("attribute", name: name)
    expect(FactoryGirl::Attribute::Association)
      .to receive(:new)
      .with(name, name, overrides)
      .and_return(attr)

    subject.association(name, overrides)
    expect(factory.attributes).to include(attr)
  end

  it "adds an attribute using the method name when passed an undefined method" do
    attr = double("attribute", name: :name)
    block = -> {}
    expect(FactoryGirl::Attribute::Static)
      .to receive(:new)
      .with(:name, "value")
      .and_return(attr)

    subject.send(:name, "value")
    expect(factory.attributes).to include(attr)
  end

  it "adds an attribute when passed an undefined method and block" do
    attribute = double("attribute", name: :name)
    block = -> {}
    expect(FactoryGirl::Attribute::Dynamic)
      .to receive(:new)
      .with(:name, block)
      .and_return(attribute)
    subject.send(:name, &block)
    expect(factory.attributes).to include(attribute)
  end

  it "adds an association when passed an undefined method without arguments or block" do
    name = :user
    attribute = double("attribute", name: :name)
    expect(FactoryGirl::Attribute::Association)
      .to receive(:new)
      .with(name, name, {})
      .and_return(attribute)

    subject.send(name)
    expect(factory.attributes).to include(attribute)
  end

  it "adds a sequence when passed an undefined method with no args and no block" do
    name = :airport
    FactoryGirl.sequences[name] = FactoryGirl::Sequence.new { |value| "expected" }
    subject.send(name)
    proxy = double("proxy")
    attribute = factory.attributes.last
    allow(proxy).to receive(:set)
    attribute.add_to(proxy)

    expect(proxy).to have_received(:set).with(name, "expected")
  end

  it "delegate to_create" do
    expect(factory).to receive(:to_create) { "result" }

    expect(subject.to_create).to eq("result")
  end
end
