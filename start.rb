#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'yaml'
require_relative 'src/vending'

init_values = YAML.load_file('./init_values.yml', symbolize_names: true)
ENV['environment'] = 'development'

def vending_ascii
  <<-VENDING_ASCII
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
  VENDING_ASCII
end

def user_observes_the_machine(stock)
  puts 'You see a vending machine. It has:'

  stock.each do |item|
    if item[:qty].positive?
      puts "#{item[:qty]} bottles of #{item[:formatted_name]}"
    else
      puts "#{item[:formatted_name]} shelf is empty"
    end
  end
  sleep 1

  puts
end

puts vending_ascii

user_observes_the_machine(init_values[:stock])

vending_machine = Vending::Machine.new(**init_values)
vending_machine.process
