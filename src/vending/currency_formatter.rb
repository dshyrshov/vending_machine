# frozen_string_literal: true

module Vending
  class CurrencyFormatter
    def self.format(value)
      value = value.to_s.insert(-3, '.')
      "#{value} ₪"
    end
  end
end
