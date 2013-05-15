require './lib/drink'

class VendingMachine
  VALID_MONEY = [10, 50, 100, 500, 1000]
  attr_reader :total, :drinks, :sale_amount

  def initialize
    @total = 0
    @drinks = Array.new(5, Drink.cola)
    @sale_amount = 0
  end

  def insert money
    return money unless VALID_MONEY.include? money
    @total += money
    nil
  end

  def change
    change = total
    @total = 0
    change
  end

  def purchase(drink_name)
    if can_purchase? drink_name
      drink = pop_drink drink_name
      @sale_amount += drink.price
      @total -= drink.price
      [drink, change]
    end
  end

  def can_purchase?(drink_name)
    available_drink_names.include? drink_name
  end

  def store(drink)
    drinks << drink
  end

  def available_drink_names
    drinks.uniq.select{|d| d.price <= total }.map(&:name)
  end

  def stock_info
    ret = []
    @drinks.each do |drink|
      puts drink
      if info = ret.find{|info| info[:name] == drink.name}
        info[:stock] += 1
      else
        ret << { name: drink.name, price: drink.price, stock: 1 }
      end
    end
    ret
  end

  private

  def pop_drink name
    drinks.delete_at(drinks.index{|d| d.name == name })
  end
end
