require "spec_helper"
require "my_factory_girl/syntax/blueprint"

RSpec.describe Factory::Syntax::Blueprint do
  context "a blueprint" do
    before do
      Factory.sequence(:email) { |n| "somebody#{n}@email.com"}
      User.blueprint do
        first_name { "Bill" }
        last_name { "Nye" }
        email { Factory.next(:email) }
      end
    end

    after do
      Factory.factories.clear
      Factory.sequences.clear
    end

    context "after making an instance" do
      before do
        @instance = Factory(:user, last_name: "Rye")
      end

      it "uses the attributes from the blueprint" do
        expect(@instance.first_name).to eq("Bill")
      end

      it "evaluates attribute blocks for each instance" do
        expect(@instance.email).to match(/somebody\d+@email.com/)
        expect(@instance.email).not_to eq(Factory(:user).email)
      end
    end
  end
 end
