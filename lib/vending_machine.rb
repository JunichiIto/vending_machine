require './lib/drink'

class VendingMachine
  AVAILABLE_MONEY = [10, 50, 100, 500, 1000]

  attr_reader :total, :sale_amount

  def initialize
    @total = 0
    @sale_amount = 0
    @drink_table = {}
    5.times { store Drink.cola }
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
    if purchasable? drink_name
      drink = @drink_table[drink_name][:drinks].pop
      @sale_amount += drink.price
      @total -= drink.price
      [drink, refund]
    end
  end

  def purchasable?(drink_name)
    purchasable_drink_names.include? drink_name
  end

  def store(drink)
    @drink_table[drink.name] = { price: drink.price, drinks: [] } unless @drink_table.has_key? drink.name
    @drink_table[drink.name][:drinks] << drink
    nil
  end

  def purchasable_drink_names
    @drink_table.select{|_, info| info[:price] <= total && info[:drinks].size > 0 }.keys
  end

  def stock_info
    Hash[@drink_table.map {|name, info| [name, { price: info[:price], stock: info[:drinks].size }] }]
  end
end
