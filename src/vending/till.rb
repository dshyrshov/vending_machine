# frozen_string_literal: true

module Vending
  class Till
    attr_reader :coins, :transaction, :transaction_total, :errors, :monitor

    def initialize(coins)
      @coins = coins
      @errors = []
      @monitor = Monitor.new
    end

    def accept_coin(coin_value)
      return false unless valid_coin?(coin_value)

      coin = coin_value.to_i

      coins[coin] += 1
      transaction[coin] += 1
      @transaction_total += coin
    end

    def new_transaction
      @errors = []
      @transaction_total = 0
      @transaction = coins.transform_values { |_v| 0 }
    end

    def valid_coins
      coins.keys
    end

    def process_change(item_price)
      return unless (transaction_total - item_price).positive?

      change = CoinChanger.new(transaction_total - item_price, coins).process
      return_change(change)
    rescue CoinChanger::InsufficientCoins
      errors.push(:insufficient_coins)
      return_change(transaction)
    end

    def return_change(change)
      change.each { |coin_value, amount| coins[coin_value] -= amount }

      errors.empty? ? monitor.print_change(change) : monitor.print_change_error(change)
    end

    private

    def valid_coin?(coin_value)
      numeric?(coin_value) && coins.keys.include?(coin_value.to_i)
    end

    def numeric?(value)
      value.to_i.to_s == value
    end
  end
end
