require "spec_helper"

RSpec.describe Factory::Proxy::Stub do
  before do
    @class = double("class")
    @instance = double("instance")
    allow(@class).to receive(:new).and_return(@instance)
    allow(@instance).to receive(:id).and_return(42)
    allow(@instance).to receive(:id=)
    allow(@instance).to receive(:reload) { @instance.connection.reload }

    @stub = Factory::Proxy::Stub.new(@class)
  end

  it "is not a new record" do
    expect(@stub.result).not_to be_a_new_record
  end

  it "is not able to connect to the database" do
    expect { @stub.result.reload }.to raise_error(RuntimeError)
  end

  context "when a user factory exists" do
    before do
      @user = double("user")
      @associated_factory = double("associated factory")
      allow(Factory)
        .to receive(:factory_by_name)
        .and_return(@associated_factory)
    end

    context "when asked to associate with another factory" do
      before do
        allow(@instance).to receive(:owner).and_return(@user)
        allow(@stub).to receive(:set).with(:owner, @user)
        allow(@associated_factory)
          .to receive(:run)
          .with(Factory::Proxy::Stub, {})
          .and_return(@user)

        @stub.associate(:owner, :user, {})
      end

      it "sets a value for the association" do
        expect(Factory).not_to receive(:create)
        expect(@stub.association(:user)).to eq(@user)
      end

      it "returns the actual instance when asked for the result" do
        expect(@stub.result.owner).to eq(@user)
      end
    end
  end

  context "when asked for the result" do
    it "returns the actual instance when asked for the result" do
      expect(@stub.result).to eq(@instance)
    end

    it "runs the after_stub callback when asked for the result" do
      @spy = double("spy")
      expect(@spy).to receive(:foo)
      @stub.add_callback(:after_stub, proc { @spy.foo })

      @stub.result
    end
  end

  context "with an existing attribute" do
    before do
      @value = "value"
      allow(@instance).to receive(:attribute=).with(@value)
      allow(@instance).to receive(:attribute).and_return(@value)

      @stub.set(:attribute, @value)
    end

    it "returns the resulting object" do
      expect(@stub.attribute).to eq(@value)
    end

    it "returns that value when asked for the attribute" do
      expect(@stub.get(:attribute)).to eq(@value)
    end
  end
end
