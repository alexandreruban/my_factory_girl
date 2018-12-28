require "spec_helper"

RSpec.describe FactoryGirl::Attribute::Association do
  before do
    @name = :author
    @factory = :user
    @overrides = { first_name: "John" }
    @attr = FactoryGirl::Attribute::Association.new(@name, @factory, @overrides)
  end

  it "has a factory" do
    expect(@attr.factory).to eq(@factory)
  end
end
