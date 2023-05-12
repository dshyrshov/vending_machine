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

    till.sort.reverse.each do |coin_value, coin_amount|
      next if coin_amount.zero?

      remaining_change = total_change - accrued_change

      next if remaining_change < coin_value

      max_coins_of_amount = (remaining_change / coin_value).round
      coins_to_take = [max_coins_of_amount, coin_amount].min
      taken_coins[coin_value] = coins_to_take

      accrued_change += coin_value * coins_to_take
    end

    raise InsufficientCoins if (total_change - accrued_change).positive?

    taken_coins
  end

  # Dynamic programming approach
  def dynamic_programming_approach
    coin_values = till.keys
    available_coins = till.values

    coins_used = Array.new(total_change / 25 + 1) { Array.new(coin_values.length, 0) }
    min_coins = Array.new(total_change / 25 + 1, Float::INFINITY)
    min_coins[0] = 0

    available_coins.each_with_index do |coin_amount, coin_index|
      coin_amount.times do
        total_change.step(0, -25) do |change_step|
          accrued_change = change_step + coin_values[coin_index]
          next if accrued_change > total_change
          next if min_coins[accrued_change / 25] <= min_coins[change_step / 25] + 1

          min_coins[accrued_change / 25] = min_coins[change_step / 25] + 1

          coins_used[accrued_change / 25] = coins_used[change_step / 25].dup
          coins_used[accrued_change / 25][coin_index] += 1
        end
      end
    end

    raise InsufficientCoins if min_coins[total_change / 25] == Float::INFINITY

    transform_to_hash(coin_values, coins_used[total_change / 25])
  end

  private

  def transform_to_hash(coin_values, coins_used)
    Hash[coin_values.zip(coins_used)].select { |_k, v| v.positive? }
  end
end
