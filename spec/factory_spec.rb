require "spec_helper"

RSpec.describe Factory, "registering a factory" do
  before do
    @name = :user
    @factory = double("factory", factory_name: @name)
  end

  after { FactoryGirl.factories.clear }

  it "should add the factory to the list of factories" do
     FactoryGirl.register_factory(@factory)
     expect(FactoryGirl.factory_by_name(@name)).to eq(@factory)
   end

  it "does not allow a duplicate factory definition" do
    expect { 2.times { Factory.define(:user) { |f| } } }
      .to raise_error(FactoryGirl::DuplicateDefinitionError)
  end
end

RSpec.describe Factory do
  before do
    @factory_name = :user
    @class = User
    @factory = FactoryGirl::Factory.new(@factory_name)
  end

  after { FactoryGirl.factories.clear }

  it "has a factory name" do
    expect(@factory.factory_name).to eq(@factory_name)
  end

  it "has a build class" do
    expect(@factory.build_class).to eq(@class)
  end

  it "has a default strategy" do
    expect(@factory.default_strategy).to eq(:create)
  end

  it "guesses the build class from the factory name" do
    expect(@factory.build_class).to eq(@class)
  end

  context "when defined with a custom class" do
    before do
      @class = User
      @factory = FactoryGirl::Factory.new(:author, class: @class)
    end

    it "uses the specified class as the build class" do
      expect(@factory.build_class).to eq(@class)
    end
  end

  context "when defined with a class instead of a name" do
    before do
      @class = ArgumentError
      @name = :argument_error
      @factory = FactoryGirl::Factory.new(@class)
    end

    it "guesses the factory name from the class" do
      expect(@factory.factory_name).to eq(@name)
    end

    it "uses the class as the build class" do
      expect(@factory.build_class).to eq(@class)
    end
  end

  context "when defined with a custom class" do
    before do
      @class = ArgumentError
      @factory = FactoryGirl::Factory.new(:author, class: :argument_error)
    end

    it "uses the specified class as the build class" do
      expect(@factory.build_class).to eq(@class)
    end
  end
end

RSpec.describe "a factory with a name ending in s" do
  before do
    @name = :business
    @class = Business
    @factory = FactoryGirl::Factory.new(@name)
  end

  it "has a factory name" do
    expect(@factory.factory_name).to eq(@name)
  end

  it "has a build class" do
    expect(@factory.build_class).to eq(@class)
  end
end

RSpec.describe "a factory with a string name" do
  before do
    @name = :user
    @factory = FactoryGirl::Factory.new(@name.to_s) {}
  end

  it "converts the string to a symbol" do
    expect(@factory.factory_name).to eq(@name)
  end
end

RSpec.describe "a factory defined with a string name" do
  before do
    @name = :user
    @factory = Factory.define(@name.to_s) {}
  end

  after { FactoryGirl.factories.clear }

  it "converts the string to a symbol" do
    expect(@factory.factory_name).to eq(@name)
  end
end

RSpec.describe "defining a factory using a parent attribute" do
  before do
    @parent = Factory.define :object do |f|
      f.name "Name"
    end
  end

  after { FactoryGirl.factories.clear }

  it "raises ArgumentError when using a non existent factory as parent" do
    expect { Factory.define(:child, parent: :nonexistent) {} }
      .to raise_error(ArgumentError)
  end

  it "creates a new factory using the class of the parent" do
    child = Factory.define(:child, parent: :object) {}

    expect(child.build_class).to eq(@parent.build_class)
  end

  it "creates a new factory while overriding the parents class" do
    class Other; end

    child = Factory.define(:child, parent: :object, class: Other) {}
    expect(child.build_class).to eq(Other)
  end

  it "creates a new factory with the attributes of the parent" do
    child = Factory.define(:child, parent: :object) {}

    expect(child.attributes.size).to eq(1)
    expect(child.attributes.first.name).to eq(:name)
  end

  it "allows to define additional attributes" do
    child = Factory.define(:child, parent: :object) do |f|
      f.email "person@email.com"
    end

    expect(child.attributes.size).to eq(2)
  end

  it "allows to override the parent attribute" do
    child = Factory.define(:child, parent: :object) do |f|
      f.name { "John Doe" }
    end

    expect(child.attributes.size).to eq(1)
    expect(child.attributes.first)
      .to be_an_instance_of(FactoryGirl::Attribute::Dynamic)
  end

  it "inherits all callbacks" do
    Factory.define(:child, parent: :object) do |f|
      f.after_stub { |o| o.name = "Stuby"}
    end

    grandchild = Factory.define(:grandchild, parent: :child) do |f|
      f.after_stub { |o| o.name = "#{o.name} McStuby"}
    end

    expect(grandchild.attributes.size).to eq(3)
    expect(grandchild.attributes[0])
      .to be_an_instance_of(FactoryGirl::Attribute::Callback)
    expect(grandchild.attributes[1])
      .to be_an_instance_of(FactoryGirl::Attribute::Callback)
  end
