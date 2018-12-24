class Factory
  class Proxy
    class Create < Build
      def result
        @instance.save!
        @instance
      end
    end
  end
end
