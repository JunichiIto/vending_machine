class Drink
  attr_reader :name, :price

  def initialize price, name
    @name = name
    @price = price
  end
end
