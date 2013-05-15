require './lib/drink'

class VendingMachine
  AVAILABLE_MONEY = [10, 50, 100, 500, 1000]

  attr_reader :total, :sale_amount

  def initialize
    @total = 0
    @stock_table = {}
    5.times { store Drink.cola }
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
    unless info = @stock_table[drink.name]
      info = { price: drink.price, drinks: [] }
      @stock_table[drink.name] = info
    end
    info[:drinks] << drink
  end

  def available_drink_names
    @stock_table.select{|_, info| info[:price] <= total && info[:drinks].size > 0 }.keys
  end

  def stock_info
    ret = {}
    @stock_table.each do |name, info|
      ret[name] = { price: info[:price], stock: info[:drinks].size }
    end
    ret
  end

  private

  def pop_drink name
    @stock_table[name][:drinks].pop
  end
end
