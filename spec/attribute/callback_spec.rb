require "spec_helper"

RSpec.describe FactoryGirl::Attribute::Callback do
  before do
    @name = :after_create
    @block = proc { "block" }
    @attr = FactoryGirl::Attribute::Callback.new(@name, @block)
  end

  it "has a name" do
    expect(@attr.name).to eq(@name)
  end

  it "sets its callback on a proxy" do
    @proxy = double("proxy")
    expect(@proxy).to receive(:add_callback).with(@name, @block)
    @attr.add_to(@proxy)
  end

  it "converts names to symbols" do
    expect(FactoryGirl::Attribute::Callback.new("name", @block).name).to eq(:name)
  end
end
