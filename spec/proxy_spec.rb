require "spec_helper"

RSpec.describe FactoryGirl::Proxy do
  context "a proxy" do
    before do
      @proxy = FactoryGirl::Proxy.new(Class.new)
    end

    it "does nothing when asked to set an attribute to a value" do
      expect(@proxy.set(:name, "a name")).to be_nil
    end

    it "returns nil when asked for an attribute" do
      expect(@proxy.get(:name)).to be_nil
    end

    it "calls get for a missing method" do
      expect(@proxy).to receive(:get).with(:name).and_return("A name")
      expect(@proxy.name).to eq("A name")
    end

    it "does nothing when asked to associate with another factory" do
      expect(@proxy.associate(:owner, :user, {})).to be_nil
    end

    it "raises an error when asked for the result" do
      expect { @proxy.result }.to raise_error(NotImplementedError)
    end

    context "when adding callbacks" do
      before do
        @first_block = proc { "block 1" }
        @second_block = proc { "block 2" }
      end

      it "adds a callback" do
        @proxy.add_callback(:after_create, @first_block)
        expect(@proxy.callbacks[:after_create]).to eq([@first_block])
      end

      it "can have multiple callbacks of the same name" do
        @proxy.add_callback(:after_create, @first_block)
        @proxy.add_callback(:after_create, @second_block)
        expect(@proxy.callbacks[:after_create])
          .to eq([@first_block, @second_block])
      end

      it "can have multiple callbacks of different name" do
        @proxy.add_callback(:after_create, @first_block)
        @proxy.add_callback(:after_build, @second_block)

        expect(@proxy.callbacks[:after_create]).to eq([@first_block])
        expect(@proxy.callbacks[:after_build]).to eq([@second_block])
      end
    end

    context "when running callbacks" do
      before do
        @first_spy = double("first spy")
        @second_spy = double("second spy")
        allow(@first_spy).to receive(:foo)
        allow(@second_spy).to receive(:foo)
      end

      it "runs all callbacks with a given name" do
        @proxy.add_callback(:after_create, proc { @first_spy.foo })
        @proxy.add_callback(:after_create, proc { @second_spy.foo })
        @proxy.run_callbacks(:after_create)

        expect(@first_spy).to have_received(:foo)
        expect(@second_spy).to have_received(:foo)
      end

      it "only runs callback with a given name" do
        @proxy.add_callback(:after_create, proc { @first_spy.foo })
        @proxy.add_callback(:after_build, proc { @second_spy.foo })
        @proxy.run_callbacks(:after_create)

        expect(@first_spy).to have_received(:foo)
        expect(@second_spy).not_to have_received(:foo)
      end

      it "passes in the instance if the block takes an argument" do
        @proxy.instance_variable_set("@instance", @first_spy)
        @proxy.add_callback(:after_create, proc { |spy| spy.foo })
        @proxy.run_callbacks(:after_create)

        expect(@first_spy).to have_received(:foo)
      end
    end
  end
end
