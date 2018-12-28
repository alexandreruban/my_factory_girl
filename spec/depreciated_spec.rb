require "spec_helper"

describe "accessing on an undefined method on Factory that is defined on FG" do
  let(:method_name) { :aliases }
  let(:return_value) { "value" }
  let(:args) { [1, 2, 3] }

  before do
    allow($stderr).to receive(:puts)
    allow(FactoryGirl).to receive(:method_name).and_return(return_value)

    @result = Factory.send(:method_name, *args)
  end

  it "prints a depreciation warning" do
    expect($stderr).to have_received(:puts)
  end

  it "invoked that method on FactoryGirl" do
    expect(FactoryGirl).to have_received(:method_name).with(*args)
  end

  it "returns the value from the method on FactoryGirl" do
    expect(@result).to eq(return_value)
  end
end

describe "accessing an undefined method on Factory that in not defined on FG" do
  let(:method_name) { :magic_beans }

  before do
    allow($stderr).to receive(:puts) { raise "Don't print a depreciation warning" }

    begin
      Factory.send(method_name)
    rescue Exception => @raised
    end
  end

  it "raises a NoMethodError" do
    expect(@raised).to be_an_instance_of(NoMethodError)
  end
end

describe "accessing an undefined constant on Factory that is defined on FG" do
  before do
    @result = Factory::Attribute
  end

  it "returns that constant on FactoryGirl" do
    expect(@result).to eq(FactoryGirl::Attribute)
  end
end

describe "accessing an undefined constant on Factory that is not defined on FG" do
  it "raises a NameError" do
    begin
      Factory::BOGUS
    rescue Exception => exception
    end

    expect(exception).to be_an_instance_of(NameError)
    expect(exception.message).to include("Factory::BOGUS")
  end
end