end

RSpec.describe "when defining a child factory without setting default strategy" do
  before do
    @parent = Factory.define(:object, default_strategy: :stub) {}
    @child = Factory.define(:child, parent: :object) {}
  end

  after { FactoryGirl.factories.clear }

  it "inherits the default strategy from its parent" do
    expect(@child.default_strategy).to eq(:stub)
  end
end

RSpec.describe "when defining a child factory with a default strategy" do
  before do
    @parent = Factory.define(:object, default_strategy: :stub) {}
    @child = Factory.define(
      :child,
      parent: :object,
      default_strategy: :build
    ) {}
  end

  after { FactoryGirl.factories.clear }

  it "should not inherit the default strategy from its parent" do
    expect(@child.default_strategy).to eq(:build)
  end
end

RSpec.describe "a factory for a namespaces class" do
  before do
    @name = :settings
    @class = Admin::Settings
  end

  after { FactoryGirl.factories.clear }

  it "builds a namespaced class passed by a string" do
    factory = Factory.define(@name.to_s, class: @class.name) {}
    expect(factory.build_class).to eq(@class)
  end

  it "builds Admin::Settings class form Admin::Settings string" do
    factory = Factory.define(@name.to_s, class: @class.name.underscore) {}
    expect(factory.build_class).to eq(@class)
  end
end

RSpec.describe "Factory class" do
  before do
    @name = :user
    @factory = double("factory")
    FactoryGirl.factories[@name] = @factory
  end

  after { FactoryGirl.factories.clear }

  it "uses the default strategy option as Factory.default_strategy" do
    allow(@factory).to receive(:default_strategy).and_return(:create)
    expect(@factory)
      .to receive(:run)
      .with(FactoryGirl::Proxy::Create, attr: "value")
      .and_return("result")
    expect(Factory.default_strategy(@name, attr: "value")).to eq("result")
  end

  [:attributes_for, :build, :create, :stub].each do |method|
    it "raises ArgumentError when called with a non existing factory" do
      expect { Factory.send(method, :bogus) }.to raise_error(ArgumentError)
    end

    it "recognises either 'name' and :name for Factory.#{method}" do
      allow(@factory).to receive(:run)
      expect { Factory.send(method, @name.to_s) }.not_to raise_error
      expect { Factory.send(method, @name) }.not_to raise_error
    end
  end

  it "uses FactoryGirl::Stub for Factory.stub" do
    expect(@factory)
      .to receive(:run)
      .with(FactoryGirl::Proxy::Stub, attr: "value")
      .and_return("result")

    expect(Factory.stub(@name, attr: "value")).to eq("result")
  end
end

RSpec.describe "defining a factory with a default strategy parameter" do
  it "raises ArgumentError when trying to use a non existent factory" do
    expect { Factory.define(:object, default_strategy: :nonexistent) {} }
      .to raise_error(ArgumentError)
  end

  it "creates a new factory with a specified default strategy" do
    factory = Factory.define(:object, default_strategy: :stub) {}
    expect(factory.default_strategy).to eq(:stub)
  end
end
