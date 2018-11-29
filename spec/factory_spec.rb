require "spec_helper"

RSpec.describe Factory do
  context "a factory" do
    before do
      @factory_name = :user
      @factory = double("factory")
      allow(Factory).to receive(:new) { @factory }
    end

    it "creates a new factory" do
      Factory.define(@factory_name) { |f| }

      expect(Factory).to have_received(:new)
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

  context "defining a factory" do
    before do
      @factory_name = :user
      @factory = Factory.new(@factory_name)
    end

    it "has a factory name" do
      expect(@factory.factory_name).to eq(@factory_name)
    end

    it "does not allow attributes to be added with value and block" do
      expect { @factory.add_attribute(:name, "value") {} }
        .to raise_error(ArgumentError)
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
  end
end
