require "spec_helper"
require "my_factory_girl/syntax/make"

RSpec.describe FactoryGirl::Syntax::Make do
  before do
    Factory.define :user do |f|
      f.first_name "Bill"
      f.last_name "Nye"
      f.email "email@email.com"
    end
  end

  after { FactoryGirl.factories.clear }

  context "after making an instance" do
    before do
      @instance = User.make(last_name: "Rye")
    end

    it "uses the attributes from the factory" do
      expect(@instance.first_name).to eq("Bill")
    end

    it "uses the attributes passed to make" do
      expect(@instance.last_name).to eq("Rye")
    end

    it "saves the record" do
      expect(@instance).not_to be_a_new_record
    end
  end
end
