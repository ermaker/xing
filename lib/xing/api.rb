require 'httparty'
require 'multi_json'
require 'logger'

module Xing
  class API
    include HTTParty
    class << self
      attr_accessor :base

      def logger
        @logger ||= Logger.new(STDOUT)
      end

      def json(uri, **args)
        post(uri,
             body: MultiJson.dump(args),
             headers: { 'Content-Type' => 'application/json' }
            )
      end

      def account(idx)
        get(base + "/account/#{idx}")
      end

      def manipulate_shcode(args)
        case args[:shcode]
        when :leverage
          args[:shcode] = '122630'
        when :inverse
          args[:shcode] = '114800'
        end
      end

      def log_if_unexpected(retval, white_code)
        if retval['message'].size > 1
          logger.info { "Multiple messages: #{retval['message'].join(', ')}" }
        end
        message = retval['message'].last
        return if white_code.include? message[/^\[(.+?)\]/, 1]
        logger.warn { "Check: #{message}" }
      rescue NoMethodError
        logger.warn { "Check: #{retval}" }
      end

      TR_WHITE_CODE = [
        '00000'
      ]

      def tr(tr_name, **args)
        manipulate_shcode(args)
        json(base + "/tr/#{tr_name}", args).tap do |retval|
          log_if_unexpected(retval, TR_WHITE_CODE)
        end
      end
    end
    self.base = ENV['XING_URI'] + '/v0'
  end
end
