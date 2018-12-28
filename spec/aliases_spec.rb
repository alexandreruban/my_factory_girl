require "spec_helper"

RSpec.describe "Aliases" do
  it "includes an attribute as an alias for itself by default" do
    expect(FactoryGirl.aliases_for(:test)).to include(:test)
  end

  it "includes the root of a foreign key as an alias by default" do
    expect(FactoryGirl.aliases_for(:test_id)).to include(:test)
  end

  it "includes an attribute's foreign key as an alias by default" do
    expect(FactoryGirl.aliases_for(:test)).to include(:test_id)
  end

  it "should not include an attribute as an alias when it starts with underscore" do
    expect(FactoryGirl.aliases_for(:_id)).not_to include(:id)
  end

  context "after adding an alias" do
    before do
      Factory.alias(/(.*)_suffix/, '\1')
    end

    it "returns the alias in the aliases list" do
      expect(FactoryGirl.aliases_for(:test_suffix)).to include(:test)
    end
  end
end
