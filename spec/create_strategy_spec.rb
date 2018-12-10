require "spec_helper"

RSpec.describe Factory::Strategy::Create do
  context "with a class to build" do
    before do
      @class = Class.new
      @instance = double("built-instance")
      @association = double("associated-instance")

      allow(@class).to receive(:new).and_return(@instance)
      allow(Factory).to receive(:create).and_return(@association)
      allow(@instance).to receive(:attribute).and_return("value")
      allow(@instance).to receive(:attribute=)
      allow(@instance).to receive(:owner=)
      allow(@instance).to receive(:save!)
    end
  end

  context "the build strategy" do
    before do
      @strategy = Factory::Strategy::Create.new(@class)
    end

    context "when asked to associate with another factory" do
      it "creates the associated instance" do
        expect(Factory).to receive(:create).with(:user, {}).and_return(@association)
        @strategy.associate(:owner, :user, {})
      end

      it "sets the associated instance" do
        expect(@instance).to receive(:owner=).with(@association)
        @strategy.associate(:owner, :user, {})
      end
    end

    context "when asked for the result" do
      it "saves the instance" do
        expect(@instance).to receive(:save).with(no_args)
        @result = @strategy.result
      end
    end
  end
end
