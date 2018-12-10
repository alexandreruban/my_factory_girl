require "spec_helper"

RSpec.describe Factory::Strategy::Build do
  context "with a class to build" do
    before do
      @class = Class.new
      @instance = double("build-instance")
      @association = double("associated-instance")

      allow(@class).to receive(:new).and_return(@instance)
      allow(@instance).to receive(:attribute).and_return("value")
      allow(Factory).to receive(:create).and_return(@association)
      allow(@instance).to receive(:attribute=)
      allow(@instance).to receive(:owner=)
    end

    context "the build strategy" do
      before do
        @strategy = Factory::Strategy::Build.new(@class)
      end

      it "returns the build instance when asked for the result" do
        expect(@strategy.result).to eq(@instance)
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

      context "when getting an attribute" do
        before do
          @result = @strategy.get(:attribute)
        end

        it "returns the value for that attribute" do
          expect(@result).to eq("value")
        end
      end

      context "when setting an attribute" do
        it "sets that value" do
          expect(@instance).to receive(:attribute=).with("value")
          @strategy.set(:attribute, "value")
        end
      end
    end
  end
end
