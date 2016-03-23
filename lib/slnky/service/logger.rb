require 'slnky'
require 'logger'

module Slnky
  module Service
    class Logger < Base
      def initialize(url, options={})
        super(url, options)
        # not working in production and not sure why
        @logfile = development? ? STDOUT : "log/slnky.log"
        @logger = ::Logger.new(@logfile)
        @logger.level = ::Logger::INFO
        @logger.formatter = proc do |severity, datetime, progname, msg|
          "%-5s %s: %s\n" % [severity, datetime, msg]
        end
      end

      subscribe '*', :handle_event

      def run
        @channel.queue("service.logger.logs", durable: true).bind(@exchanges['logs']).subscribe do |raw|
          payload = parse(raw)
          logline(payload)
        end
      end

      def logline(log)
        level = log.level.to_sym
        @logger.send(level, "%s/%s: %s" % [log.ipaddress, log.service, log.message])
      end

      def handle_event(name, data)
        @logger.send :info, data.to_h.inspect
      end

      def handler(name, data)
        # for example test
        name == 'slnky.service.test' && data.hello == 'world!'
      end
    end
  end
end
