module Vending
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

    def give_out_change
      puts 'Please take your change:'

      str_arr = coins.map do |coin_value, amount|
        till[coin_value] -= amount
        "#{CurrencyFormatter.format coin_value} x #{amount}"
      end

      puts str_arr.join(', ')
    end
  end
end
