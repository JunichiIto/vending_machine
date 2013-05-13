class Drink
  attr_reader :name, :price

  def self.cola
    self.new 120, "cola"
  end

  def initialize price, name
    @name = name
    @price = price
  end

  def ==(another)
    self.name == another.name
  end
end
