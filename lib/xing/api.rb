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

      MULTIPLE_WHITE_CODE = %w(00000)
      def log_if_multiple_messages(retval)
        return unless retval['message'].size > 1
        return if retval['message'].all? { |msg| MULTIPLE_WHITE_CODE.include? msg[/^\[(.+?)\]/, 1] }
        logger.debug { "Multiple messages: #{retval['message'].join(', ')}" }
      end

      def log_if_unexpected_code(retval, white_code)
        message = retval['message'].last
        return if white_code.include? message[/^\[(.+?)\]/, 1]
        logger.warn { "Check: #{message}" }
      end

      def log_if_unexpected(retval, white_code)
        log_if_multiple_messages(retval)
        log_if_unexpected_code(retval, white_code)
      rescue NoMethodError
        logger.warn { "Check: #{retval}" }
      end

      TR_WHITE_CODE = %w(00000 00039 00040)

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
