module Slnky
  module Logger
    class Mock < Slnky::Logger::Client
      # unless there's something special you need to do in the initializer
      # use the one provided by the actual client object
      def initialize

      end

      def logline

      end
    end
  end
end
