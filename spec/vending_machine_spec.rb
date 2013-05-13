require 'rspec'
require './vending_machine'

describe VendingMachine do
  describe "#test" do
    specify do
      machine = VendingMachine.new
      expect(machine.say).to eq "hello!"
    end
  end
end
