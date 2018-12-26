require "spec_helper"

RSpec.describe Factory::Attribute::Association do
  before do
    @name = :author
    @factory = :user
    @overrides = { first_name: "John" }
    @attr = Factory::Attribute::Association.new(@name, @factory, @overrides)
  end

  it "has a factory" do
    expect(@attr.factory).to eq(@factory)
  end
end
