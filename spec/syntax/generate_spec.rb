require "spec_helper"
require "my_factory_girl/syntax/generate"

RSpec.describe Factory::Syntax::Generate do
  context "a factory" do
    before do
      Factory.define :user do |f|
        f.first_name "Bill"
        f.last_name "Nye"
        f.email "bill@email.com"
      end
    end

    after do
      Factory.factories.clear
    end

    it "does not raise an error when generating an invalid instance" do
      expect { User.generate(first_name: nil) }.not_to raise_error
    end

    it "raises an error when forced to generate an invalid instance" do
      expect { User.generate!(first_name: nil) }
        .to raise_error(ActiveRecord::RecordInvalid)
    end

    %w(generate generate! spawn).each do |method|
      it "yields a generated instance when using #{method} with a block" do
        yielded = nil
        User.send(method) { |instance| yielded = instance }
        expect(yielded).to be_an_instance_of(User)
      end

      context "after generating an instance using #{method}" do
        before do
          @instance = User.send(method, last_name: "Rye")
        end

        it "uses the attributes from the factory" do
          expect(@instance.first_name).to eq("Bill")
        end

        it "uses the attributes passed to generate" do
          expect(@instance.last_name).to eq("Rye")
        end

        if method == "spawn"
          it "does not save the record" do
            expect(@instance).to be_a_new_record
          end
        else
          it "saves the record" do
            expect(@instance).not_to be_a_new_record
          end
        end
      end
    end
  end
end
