require "spec_helper"

RSpec.describe FactoryGirl::Proxy::Build do
  before do
    @class = Class.new
    @instance = double("build-instance")

    allow(@class).to receive(:new).and_return(@instance)
    allow(@instance).to receive(:attribute).and_return("value")
    allow(@instance).to receive(:attribute=)
    allow(@instance).to receive(:owner=)

    @proxy = FactoryGirl::Proxy::Build.new(@class)
  end

  it "shoud instanciate the class" do
    expect(@class).to have_received(:new)
  end

  context "when asked to associate with another factory" do
    before do
      @association = double("associated instance")
      @associated_factory = double("associated factory", run: @association)
      @overrides = { attr: "value" }
      allow(FactoryGirl).to receive(:factory_by_name).and_return(@associated_factory)
      @proxy.associate(:owner, :user, @overrides)
    end

    it "creates the associated instance" do
      expect(@associated_factory)
        .to have_received(:run)
        .with(FactoryGirl::Proxy::Create, @overrides)
    end

    it "sets the associated instance" do
      expect(@instance)
        .to have_received(:owner=)
        .with(@association)
    end
  end

  it "runs create when building an association" do
    association = double("associated instance")
    associated_factory = double("associated factory", run: association)
    allow(FactoryGirl).to receive(:factory_by_name).and_return(associated_factory)
    overrides = { attr: "value" }
    expect(@proxy.association(:user, overrides)).to eq(association)
    expect(associated_factory)
      .to have_received(:run)
      .with(FactoryGirl::Proxy::Create, overrides)
  end

  it "returns the built instance when asked for the result" do
    expect(@proxy.result).to eq(@instance)
  end

  it "runs the after build callback when retrieving the result" do
    spy = double("spy")
    @proxy.add_callback(:after_build, proc { spy.foo })
    expect(spy).to receive(:foo)

    @proxy.result
  end

  context "when getting an attribute" do
    before { @result = @proxy.get(:attribute) }

    it "asks the build class for the value" do
      expect(@instance).to have_received(:attribute)
    end

    it "returns the value for that attribute" do
      expect(@result).to eq("value")
    end
  end

  context "when setting an attribute" do
    it "sets that value" do
      @proxy.set(:attribute, "value")
      expect(@instance).to have_received(:attribute=).with("value")
    end
  end
end
