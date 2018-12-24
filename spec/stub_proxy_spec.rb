require "spec_helper"

RSpec.describe Factory::Proxy::Stub do
  context "the stub proxy" do
    before do
      @proxy = Factory::Proxy::Stub.new(@class)
    end

    context "when asked to associate with another factory" do
      before do
        allow(Factory).to receive(:create)
        @proxy.associate(:owner, :user, {})
      end

      it "does not set a value for the association" do
        expect(@proxy.owner).to be_nil
      end
    end

    it "returns nil when building an association" do
      expect(@proxy.association(:user)).to be_nil
    end

    it "does not call Factory.create when building an association" do
      expect(Factory).not_to receive(:create)
      @proxy.association(:user)
    end

    it "returns nil when building an association" do
      @proxy.set(:association, "x")
      expect(@proxy.association(:user)).to be_nil
    end

    it "returns a mock object when asked for the result" do
      expect(@proxy).to be_a_kind_of(Object)
    end

    context "after setting an attribute" do
      before do
        @proxy.set(:attribute, "value")
      end

      it "adds a stub to the resulting object" do
        expect(@proxy.attribute).to eq("value")
      end

      it "returns that value when asked for that attribute" do
        expect(@proxy.get(:attribute)).to eq("value")
      end
    end
  end
end
