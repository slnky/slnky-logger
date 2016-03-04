require 'slnky'
require 'logger'

module Slnky
  module Service
    class Logger < Base
      def run
        logger = ::Logger.new("log/slnky.log")
        logger.level = ::Logger::INFO

        subscribe 'aws.ec2.terminated' do |message|
          name = message.name
          data = message.payload
          logger.send(:info, data.to_s)
        end

        @channel.queue("service.logger.logs", durable: true).bind(@exchanges['logs']).subscribe do |raw|
          payload = parse(raw)
          level = payload.level.to_sym
          # puts "## %s [%6s] %s" % [Time.now, payload.level.upcase, payload.to_s]
          logger.send(level, payload.to_s)
        end
      end
    end
  end
end
