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
        return if white_code.include? retval['message'][/^\[(.+?)\]/, 1]
        logger.warn { "Check: #{retval['message']}" }
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
