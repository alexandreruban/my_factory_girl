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

    context "when adding an attribute with a value parameter" do
      before do
        @attr = :name
        @value = "Master Yoda"
        @factory.add_attribute(@name, @value)
      end

      it "includes the value in the generated attributes hash" do
        expect(@factory.attributes_for[@name]).to eq(@value)
      end
    end

    context "when adding an attribute with a block" do
      before do
        @attr = :name
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
      end

      context "when creating an instance" do
        before do
          User.destroy_all
          @instance = @factory.create
        end

        should_instanciate_class

        it "saves the instance" do
          expect(User.count).to eq 1
        end

        it "raises an ActiveRecord::RecordInvalid for invalid instances" do
          expect { @factory.create(first_name: nil) }
            .to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
