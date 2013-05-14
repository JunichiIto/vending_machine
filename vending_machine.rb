require './drink'

class VendingMachine
  VALID_MONEY = [10, 50, 100, 500, 1000]
  attr_reader :total_amount, :drinks, :sale

  def initialize
    @total_amount = 0
    @drinks = Array.new(5, Drink.cola)
    @sale = 0
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

  def buy(drink)
    if can_buy? drink
      drink = @drinks.delete_at(@drinks.index(drink))
      @sale += drink.price
      @total_amount -= drink.price
      drink
    end
  end

  def can_buy?(drink)
    total_amount >= drink.price and @drinks.any?{|d| d == drink}
  end

  def add_drink(drink)
    @drinks << drink
  end

  def available_drinks
    drinks.select{|d| d.price <= total_amount}
  end
end
