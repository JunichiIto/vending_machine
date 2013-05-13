require './drink'

class VendingMachine
  VALID_MONEY = [10, 50, 100, 500, 1000]
  attr_reader :total_amount

  def initialize
    @total_amount = 0
  end

  def insert_money amount
    return amount unless VALID_MONEY.include? amount
    @total_amount += amount
    nil
  end

  def change
    change = @total_amount
    @total_amount = 0
    change
  end

  def drinks
    Array.new(5, Drink.new(120, 'cola'))
  end
end
