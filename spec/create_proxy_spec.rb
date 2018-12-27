require "spec_helper"

RSpec.describe Factory::Proxy::Create do
  before do
    @class = Class.new
    @instance = double("built-instance")

    allow(@class).to receive(:new).and_return(@instance)
    allow(@instance).to receive(:attribute).and_return("value")
    allow(@instance).to receive(:attribute=)
    allow(@instance).to receive(:owner=)
    allow(@instance).to receive(:save!)

    @proxy = Factory::Proxy::Create.new(@class)
  end

  it "instanciates the class" do
    expect(@class).to have_received(:new)
  end

  context "when asked to associate with another factory" do
    before do
      @association = double("associated instance")
      @associated_factory = double("associated factory", run: @association)
      allow(Factory).to receive(:factory_by_name).and_return(@associated_factory)
      @overrides = { attr: "value" }
      @proxy.associate(:owner, :user, @overrides)
    end

    it "creates the associated instance" do
      expect(@associated_factory)
        .to have_received(:run)
        .with(Factory::Proxy::Create, @overrides)
    end

    it "sets the associated instance" do
      expect(@instance).to have_received(:owner=).with(@association)
    end
  end

  it "runs create when building the result" do
    association = double("associated instance")
    associated_factory = double("associated factory", run: association)
    allow(Factory).to receive(:factory_by_name).and_return(associated_factory)
    overrides = { attr: "value" }
    expect(@proxy.association(:user, overrides)).to eq(association)
    expect(associated_factory)
      .to have_received(:run)
      .with(Factory::Proxy::Create, overrides)
  end

  context "when asked for the result" do
    before do
      @build_spy = double("build_spy")
      @create_spy = double("create_spy")
      @proxy.add_callback(:after_build, proc { @build_spy.foo })
      @proxy.add_callback(:after_create, proc { @create_spy.foo })
      allow(@build_spy).to receive(:foo)
      allow(@create_spy).to receive(:foo)
      @result = @proxy.result
    end

    it "saves the instance" do
      expect(@instance).to have_received(:save!).with(no_args)
    end

    it "returns the built instance" do
      expect(@result).to eq(@instance)
    end

    it "runs both the build ans create callbacks" do
      expect(@build_spy).to have_received(:foo)
      expect(@create_spy).to have_received(:foo)
    end
  end

  context "when setting an attribute" do
    it "sets that value" do
      expect(@instance).to receive(:attribute=).with("value")
      @proxy.set(:attribute, "value")
    end
  end

  context "when getting an attribute" do
    before { @result = @proxy.get(:attribute) }

    it "asks the built instance for the value" do
      expect(@instance).to have_received(:attribute)
    end

    it "returns the value for that attribute" do
      expect(@result).to eq("value")
    end
  end
end
