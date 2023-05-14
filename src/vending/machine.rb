#!/usr/bin/env ruby
# frozen_string_literal: true

module Vending
  class Machine
    attr_reader :stock, :monitor, :till

    def initialize(stock:, coins:)
      @stock = stock
      @till = Till.new(coins)
      @monitor = Monitor.new
    end

    def process
      monitor.greet

      order_loop
    end

    private

    def order_loop
      loop do
        item = item_choice

        # Handles user picking 0 to exit the loop
        if item.nil?
          monitor.exit_message
          break
        end

        # Handles user picking an item that is out of stock
        # We still want the user to be able to make the choice
        # like in a vending machine with physical buttons
        if out_of_stock?(item)
          handle_out_of_stock(item)
          next
        end

        request_coins(item)
        till.process_change(item[:price])

        give_out_item(item) if till.errors.empty?

        pause_loop
      end
    end

    def handle_out_of_stock(item)
      monitor.out_of_stock(item)
    end

    def item_choice
      monitor.print_choices(stock)
      choice = request_choice
      choice.zero? ? nil : stock[choice - 1]
    end

    def out_of_stock?(item)
      item[:qty].zero?
    end

    def give_out_item(item)
      item[:qty] -= 1

      monitor.print_item(item[:formatted_name])
    end

    def request_choice
      choice = nil

      while choice.nil?
        input = gets.chomp

        if numeric?(input) && (0..stock.size).include?(input.to_i)
          choice = input.to_i
        else
          monitor.request_choice(stock.size)
        end
      end

      choice
    end

    def request_coins(item)
      monitor.request_coins(item)
      till.new_transaction

      while till.transaction_total < item[:price]
        monitor.empty_prompt
        input = gets.chomp

        if till.accept_coin(input)
          monitor.inserted_so_far(till.transaction_total)
        else
          monitor.request_valid_coin(till.valid_coins)
        end
      end
    end

    def numeric?(value)
      value.to_i.to_s == value
    end

    def pause_loop
      # Pauses for better CLI user experience
      sleep 1 unless ENV.fetch('environment') == 'test'
    end
  end
end
