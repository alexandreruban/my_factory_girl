module FactoryGirl
  class Proxy
    class Create < Build
      def result
        run_callbacks(:after_build)
        @instance.save!
        run_callbacks(:after_create)
        @instance
      end
    end
  end
end
