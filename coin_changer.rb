# frozen_string_literal: true

# Figures out coin change with available coins in the till
class CoinChanger
  class InsufficientCoins < StandardError; end

  attr_reader :total_change, :till

  def initialize(total_change, till)
    @total_change = total_change
    @till = till
  end

  # Greedy algorithm of finding coin change
  # If item prices or coin values will change
  # it will require a switch to a dynamic programming approach
  def process
    accrued_change = 0
    taken_coins = {}

    till.sort.reverse.each do |coin_value, amount|
      next if amount.zero?

      remaining_change = total_change - accrued_change

      next if remaining_change < coin_value

      max_coins_of_amount = (remaining_change / coin_value).round
      coins_to_take = [max_coins_of_amount, amount].min
      taken_coins[coin_value] = coins_to_take

      accrued_change += coin_value * coins_to_take
    end

    raise InsufficientCoins if (total_change - accrued_change).positive?

    taken_coins
  end
end
