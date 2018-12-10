class Factory
  class Strategy
    class Create < Build
      def result
        @instance.save!
        @instance
      end
    end
  end
end
