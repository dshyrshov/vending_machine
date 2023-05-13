#!/usr/bin/env ruby
# frozen_string_literal: true

module Vending
  class Machine
    attr_reader :stock, :till, :monitor

    def initialize(stock:, till:)
      @stock = stock
      @till = till
      @monitor = Monitor.new
    end

    def process
      monitor.greet

      loop do
        monitor.print_choices(stock)

        choice = request_choice
        if choice.zero?
          monitor.exit_message
          exit(true)
        end

        item = stock[choice - 1]

        monitor.request_coins(item)
        inserted = get_coins(item[:price])

        if (inserted - item[:price]).positive?
          coin_change = process_coin_change(inserted, item[:price])

          give_out_coins(coin_change)
        end

        give_out_item(item)

        sleep 2
      end
    end

    private

    def process_coin_change(inserted, item_price)
      CoinChanger.new(inserted - item_price, till).process
    rescue CoinChanger::InsufficientCoins
      give_out_coins(@inserted_coins)
    end

    def give_out_item(item)
      puts "Your item: #{item[:formatted_name]}. Enjoy!"
    end

    def give_out_coins(coins)
      puts 'Vending machine returns coins:'

      str_arr = coins.map do |coin_value, amount|
        till[coin_value] -= amount
        "#{CurrencyFormatter.format coin_value} x #{amount}"
      end

      puts str_arr.join(', ')
    end

    def request_choice
      choice = nil
      while choice.nil?
        input = gets.chomp
        if input.to_i.to_s == input && (0..stock.size).include?(input.to_i)
          choice = input.to_i
        else
          monitor.request_choice(stock.size)
        end
      end

      choice
    end

    def get_coins(amount)
      @inserted_coins = {}
      inserted = 0
      while inserted < amount
        monitor.empty_prompt
        input = gets.chomp

        if input.to_i.to_s == input && till.keys.include?(input.to_i)
          inserted += input.to_i
          till[input.to_i] += 1
          @inserted_coins[input.to_i] ||= 0
          @inserted_coins[input.to_i] += 1
          monitor.inserted_so_far(inserted)
        else
          monitor.request_valid_coin(till.keys)
        end
      end

      inserted
    end
  end
end
