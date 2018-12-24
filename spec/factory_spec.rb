require "spec_helper"

RSpec.describe Factory do
  def self.should_instanciate_class
    it "instaciates the build class" do
      expect(@instance).to be_a_kind_of(@class)
    end

    it "assigns the attributes on the instance" do
      expect(@first_name).to eq(@instance.first_name)
      expect(@last_name).to eq(@instance.last_name)
    end

    it "overrides the attributes using the passed hash" do
      @value = "Davis"
      @instance = @factory.build(first_name: @value)

      expect(@instance.first_name).to eq(@value)
    end
  end

  context "defining a factory" do
    before do
      @factory_name = :user
      @factory = double("factory")
      @options = { class: "magic" }
      allow(@factory).to receive(:factory_name).and_return(@factory_name)
      allow(Factory).to receive(:new) { @factory }
    end

    it "creates a new factory using the specified factory name and options" do
      Factory.define(@factory_name, @options) { |f| }

      expect(Factory).to have_received(:new).with(@factory_name, @options)
    end

    it "adds the factory to the factories list" do
      Factory.define(@factory_name) { |f| }

      expect(Factory.factories[@factory_name]).to eq(@factory)
    end

    it "yields the instance to the block" do
      yielded = nil
      Factory.define(@factory_name) { |f| yielded = f }

      expect(yielded).to eq(@factory)
    end
  end

  context "a factory" do
    before do
      @factory_name = :user
      @class = User
      @factory = Factory.new(@factory_name)
    end

    it "has a factory name" do
      expect(@factory.factory_name).to eq(@factory_name)
    end

    it "adds an attribute using the method name when passed an undefined method" do
      attr = double("attribute", name: :name)
      block = -> {}
      expect(Factory::Attribute::Static)
        .to receive(:new)
        .with(:name, "value")
        .and_return(attr)

      @factory.send(:name, "value")
      expect(@factory.attributes).to include(attr)
    end

    it "has a build class" do
      expect(@factory.build_class).to eq(@class)
    end

    it "does not allow the same attribute to be defined twice" do
      expect { 2.times { @factory.add_attribute(:first_name, "John") } }
        .to raise_error(Factory::AttributeDefinitionError)
    end

    it "guesses the build class from the factory name" do
      expect(@factory.build_class).to eq(@class)
    end

    it "allows attributes to be added with string as names" do
      @factory.add_attribute("name", "value")

      result = @factory::run(Factory::Proxy::AttributesFor, {})
      expect(result[:name]).to eq("value")
    end

    it "adds a static attribute when an attribute is defined with a value" do
      attribute = double("attribute", name: :name)
      expect(Factory::Attribute::Static)
        .to receive(:new)
        .with(:name, "value")
        .and_return(attribute)
      @factory.add_attribute(:name, "value")
    end

    it "adds a dynamic attribute when an attribute is defined with a block" do
      attribute = double("attribute", name: :name)
      block = proc {}
      expect(Factory::Attribute::Dynamic)
        .to receive(:new)
        .with(:name, block)
        .and_return(attribute)

      @factory.add_attribute(:name, &block)
    end

    it "raises when the attribute is defined with both a value and a block" do
      expect { @factory.add_attribute(:name, "value") {} }
        .to raise_error(Factory::AttributeDefinitionError)
    end

    context "after adding an attribute" do
      before do
        @attribute = double("attribute", name: "name", value: "value")
        allow(@attribute).to receive(:add_to)
        @proxy = double("proxy", result: "result")
        allow(@proxy).to receive(:set)

        allow(Factory::Attribute::Static).to receive(:new).and_return(@attribute)
        allow(Factory::Proxy::Build).to receive(:new).and_return(@proxy)

        @factory.add_attribute(:name, "value")
      end

      it "creates the right proxy using the build class when running" do
        expect(Factory::Proxy::Build)
          .to receive(:new)
          .with(@factory.build_class)
          .and_return(@proxy)

        @factory.run(Factory::Proxy::Build, {})
      end

      it "gets the value from the attribute when running" do
        expect(@attribute).to receive(:add_to).with(@proxy)
        @factory.run(Factory::Proxy::Build, {})
      end

      it "sets the value on the proxy when running" do
        expect(@attribute).to receive(:add_to).with(@proxy)

        @factory.run(Factory::Proxy::Build, {})
      end

      it "returns the value of the proxy when running" do
        expect(@proxy).to receive(:result).with(no_args).and_return("result")

        expect(@factory.run(Factory::Proxy::Build, {}))
          .to eq("result")
      end
    end

    context "when adding an association without a factory name" do
      before do
        @factory = Factory.new(:post)
        @name = :user
        @factory.association(@name)
        allow_any_instance_of(Post).to receive(:user=)
        allow(Factory).to receive(:create)
      end

      it "adds an attribute with the name of the association" do
        result = @factory.run(Factory::Proxy::AttributesFor, {})
        expect(result).to have_key(@name)
      end

      it "creates a block that builds the association" do
        expect(Factory).to receive(:create).with(@name, {})
        @factory.run(Factory::Proxy::Build, {})
      end
    end

    context "when adding an association with a factory name" do
      before do
        @factory = Factory.new(:post)
        @name = :author
        @factory_name = :user
        @factory.association(@name, factory: @factory_name)
        allow(Factory).to receive(:create)
      end

      it "adds the attribute with the name of the association" do
        result = @factory.run(Factory::Proxy::AttributesFor, {})
        expect(result).to have_key(@name)
      end

      it "creates a block that builds the associaiton" do
        expect(Factory).to receive(:create).with(@factory_name, {})
        @factory.run(Factory::Proxy::Build, {})
      end
    end

    context "when overriding generated attributes with a hash" do
      before do
        @attr = :name
        @value = "The price is right!"
        @hash = { @attr => @value }
      end

      it "returns the overriden value in the generated attributes" do
        result = @factory.run(Factory::Proxy::AttributesFor, @hash)

        expect(result[@attr]).to eq(@value)
      end

      it "does not call a lazy attribute block for an overriden attribute" do
        @factory.add_attribute(@attr) { flunk }

        @factory.run(Factory::Proxy::AttributesFor, @hash)
      end

      it "should override a symbol parameter with a string parameter" do
        @factory.add_attribute(@attr, "The price is wrong, Bob!")
        @hash = { @attr.to_s => @value }

        result = @factory.run(Factory::Proxy::AttributesFor, @hash)
        expect(result[@attr]).to eq(@value)
      end
    end

    context "when overriding an attribute with an alias" do
      before do
        @factory.add_attribute(:test, "original")
        Factory.alias(/(.*)_alias/, '\1')
        @result = @factory.run(
          Factory::Proxy::AttributesFor, test_alias: "new"
        )
      end

      it "it uses the passed in value for the alias" do
        expect(@result[:test_alias]).to eq("new")
      end

      it "discards the predefined value for the attribute" do
        expect(@result[:test]).to be_nil
      end
    end

    context "when defined with a custom class" do
      before do
        @class = User
        @factory = Factory.new(:author, class: @class)
      end

      it "uses the specified class as the build class" do
        expect(@factory.build_class).to eq(@class)
      end
    end

    context "when defined with a class instead of a name" do
      before do
        @class = ArgumentError
        @name = :argument_error
        @factory = Factory.new(@class)
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
        @factory = Factory.new(:author, class: :argument_error)
      end

      it "uses the specified class as the build class" do
        expect(@factory.build_class).to eq(@class)
      end
    end
  end

  context "a factory with a name ending in s" do
    before do
      @name = :business
      @class = Business
      @factory = Factory.new(@name)
    end

    it "has a factory name" do
      expect(@factory.factory_name).to eq(@name)
    end

    it "has a build class" do
      expect(@factory.build_class).to eq(@class)
    end
  end

  context "a factory with a string name" do
    before do
      @name = :user
      @factory = Factory.new(@name.to_s) {}
    end

    it "converts the string to a symbol" do
      expect(@factory.factory_name).to eq(@name)
    end
  end

  context "a factory defined with a string name" do
    before do
      Factory.factories = {}
      @name = :user
      @factory = Factory.define(@name.to_s) {}
    end

    it "converts the string to a symbol" do
      expect(@factory.factory_name).to eq(@name)
    end
  end

  context "Factory class" do
    before do
      @name = :user
      @factory = double("factory")
      @factory = Factory.factories[@name]
    end

    [:attributes_for, :build, :create].each do |method|
      it "raises ArgumentError when called with a non existing factory" do
        expect { Factory.send(method, :bogus) }.to raise_error(ArgumentError)
      end

      it "recognises either 'name' and :name for Factory.#{method}" do
        allow(@factory).to receive(:run)
        expect { Factory.send(method, @name.to_s) }.not_to raise_error
        expect { Factory.send(method, @name) }.not_to raise_error
      end
    end

    it "calls the create method from the top level Factory() method" do
      expect(@factory)
        .to receive(:run)
        .with(Factory::Proxy::Create, @attrs)

      Factory(@name, @attrs)
    end
  end
end
