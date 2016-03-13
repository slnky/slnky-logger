require 'slnky'
require 'logger'

module Slnky
  module Service
    class Logger < Base
      def initialize(url, options={})
        super(url, options)
        @logfile = development? ? STDOUT : "log/slnky.log"
        @logger = ::Logger.new(@logfile)
        @logger.level = ::Logger::INFO
      end

      subscribe 'aws.ec2.terminated', :handle_terminated

      def run
        @channel.queue("service.logger.logs", durable: true).bind(@exchanges['logs']).subscribe do |raw|
          payload = parse(raw)
          level = payload.level.to_sym
          # puts "## %s [%6s] %s" % [Time.now, payload.level.upcase, payload.to_s]
          @logger.send(level, payload.to_s)
        end
      end

      def handle_terminated(name, data)
        @logger.send :info, data.inspect
      end
    end
  end
end
