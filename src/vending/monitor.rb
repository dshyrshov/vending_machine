# frozen_string_literal: true

module Vending
  # Prints out information for users
  class Monitor
    def greet
      puts 'Welcome to Vendico™'
      puts
    end

    def request_choice(stock_size)
      puts "Please enter a number from 0 to #{stock_size}"
      empty_prompt
    end

    def exit_message
      puts 'Thank you for using Vendico™'
    end

    def request_coins(item)
      puts "#{item[:formatted_name]} is #{CurrencyFormatter.format item[:price]}. Please insert coins:"
    end

    def print_choices(stock)
      puts 'Please pick a beverage:'
      stock.each_with_index do |item, index|
        puts "#{index + 1}. #{item[:formatted_name]}: #{CurrencyFormatter.format item[:price]}"
      end
      puts "0. I'll pass"
      empty_prompt
    end

    def inserted_so_far(inserted)
      puts "Inserted so far: #{CurrencyFormatter.format inserted}"
    end

    def request_valid_coin(valid_coins)
      puts "Invalid coin, please insert one of #{valid_coins.join(', ')}"
    end

    def empty_prompt
      print '> '
    end

    def print_change(coins)
      puts 'Please take your change:'

      print_formatted_change(coins)
    end

    def print_change_error(coins)
      puts 'We couldn\'t find change for you. Here are your coins:'

      print_formatted_change(coins)
    end

    def print_formatted_change(coins)
      formatted_change = coins.map do |coin_value, amount|
        "#{CurrencyFormatter.format coin_value} x #{amount}"
      end

      puts formatted_change.join(', ')
    end

    def print_item(name)
      puts "Your item: #{name}. Enjoy!"
    end

    def out_of_stock(item)
      puts "Sorry, we are temporarily out of #{item[:formatted_name]}! Please pick another item."
    end
  end
end
