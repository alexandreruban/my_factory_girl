require "spec_helper"

RSpec.describe "Integration test" do
  before do
    FactoryGirl.define do
      factory :user do
        first_name "Jimi"
        last_name "Hendrix"
        email { |a| "#{a.first_name}.#{a.last_name}@example.com".downcase }
        admin false
      end

      factory :guest, parent: :user do
        last_name "Anonymous"
        username "GuestUser"
      end

      factory Post, default_strategy: :attributes_for do
        title "Test Post"
        association :author, factory: :user
      end

      factory :admin, class: User do
        first_name "Ben"
        last_name "Strein"
        email { Factory.next(:email) }
        sequence(:username) { |n| "username#{n}" }
        admin true
      end

      factory :user_with_callbacks, parent: :user do
        after_stub { |u| u.first_name = "Stuby" }
        after_build { |u| u.first_name = "Buildy" }
        after_create { |u| u.last_name = "Createy" }
      end

      factory :user_with_inherited_callbacks, parent: :user_with_callbacks do
        after_stub { |u| u.last_name = "Double-Stuby" }
      end

      factory :business do
        name "Supplier of Awsome"
        association :owner, factory: :user
      end

      factory :sequence_abuser, class: User do
        first_name { Factory.sequence(:email) }
      end

      sequence(:email) { |n| "somebody#{n}@example.com" }
    end
  end

  after { FactoryGirl.factories.clear }

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

  context "a build instance" do
    before do
      @instance = Factory.build(:post)
    end

    it "is not saved" do
      expect(@instance).to be_a_new_record
    end

    it "assigns associations" do
      expect(@instance.author).to be_a_kind_of(User)
    end

    it "saves the associations" do
      expect(@instance.author).not_to be_a_new_record
    end

    it "it does not assign both an association and its foreign key" do
      expect(Factory.build(:post, author_id: 1).author_id).to eq(1)
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

  context "a generated stub instance" do
    before do
      @stub = Factory.stub(:user, first_name: "Billy")
    end

    it "assigns all attributes" do
      [:admin, :email, :first_name, :last_name].each do |attr|
        expect(@stub.send(attr)).not_to be_nil
      end
    end

    it "correctly assigns lazy, dependent attributes" do
      expect(@stub.email).to eq("billy.hendrix@example.com")
    end

    it "overrides attributes" do
      expect(@stub.first_name).to eq("Billy")
    end

    it "assigns associations" do
      expect(Factory.stub(:post).author).not_to be_nil
    end

    it "has an id" do
      expect(@stub.id).to be > 0
    end

    it "has an unique id" do
      @other_stub = Factory.stub(:user)
      expect(@stub.id).not_to eq(@other_stub.id)
    end

    it "is not considered as a new record" do
      expect(@stub).not_to be_a_new_record
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

  context "an instance generated by a factory that inherits from another factory" do
    before do
      @instance = Factory.create(:guest)
    end

    it "has the same class as the parent factory" do
      expect(@instance).to be_an_instance_of(User)
    end

    it "has the attributes of the parent" do
      expect(@instance.first_name).to eq("Jimi")
    end

    it "has the attributes defined in the factory itself" do
      expect(@instance.username).to eq("GuestUser")
    end

    it "has the attributes that have been overriden" do
      expect(@instance.last_name).to eq("Anonymous")
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

  context "an attribute generated by an inline sequence" do
    before do
      @username = Factory.attributes_for(:admin)[:username]
    end

    it "matches the correct format" do
      expect(@username).to match(/^username\d+$/)
    end

    context "after the attribute has already been generated once" do
      before do
        @another_username = Factory.attributes_for(:admin)[:username]
      end

      it "matches the correct format" do
        expect(@username).to match(/^username\d+$/)
      end

      it "is not the same as the first generated value" do
        expect(@username).not_to eq(@another_username)
      end
    end
  end

  context "a factory with a specified default strategy" do
    it "generates instances according to the strategy" do
      expect(Factory(:post)).to be_an_instance_of(Hash)
    end
  end

  context "an instance with callbacks" do
    it "runs the after_stub callback when stubbing" do
      @user = Factory.stub(:user_with_callbacks)
      expect(@user.first_name).to eq("Stuby")
    end

    it "runs the after build callback when building" do
      @user = Factory.build(:user_with_callbacks)
      expect(@user.first_name).to eq("Buildy")
    end

    it "runs both the after_build and after_create callbacks when creating" do
      @user = Factory.create(:user_with_callbacks)
      expect(@user.first_name).to eq("Buildy")
      expect(@user.last_name).to eq("Createy")
    end

    it "runs both the after_stub callback on the factory and the inherited callback" do
      @user = Factory.stub(:user_with_inherited_callbacks)
      expect(@user.first_name).to eq("Stuby")
      expect(@user.last_name).to eq("Double-Stuby")
    end
  end

  it "raises FactoryGirl::SequenceAbuseError" do
    expect { Factory(:sequence_abuser) }
      .to raise_error(FactoryGirl::SequenceAbuseError)
  end
end
