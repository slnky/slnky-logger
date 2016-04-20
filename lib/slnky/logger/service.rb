module Slnky
  module Logger
    class Service < Slnky::Service::Base
      def initialize
        super
        log.local = false
        log.service = Slnky::Log::Service.new
        output = config.production? ? "log/slnky.log" : STDOUT
        @logger = ::Logger.new(output)
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "%-5s %s: %s\n" % [severity, datetime, msg]
        end
      end

      attr_writer :client
      def client
        @client ||= Slnky::Logger::Client.new
      end

      # subscribe 'slnky.service.test', :handle_test
      # you can also subscribe to heirarchies, this gets
      # all events under something.happened
      # subscribe 'something.happened.*', :other_handler
      subscribe '*', :handle_event

      def run
        transport.queue('logger', 'logs')
        transport.queue('logger', 'logs').subscribe do |raw|
          logline(parse(raw))
        end
      end

      def handle_test(name, data)
        name == 'slnky.service.test' && data.hello == 'world!'
      end

      def logline(line)
        level = line.level.to_sym
        @logger.send(level, "#{line.service}(*): #{line.message}")
      end

      def handle_event(name, data)
        out = data.to_h.inspect
        if out.length > 50
          out = out[0...200] + '...'
        end
        log.send :info, "#{name}: #{out}"
      end
    end
  end
end
