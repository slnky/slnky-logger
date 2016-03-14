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
      end

      subscribe 'aws.ec2.terminated', :handle_terminated

      def run
        @channel.queue("service.logger.logs", durable: true).bind(@exchanges['logs']).subscribe do |raw|
          payload = parse(raw)
          level = payload.level.to_sym
          @logger.send(level, payload.to_s)
        end
      end

      def handle_terminated(name, data)
        @logger.send :info, data.inspect
      end

      def handler(name, data)
        # for example test
        name == 'slnky.service.test' && data.hello == 'world!'
      end
    end
  end
end
