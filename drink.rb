class Drink
  attr_reader :name, :price

  def self.cola
    self.new 120, :cola
  end

  def self.redbull
    self.new 200, :redbull
  end

  def self.water
    self.new 100, :water
  end

  def initialize price, name
    @name = name
    @price = price
  end

  def ==(another)
    self.name == another.name
  end

  def to_s
    "name: #{name}, price: #{price}"
  end
end
