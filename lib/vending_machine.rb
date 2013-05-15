require './lib/drink'

class VendingMachine
  AVAILABLE_MONEY = [10, 50, 100, 500, 1000]
  DEFAULT_DRINKS = Array.new(5, Drink.cola)

  attr_reader :total, :sale_amount

  def initialize
    @total = 0
    @drinks = DEFAULT_DRINKS.dup
    @sale_amount = 0
  end

  def insert money
    return money unless AVAILABLE_MONEY.include? money
    @total += money
    nil
  end

  def refund
    change = total
    @total = 0
    change
  end

  def purchase(drink_name)
    if can_purchase? drink_name
      drink = pop_drink drink_name
      @sale_amount += drink.price
      @total -= drink.price
      [drink, refund]
    end
  end

  def can_purchase?(drink_name)
    available_drink_names.include? drink_name
  end

  def store(drink)
    @drinks << drink
  end

  def available_drink_names
    stock_info.select{|_, info| info[:price] <= total }.keys
  end

  def stock_info
    @drinks.inject({}) do |hash, drink|
      if info = hash[drink.name]
        info[:stock] += 1
      else
        hash[drink.name] = { price: drink.price, stock: 1 }
      end
      hash
    end
  end

  private

  def pop_drink name
    @drinks.delete_at(@drinks.index{|d| d.name == name })
  end
end
