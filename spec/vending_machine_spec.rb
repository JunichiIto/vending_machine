require 'rspec'
require './vending_machine'

describe VendingMachine do
  let(:machine) { VendingMachine.new }
  describe "#insert_money" do
    it 'inserts 10 yen' do
      expect(machine.insert_money(10)).to be_nil
    end
    it 'inserts 50 yen' do
      expect(machine.insert_money(50)).to be_nil
    end
    it 'inserts 100 yen' do
      expect(machine.insert_money(100)).to be_nil
    end
    it 'inserts 500 yen' do
      expect(machine.insert_money(500)).to be_nil
    end
    it 'inserts 1000 yen' do
      expect(machine.insert_money(1000)).to be_nil
    end
    it 'inserts more than once' do
      expect(machine.insert_money(10)).to be_nil
      expect(machine.insert_money(10)).to be_nil
    end
    context 'when invalid money' do
      context '1 yen' do
        it 'returns money' do
          expect(machine.insert_money(1)).to eq 1
        end
        it 'does not increment total amount' do
          machine.insert_money 1
          expect(machine.total_amount).to eq 0
        end
      end
      context '5 yen' do
        it 'returns money' do
          expect(machine.insert_money(5)).to eq 5
        end
        it 'does not increment total amount' do
          machine.insert_money 5
          expect(machine.total_amount).to eq 0
        end
      end
      context '5000 yen' do
        it 'returns money' do
          expect(machine.insert_money(5000)).to eq 5000
        end
        it 'does not increment total amount' do
          machine.insert_money 5000
          expect(machine.total_amount).to eq 0
        end
      end
    end
  end
  describe '#total_amount' do
    context 'more than once' do
      before do
        machine.insert_money 10
        machine.insert_money 50
      end
      specify { expect(machine.total_amount).to eq 60 }
    end
  end
  describe '#change' do
    before do
        machine.insert_money 10
        machine.insert_money 50
    end
    it 'returns change' do
      expect(machine.change).to eq 60
    end
    it 'has no money' do
      machine.change
      expect(machine.total_amount).to eq 0
    end
    context 'after buy' do
      before do
        machine.insert_money 100
        machine.buy :cola
      end
      it 'has no change' do
        expect(machine.change).to eq 0
      end
    end
  end
  describe '#drinks' do
    it 'has 5 drinks by default' do
      expect(machine.drinks).to have(5).items
    end
    it 'has 5 cola-s' do
      expect(machine.drinks.count(Drink.cola)).to eq 5
    end
  end
  describe '#can_buy?' do
    context 'when drinks and money okay' do
      before do
        machine.insert_money 10
        machine.insert_money 10
        machine.insert_money 100
      end
      specify{ expect(machine.can_buy? :cola).to be_true }
    end
    context 'when money is not emough' do
      before do
        machine.insert_money 10
        machine.insert_money 100
      end
      specify{ expect(machine.can_buy? :cola).to be_false }
    end
    context 'when no cola' do
      before do
        5.times do
          machine.insert_money 10
          machine.insert_money 10
          machine.insert_money 100
          machine.buy :cola
        end
        machine.insert_money 10
        machine.insert_money 10
        machine.insert_money 100
      end
      specify{ expect(machine.can_buy? :cola).to be_false }
    end
  end
  describe '#buy' do
    context 'when drinks and money okay' do
      before do
        machine.insert_money 10
        machine.insert_money 10
        machine.insert_money 100
      end
      it 'can buy' do
        expect(machine.buy :cola).to eq [Drink.cola, 0]
      end
      it 'reduces drinks' do
        machine.buy :cola
        expect(machine.drinks).to have(4).items
      end
    end
    context 'when money is not enough' do
      before do
        machine.insert_money 10
        machine.insert_money 100
      end
      it 'cannot buy' do
        expect(machine.buy :cola).to be_nil
      end
      it 'does not reduce drinks' do
        expect{machine.buy :cola}.not_to change{machine.drinks}
      end
    end
    context 'when no cola' do
      before do
        5.times do
          machine.insert_money 10
          machine.insert_money 10
          machine.insert_money 100
          machine.buy :cola
        end
        machine.insert_money 10
        machine.insert_money 10
        machine.insert_money 100
      end
      it 'cannot buy' do
        expect(machine.buy :cola).to be_nil
      end
      it 'does not reduce drinks' do
        expect{machine.buy :cola}.not_to change{machine.drinks}.from(0)
      end
      it 'does not increase sales' do
        expect{machine.buy :cola}.not_to change{machine.sale}.from(120 * 5)
      end
      it 'returns inserted money' do
        machine.buy :cola
        expect(machine.change).to eq 120
      end
    end
    context 'when money exceeds price' do
      before do
        machine.insert_money 500
      end
      it 'returns drink and change' do
        expect(machine.buy :cola).to eq [Drink.cola, 500 - 120]
      end
      it 'has no money after buy' do
        expect{machine.buy :cola}.to change{machine.total_amount}.from(500).to(0)
      end
    end
  end
  describe '#sale' do
    context 'when once' do
      before do
        machine.insert_money 10
        machine.insert_money 10
        machine.insert_money 100
        machine.buy :cola
      end
      specify { expect(machine.sale).to eq 120 }
    end
    context 'when twice' do
      before do
        2.times do
          machine.insert_money 10
          machine.insert_money 10
          machine.insert_money 100
          machine.buy :cola
        end
      end
      specify { expect(machine.sale).to eq 240 }
    end
  end
  describe '#add_drink' do
    it 'can add drink' do
      machine.add_drink Drink.redbull
      expect(machine.drinks.count(Drink.redbull)).to eq 1
    end
  end
  describe '#available_drinks' do
    before do
      5.times do
        machine.add_drink Drink.redbull
      end
      5.times do
        machine.add_drink Drink.water
      end
    end
    context 'when insert 200yen' do
      before do
        machine.insert_money 100
        machine.insert_money 100
      end
      it 'can buy all items' do
        expect(machine.available_drinks).to have(15).items
      end
      it 'can buy all cola-s' do
        expect(machine.available_drinks.count(Drink.cola)).to eq 5
      end
      it 'can buy cola' do
        expect(machine.can_buy? :cola).to be_true
      end
      it 'can buy all redbulls' do
        expect(machine.available_drinks.count(Drink.redbull)).to eq 5
      end
      it 'can buy redbull' do
        expect(machine.can_buy? :redbull).to be_true
      end
      it 'can buy all water-s' do
        expect(machine.available_drinks.count(Drink.water)).to eq 5
      end
      it 'can buy water' do
        expect(machine.can_buy? :water).to be_true
      end
    end
    context 'when insert 190yen' do
      before do
        19.times { machine.insert_money 10 }
      end
      it 'can buy all items except for redbull' do
        expect(machine.available_drinks).to have(10).items
      end
      it 'can buy all cola-s' do
        expect(machine.available_drinks.count(Drink.cola)).to eq 5
      end
      it 'can buy cola' do
        expect(machine.can_buy? :cola).to be_true
      end
      it 'cannot buy redbull' do
        expect(machine.available_drinks.count(Drink.redbull)).to eq 0
      end
      it 'cannot buy redull' do
        expect(machine.can_buy? :redbull).to be_false
      end
      it 'can buy all water-s' do
        expect(machine.available_drinks.count(Drink.water)).to eq 5
      end
      it 'can buy water' do
        expect(machine.can_buy? :water).to be_true
      end
    end
    context 'when no cola' do
      before do
        5.times do
          12.times do
            machine.insert_money 10
          end
          machine.buy :cola
        end
        12.times do
          machine.insert_money 10
        end
      end
      it 'can buy water only' do
        expect(machine.available_drinks).to have(5).items
      end
      it 'can buy all water-s' do
        expect(machine.available_drinks.count(Drink.water)).to eq 5
      end
      it 'can buy water' do
        expect(machine.can_buy? :water).to be_true
      end
      it 'cannot buy cola' do
        expect(machine.can_buy? :cola).to be_false
      end
      it 'cannot buy redbull' do
        expect(machine.can_buy? :redbull).to be_false
      end
    end
  end
end
