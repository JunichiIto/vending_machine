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

  def eql?(another)
    self == another
  end

  def hash
    name.hash
  end

  def to_s
    "<Drink: name=#{name}, price=#{price}>"
  end
end
