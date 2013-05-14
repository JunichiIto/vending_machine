require './lib/drink'

class VendingMachine
  VALID_MONEY = [10, 50, 100, 500, 1000]
  attr_reader :total_money, :drinks, :sale

  def initialize
    @total_money = 0
    @drinks = Array.new(5, Drink.cola)
    @sale = 0
  end

  def insert_money money
    return money unless VALID_MONEY.include? money
    @total_money += money
    nil
  end

  def change
    change = total_money
    @total_money = 0
    change
  end

  def buy(drink_name)
    if can_buy? drink_name
      drink = pop_drink drink_name
      @sale += drink.price
      @total_money -= drink.price
      [drink, change]
    end
  end

  def can_buy?(drink_name)
    available_drink_names.include? drink_name
  end

  def add_drink(drink)
    drinks << drink
  end

  def available_drink_names
    drinks.uniq.select{|d| d.price <= total_money }.map(&:name)
  end

  private

  def pop_drink name
    drinks.delete_at(drinks.index{|d| d.name == name })
  end
end
