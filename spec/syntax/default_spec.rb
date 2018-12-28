require "spec_helper"

RSpec.describe "Default syntax" do
  before do
    Factory.sequence(:email) { |n| "somebody#{n}@example.com" }
    Factory.define :user do |f|
      f.first_name { "Bill" }
      f.last_name { "Nye" }
      f.email { Factory.next(:email) }
    end
  end

  after do
    FactoryGirl.factories.clear
    FactoryGirl.sequences.clear
  end

  context "after making an instance" do
    before { @user = Factory(:user, last_name: "Rye") }

    it "uses the attributes form the definition" do
      expect(@user.first_name).to eq("Bill")
    end

    it "evaluates the attribute block for each instance" do
      expect(@user.email).to match(/somebody\d+@example.com/)
      expect(@user.email).not_to eq(Factory(:user).email)
    end
  end

  it "raises ArgumentError when trying to use a non existent strategy" do
    expect { Factory.define(:object, default_strategy: :non_existent) {} }
      .to raise_error(ArgumentError)
  end
end

RSpec.describe Factory, "given a parent factory" do
  before do
    @parent = FactoryGirl::Factory.new(:object)
    @parent.define_attribute(FactoryGirl::Attribute::Static.new(:name, "value"))
    FactoryGirl.register_factory(@parent)
  end

  after { FactoryGirl.factories.clear }

  it "raises ArgumentError when trying to use a non existent factory as parent" do
    expect { Factory.define(:child, parent: :non_existent) {} }
      .to raise_error(ArgumentError)
  end
end

RSpec.describe "defining a factory" do
  before do
    @name = :user
    @factory = double("factory")
    @proxy = double("proxy")
    allow(@factory).to receive(:factory_name).and_return(@name)
    @options = { class: "magic" }
    allow(FactoryGirl::Factory).to receive(:new).and_return(@factory)
    allow(FactoryGirl::DefinitionProxy).to receive(:new).and_return(@proxy)
  end

  after { FactoryGirl.factories.clear }

  it "creates a new factory using the specified name and options" do
    expect(FactoryGirl::Factory).to receive(:new).with(@name, @options)
    Factory.define(@name, @options) {}
  end

  it "passes the proxy to the block" do
    yielded = nil
    Factory.define(@name) do |y|
      yielded = y
    end
    expect(yielded).to eq(@proxy)
  end

  it "allows a factory to be found by name" do
    Factory.define(@name) {}
    expect(FactoryGirl.factory_by_name(@name)).to eq(@factory)
  end
end

RSpec.describe "after defining a factory" do
  before do
    @name = :user
    @factory = double("factory")
    FactoryGirl.factories[@name] = @factory
  end

  after { FactoryGirl.factories.clear }

  it "uses Proxy::AttributesFor for Factory.attributes_for" do
    expect(@factory)
      .to receive(:run)
      .with(FactoryGirl::Proxy::AttributesFor, attr: "value")
      .and_return("result")

    expect(Factory.attributes_for(@name, attr: "value")).to eq("result")
  end

  it "uses Proxy::Build for Factory.build" do
    expect(@factory)
      .to receive(:run)
      .with(FactoryGirl::Proxy::Build, attr: "value")
      .and_return("result")

    expect(Factory.build(@name, attr: "value")).to eq("result")
  end

  it "uses Proxy::Create for Factory.create" do
    expect(@factory)
      .to receive(:run)
      .with(FactoryGirl::Proxy::Create, attr: "value")
      .and_return("result")

    expect(Factory.create(@name, attr: "value")).to eq("result")
  end

  it "uses Proxy::Stub for Factory.stub" do
    expect(@factory)
      .to receive(:run)
      .with(FactoryGirl::Proxy::Stub, attr: "value")
      .and_return("result")

    expect(Factory.stub(@name, attr: "value")).to eq("result")
  end

  it "uses the default strategy option as Factory.default_strategy" do
    expect(@factory).to receive(:default_strategy).and_return(:build)
    expect(@factory)
      .to receive(:run)
      .with(FactoryGirl::Proxy::Build, attr: "value")
      .and_return("result")

    expect(Factory.default_strategy(@name, attr: "value")).to eq("result")
  end

  it "uses the default strategy for the global Factory method" do
    expect(@factory).to receive(:default_strategy).and_return(:stub)
    expect(@factory)
      .to receive(:run)
      .with(FactoryGirl::Proxy::Stub, attr: "value")
      .and_return("result")
    expect(Factory(@name, attr: "value")).to eq("result")
  end

  [:build, :create, :attributes_for, :stub].each do |method|
    it "raises ArgumentError on #{method} with a non existent factory" do
      expect { Factory.send(method, :bogus) }.to raise_error(ArgumentError)
    end

    it "recognizes either 'name' or :name for Factory.#{method}" do
      allow(@factory).to receive(:run)

      expect { Factory.send(method, @name.to_s) }.not_to raise_error
      expect { Factory.send(method, @name.to_sym) }.not_to raise_error
    end
  end
end

RSpec.describe "defining a sequence" do
  before do
    @sequence = double("sequence")
    @name = :count
    allow(FactoryGirl::Sequence).to receive(:new).and_return(@sequence)
  end

  it "creates a new sequence" do
    expect(FactoryGirl::Sequence).to receive(:new).with(1).and_return(@sequence)
    Factory.sequence(@name)
  end

  it "uses the supplied block as the sequence generator" do
    allow(FactoryGirl::Sequence).to receive(:new).and_yield(1)
    yielded = false
    Factory.sequence(@name) { |n| yielded = true }
    expect(yielded).to be true
  end

  it "uses the supplied value as the start value" do
    expect(FactoryGirl::Sequence)
      .to receive(:new)
      .with("A")
      .and_return(@sequence)

    Factory.sequence(@name, "A")
  end
end
