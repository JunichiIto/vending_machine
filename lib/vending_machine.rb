require './lib/drink'

class VendingMachine
  AVAILABLE_MONEY = [10, 50, 100, 500, 1000]

  attr_reader :total, :sale_amount

  def initialize
    @total = 0
    @drink_table = {}
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
      drink = @drink_table[drink_name][:drinks].pop
      @sale_amount += drink.price
      @total -= drink.price
      [drink, refund]
    end
  end

  def can_purchase?(drink_name)
    available_drink_names.include? drink_name
  end

  def store(drink)
    unless info = @drink_table[drink.name]
      info = { price: drink.price, drinks: [] }
      @drink_table[drink.name] = info
    end
    info[:drinks] << drink
  end

  def available_drink_names
    @drink_table.select{|_, info| info[:price] <= total && info[:drinks].size > 0 }.keys
  end

  def stock_info
    @drink_table.inject({}) do |hash, array|
      name, info = array
      hash[name] = { price: info[:price], stock: info[:drinks].size }
      hash
    end
  end
end
