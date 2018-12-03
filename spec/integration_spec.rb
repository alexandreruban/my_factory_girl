require "spec_helper"

RSpec.describe "Integration test" do
  before do
    Factory.define :user do |f|
      f.first_name "Jimi"
      f.last_name "Hendrix"
      f.admin false
      f.email { |a| "#{a.first_name}.#{a.last_name}@example.com".downcase }
    end

    Factory.define "post" do |f|
      f.title "Test Post"
      f.author { |a| a.association(:user) }
    end

    Factory.define :admin, class: User do |f|
      f.first_name "Ben"
      f.last_name "Strein"
      f.admin true
      f.email { Factory.next(:email) }
    end

    Factory.sequence :email do |n|
      "somebody#{n}@example.com"
    end
  end

  context "a generated attribute hash" do
    before do
      @attrs = Factory.attributes_for(:user, first_name: "Bill")
    end

    it "assigns all attributes" do
      expect([:admin, :email, :first_name, :last_name])
        .to eq(@attrs.keys.sort)
    end

    it "overrides attributes" do
      expect(@attrs[:first_name]).to eq("Bill")
    end

    it "correctly assigns lazy, dependent atributes" do
      expect(@attrs[:email]).to eq("bill.hendrix@example.com")
    end
  end

  context "a created instance" do
    before do
      @instance = Factory.create("post")
    end

    it "should be saved" do
      expect(@instance).not_to be_a_new_record
    end

    it "assigns association" do
      expect(@instance.author).to be_a_kind_of(User)
    end

    it "saves association" do
      expect(@instance.author).not_to be_a_new_record
    end
  end

  context "an instance generated by a factory with a custom class name" do
    before do
      @instance = Factory.create(:admin)
    end

    it "uses the correct class name" do
      expect(@instance).to be_a_kind_of(User)
    end

    it "uses the correct factory" do
      expect(@instance.admin?).to be true
    end
  end

  context "an attribute generated by a sequence" do
    before do
      @email = Factory.attributes_for(:admin)[:email]
    end

    it "matches the correct format" do
      expect(@email).to match(/somebody\d@example.com/)
    end

    context "after the attribute has already generated once" do
      before do
        @another_email = Factory.attributes_for(:admin)[:email]
      end

      it "matches the correct format" do
        expect(@email).to match(/somebody\d@example.com/)
      end

      it "is not the same as the first generated value" do
        expect(@email).not_to eq(@another_email)
      end
    end
  end
end
