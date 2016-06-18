require 'mongoid'
require 'mongoid/object'

module Xing
  class TradeUnit < Mongoid::Object::Worker
    class << self
      def logger
        @logger ||= Logger.new(STDOUT)
      end
    end

    def logger
      self.class.logger
    end

    def initialize(**option)
      @period = 10
      @count = option.delete(:number)
      @option = option
      @stock = Stock.new(name: @option[:name], shcode: @option[:shcode])
      @todo = :buy
    end

    def current_price
      @stock.cached_price
    end

    def buy
      return unless current_price < @option[:buy_price]
      buy_
      @option[:bought_price] = current_price
      @todo = :sell
    end

    def sell
      try_cover
      try_sell
    end

    def buy_
      logger.debug { "BUY:  #{current_price}" }
      @stock.trade(:buy, @option[:volume])
    end

    def sell_
      logger.debug { "SELL: #{current_price}" }
      @stock.trade(:sell, @option[:volume])
    end

    def try_sell
      return unless current_price > @option[:bought_price] + @option[:sell_price]
      sell_
      delete
    end

    def try_cover
      return unless current_price < @option[:bought_price] + @option[:cover_price]
      sell_
      delete
    end
  end
end
