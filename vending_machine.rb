class VendingMachine
  attr_reader :total_amount

  def initialize
    @total_amount = 0
  end

  def insert_money amount
    @total_amount += amount
    amount
  end

  def change
    change = @total_amount
    @total_amount = 0
    change
  end
end
