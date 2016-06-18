require 'time'
require 'logger'

module Xing
  class Stock
    class << self
      def logger
        @logger ||= Logger.new(STDOUT)
      end

      attr_accessor :cached_price
    end

    class Cache < Hash
      def initialize(*)
        super
        self.default_proc = proc { |_, shcode| { time: Time.at(0) } }
      end

      def update_and_fetch(shcode)
        self[shcode] = { time: Time.now, value: yield } \
          if Time.now - self[shcode][:time] > 3
        self[shcode][:value]
      end
    end

    self.cached_price = Cache.new

    def logger
      self.class.logger
    end

    def initialize(name: nil, shcode: nil)
      @shcode = shcode
      @name = name
    end

    def t1901_delay
      5
    end

    def cached_price
      self.class.cached_price.update_and_fetch(@shcode) do
        t1901.tap { |price| logger.debug { "GET Price[#{@name}]: #{price}" } }
      end
    end

    def t1901 # rubocop:disable Metrics/MethodLength
      loop do
        retval = Xing::API.tr(:t1901, shcode: @shcode)
        begin
          price = retval['response'].last['price'].to_i
          return price unless price.zero?
          logger.debug { "Price is zero. retval: #{retval}" }
        rescue NoMethodError
        end
        logger.debug { "Retry: #{retval['message']&.join(' ,') || retval}" }
        sleep t1901_delay
      end
    end

    def trade(sell_or_buy, qty)
      logger.debug { 'Try trade.' }
      retval = Xing::API.tr(
        :CSPAT00600,
        account: ENV['ACCOUNT'],
        pass: ENV['ACCOUNT_PASS'],
        shcode: @shcode, qty: qty, sell_or_buy: sell_or_buy)
      logger.debug { "retval: #{retval}" }
      logger.info { "Trade message: #{retval['message'].join(', ')}" }
    end
  end
end
