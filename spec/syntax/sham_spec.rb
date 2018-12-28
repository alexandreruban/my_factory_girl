require "spec_helper"
require "my_factory_girl/syntax/sham"

RSpec.describe FactoryGirl::Syntax::Sham do
  before do
    Sham.name { "Name" }
    Sham.email { "somebody#{rand(5)}@email.com" }
    Sham.user("foo") { |c| "User-#{c}" }

    Factory.define :user do |f|
      f.first_name { Sham.name }
      f.last_name { Sham.name }
      f.email { Sham.email }
      f.username { Sham.user }
    end
  end

  after do
    FactoryGirl.factories.clear
    FactoryGirl.sequences.clear
  end

  context "after making up an instance" do
    before do
      @instance = Factory(:user, last_name: "Rye")
    end

    it "supports a sham called name" do
      expect(@instance.first_name).to eq("Name")
    end

    it "uses the sham for the email" do
      expect(@instance.email).to match(/somebody\d+@email.com/)
    end

    it "supports Sham with starting values" do
      expect(@instance.username).to eq("User-foo")
    end
  end
end
