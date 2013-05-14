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

  def buy(drink_name)
    if can_buy? drink_name
      drink = @drinks.delete_at(@drinks.index{|d| d.name == drink_name})
      @sale += drink.price
      @total_amount -= drink.price
      [drink, change]
    end
  end

  def can_buy?(drink_name)
    available_drinks.any?{|d| d.name == drink_name}
  end

  def add_drink(drink)
    @drinks << drink
  end

  def available_drinks
    drinks.select{|d| d.price <= total_amount}.uniq
  end
end
