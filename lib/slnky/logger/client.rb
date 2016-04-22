module Slnky
  module Logger
    class Client < Slnky::Client::Base
      def initialize
        log.local = false
        log.service = Slnky::Log::Service.new
        output = config.production? ? "log/slnky.log" : STDOUT
        @logger = ::Logger.new(output)
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "%-5s %s: %s\n" % [severity, datetime, msg]
        end
      end

      def logline(line)
        @logger.send(line.level.to_sym, "#{line.service}(*): #{line.message}")
      end
    end
  end
end
