#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'yaml'
require_relative 'coin_changer'

init_values = YAML.load_file('./init_values.yml')

def print_greeting(stock)
end

class VendingMachine
  attr_reader :stock, :till

  def initialize(stock, till)
    @stock = stock
    @till = till
  end

  def process
    greet
    user_observes_the_machine
    print_choices

    choice = get_choice
    item = stock.values[choice - 1]

    puts "#{item['formatted_name']} is #{CurrencyFormatter.format item["price"]}. Please insert coins:"

    inserted = get_coins(item["price"])

    if (inserted - item["price"]).positive?
      coin_change = process_coin_change(inserted, item["price"])

      require 'pry'; binding.pry
      give_out_coins(coin_change)

    end

    give_out_item(item)
  end

  private

  def process_coin_change(inserted, item_price)
    CoinChanger.new(inserted - item_price, till).process
  rescue CoinChanger::InsufficientCoins
    give_out_coins(@inserted_coins)
  end

  def give_out_item(item)
    puts "Your item: #{item}"
  end

  def give_out_coins(coins)
    puts "Vending machine returns coins:"

    coins.map do |coin_value, amount|
      till[coin_value] -= amount
      "#{CurrencyFormatter.format coin_value} x #{amount}"
    end.join(", ")
  end

  def user_observes_the_machine
    puts "You see a vending machine. It has:"

    stock.each do |item|
      details = item[1]
      if details["qty"] > 0
        puts "#{details["qty"]} bottles of #{details["formatted_name"]}"
      else
        puts "#{details["formatted_name"]} shelf is empty"
      end
    end
    sleep 1

    puts
  end

  def print_choices
    puts 'Please pick a beverage:'
    print_stock
    print '> '
  end

  def get_choice
    choice = nil
    while choice == nil
      input = gets.chomp
      if input.to_i.to_s == input && (1..stock.size).include?(input.to_i)
        choice = input.to_i
      else
        puts "Please enter a number from 1 to #{stock.size}"
        print "> "
      end
    end

    choice
  end

  def get_coins(amount)
    @inserted_coins = {}
    inserted = 0
    while inserted < amount
      print "> "
      input = gets.chomp

      if input.to_i.to_s == input && till.keys.include?(input.to_i)
        inserted += input.to_i
        till[input.to_i] += 1
        @inserted_coins[input.to_i] ||= 0
        @inserted_coins[input.to_i] += 1
        puts "Inserted so far: #{CurrencyFormatter.format inserted}"
      else
        puts "Invalid coin, please insert one of #{formatted_coins}"
      end
    end

    inserted
  end

  def formatted_coins
    # till.keys.map { |coin| "#{CurrencyFormatter.format coin}" }.join(", ")
    till.keys.join(", ")
  end

  def greet
    puts "Welcome to Vendico™"
    puts
    print vending_ascii
    puts
  end

  def print_stock
    stock.each.with_index do |item, index|
      details = item[1]
      puts "#{index + 1}. #{details['formatted_name']}: #{CurrencyFormatter.format details['price']}"
    end
  end

  def vending_ascii
    vending_ascii = <<-VENDING
|　　|   VENDICO      |
|　　|┌──────────────┐|
|　　|│![] [] [] []  │|
|　　|│:l=========!. │|
|　　|│![] [] [] []  │|
|　　|│:l=========!. │|
|　　|│┌───────────┐ │|
|　　|││           │ │|
|　　|│└───────────┘ │|
|＿＿|└──────────────┘|
VENDING
  end
end

class CurrencyFormatter
  def self.format(value)
    value = value.to_s.insert(-3, ".")
    "#{value} ₪"
  end
end

if ARGV.empty?
  vending_machine = VendingMachine.new(init_values["stock"], init_values["till"])
  vending_machine.process
  # print_greeting(init_values["stock"])
end
