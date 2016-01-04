require 'httparty'
require 'multi_json'

module Xing
  class API
    include HTTParty
    class << self
      attr_accessor :base

      def json(uri, **args)
        post(uri,
             body: MultiJson.dump(args),
             headers: { 'Content-Type' => 'application/json' }
            )
      end

      def account(idx)
        get(base + "/account/#{idx}")
      end

      def tr(tr_name, **args)
        case args[:shcode]
        when :leverage
          args[:shcode] = '122630'
        when :inverse
          args[:shcode] = '114800'
        end
        json(base + "/tr/#{tr_name}", args)
      end
    end
    self.base = ENV['XING_URI'] + '/v0'
  end
end
