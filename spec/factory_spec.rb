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

  it "raises an error when defining a factory when using attribute setters" do
    expect { Factory.define(:user) { |f| f.name = "test" } }
      .to raise_error(Factory::AttributeDefinitionError)
  end

  context "defining a sequence" do
    before do
      @sequence = double("sequence")
      @name = :count
      allow(Factory::Sequence)
        .to receive(:new)
        .and_return(@sequence)
    end

    it "creates a new sequence" do
      expect(Factory::Sequence)
        .to receive(:new)
        .with(no_args)
        .and_return(@sequence)
      Factory.sequence(@name)
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
      @attr = :first_name
      @value = "Sugar"
      @factory.send(@attr, @value)

      expect(@factory.attributes_for[@attr]).to eq(@value)
    end

    it "does not allow attributes to be added with value and block" do
      expect { @factory.add_attribute(:name, "value") {} }
        .to raise_error(ArgumentError)
    end

    it "has a build class" do
      expect(@factory.build_class).to eq(@class)
    end

    it "guesses the build class from the factory name" do
      expect(@factory.build_class).to eq(@class)
    end

    it "allows attributes to be added with string as names" do
      @factory.add_attribute("name", "value")

      expect(@factory.attributes_for[:name]).to eq("value")
    end

    context "when adding an attribute with a value parameter" do
      before do
        @attr = :name
        @value = "Master Yoda"
        @factory.add_attribute(@attr, @value)
      end

      it "includes the value in the generated attributes hash" do
        expect(@factory.attributes_for[@attr]).to eq(@value)
      end
    end

    context "when adding an attribute with a block" do
      before do
        @attr = :name
        @attrs = {}
        @proxy = double("attribute-proxy")
        allow(Factory::AttributeProxy).to receive(:new).and_return(@proxy)
      end

      it "does not evaluate the block when the attribute is loaded" do
        @factory.add_attribute(@attr) { flunk }
      end

      it "evaluates the block when the attributes are generated" do
        called = false
        @factory.add_attribute(@attr) { called = true }
        @factory.attributes_for

        expect(called).to be true
      end

      it "uses the value of the block as the value of the attribute" do
        value = "Jacky Chan"
        @factory.add_attribute(@attr) { value }

        expect(@factory.attributes_for[@attr]).to eq(value)
      end

      it "builds an attribute proxy" do
        expect(Factory::AttributeProxy).to receive(:new)
          .with(@factory, @attr, :attributes_for, @attrs)
        @factory.add_attribute(@attr) {}
        @factory.attributes_for
      end

      it "yields an attribute proxy to the block" do
        yielded = nil
        @factory.add_attribute(@attr) { |y| yielded = y }
        @factory.attributes_for

        expect(yielded).to eq(@proxy)
      end

      context "when other attributes have previously been defined" do
        before do
          @attr = :unimportant
          @attrs = { one: "whatever", another: "soup" }
          @factory.add_attribute(:one, "whatever")
          @factory.add_attribute(:another) { "soup" }
          @factory.add_attribute(@attr) {}
        end

        it "provides previously set attributes" do
          expect(Factory::AttributeProxy)
            .to receive(:new)
            .with(@factory, @attr, :attributes_for, @attrs)
          @factory.attributes_for
        end
      end
    end

    context "when adding an association without a factory name" do
      before do
        @factory = Factory.new(:post)
        @name = :user
        @factory.association(@name)
        allow_any_instance_of(Post).to receive(:user=)
      end

      it "adds an attribute with the name of the association" do
        expect(@factory.attributes_for.key?(@name)).to be true
      end

      it "creates a block that builds the association" do
        expect(Factory).to receive(:build).with(@name, {})
        @factory.build
      end
    end

    context "when adding an association with a factory name" do
      before do
        @factory = Factory.new(:post)
        @name = :author
        @factory_name = :user
        @factory.association(@name, factory: @factory_name)
      end

      it "adds the attribute with the name of the association" do
        expect(@factory.attributes_for.key?(@name)).to be true
      end

      it "creates a block that builds the associaiton" do
        expect(Factory).to receive(:build).with(@factory_name, {})
        @factory.build
      end
    end

    context "when overriding generated attributes with a hash" do
      before do
        @attr = :name
        @value = "The price is right!"
        @hash = { @attr => @value }
      end

      it "returns the overriden value in the generated attributes" do
        @factory.add_attribute(@attr, "The price is wrong :(")

        expect(@factory.attributes_for(@hash)[@attr]).to eq(@value)
      end

      it "does not call a lazy attribute block for an overriden attribute" do
        @factory.add_attribute(@attr) { flunk }

        expect(@factory.attributes_for(@hash)[@attr]).to eq(@value)
      end

      it "should override a symbol parameter with a string parameter" do
        @factory.add_attribute(@attr, "The price is wrong, Bob!")
        @hash = { @attr.to_s => @value }

        expect(@factory.attributes_for(@hash)[@attr]).to eq(@value)
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

    context "with some attributes added" do
      before do
        @first_name = "Billy"
        @last_name = "The kid"
        @email = "billy@email.com"

        @factory.add_attribute(:first_name, @first_name)
        @factory.add_attribute(:last_name, @last_name)
        @factory.add_attribute(:email, @email)
      end

      context "when building an instance" do
        before do
          @instance = @factory.build
        end

        should_instanciate_class

        it "does not save the instance" do
          expect(@instance).to be_a_new_record
        end
      end

      context "when creating an instance" do
        before do
          @instance = @factory.create
        end

        should_instanciate_class

        it "saves the instance" do
          expect(@instance).not_to be_a_new_record
        end

        it "raises an ActiveRecord::RecordInvalid for invalid instances" do
          expect { @factory.create(first_name: nil) }
            .to raise_error(ActiveRecord::RecordInvalid)
        end
      end
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
      @attrs = { last_name: "Override" }
      @first_name = "Johnny"
      @last_name = "Winter"
      @class = User

      Factory.define(@name) do |u|
        u.first_name @first_name
        u.last_name { @last_name }
        u.email "jwinter@email.com"
      end

      @factory = Factory.factories[@name]
    end

    [:attributes_for, :build, :create].each do |method|
      it "delegates the method to the factory instance" do
        expect(@factory).to receive(method).with(@attrs)

        Factory.send(method, @name, @attrs)
      end

      it "raises ArgumentError when called with a non existing factory" do
        expect { Factory.send(method, :bogus) }.to raise_error(ArgumentError)
      end

      it "recognises either 'name' and :name for Factory.#{method}" do
        expect { Factory.send(method, @name.to_s) }.not_to raise_error
        expect { Factory.send(method, @name) }.not_to raise_error
      end
    end

    it "calls the create method from the top level Factory() method" do
      expect(@factory).to receive(:create).with(@attrs)

      Factory(@name, @attrs)
    end

    context "after defining a sequence" do
      before do
        @sequence = double("sequence")
        @name = :test
        @value = "1 2 5"
        allow(@sequence).to receive(:next).and_return(@value)
        allow(Factory::Sequence).to receive(:new).and_return(@sequence)

        Factory.sequence(@name) {}
      end

      it "calls next on the sequence when sent next" do
        expect(@sequence).to receive(:next)
        Factory.next(@name)
      end

      it "returns the value of the sequence" do
        expect(Factory.next(@name)).to eq(@value)
      end
    end
  end
end
