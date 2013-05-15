require 'rspec'
require './lib/vending_machine'

describe VendingMachine do
  def insert amount_of_money
    (amount_of_money/10).times { machine.insert 10 }
  end
  def purchase_cola(amount = 1)
    amount.times do
      insert 120
      machine.purchase :cola
    end
  end
  let(:machine) { VendingMachine.new }
  describe "#insert" do
    it 'inserts 10 yen' do
      expect(machine.insert(10)).to be_nil
    end
    it 'inserts 50 yen' do
      expect(machine.insert(50)).to be_nil
    end
    it 'inserts 100 yen' do
      expect(machine.insert(100)).to be_nil
    end
    it 'inserts 500 yen' do
      expect(machine.insert(500)).to be_nil
    end
    it 'inserts 1000 yen' do
      expect(machine.insert(1000)).to be_nil
    end
    it 'inserts more than once' do
      expect(machine.insert(10)).to be_nil
      expect(machine.insert(10)).to be_nil
    end
    context 'when invalid money' do
      context '1 yen' do
        it 'returns money' do
          expect(machine.insert(1)).to eq 1
        end
        it 'does not increment total money' do
          machine.insert 1
          expect(machine.total).to eq 0
        end
      end
      context '5 yen' do
        it 'returns money' do
          expect(machine.insert(5)).to eq 5
        end
        it 'does not increment total money' do
          machine.insert 5
          expect(machine.total).to eq 0
        end
      end
      context '5000 yen' do
        it 'returns money' do
          expect(machine.insert(5000)).to eq 5000
        end
        it 'does not increment total money' do
          machine.insert 5000
          expect(machine.total).to eq 0
        end
      end
    end
  end
  describe '#total' do
    context 'when insert more than once' do
      before do
        machine.insert 10
        machine.insert 50
      end
      specify { expect(machine.total).to eq 60 }
    end
  end
  describe '#change' do
    before do
      insert 60
    end
    it 'returns change' do
      expect(machine.change).to eq 60
    end
    it 'has no money' do
      machine.change
      expect(machine.total).to eq 0
    end
    context 'after purchase' do
      before do
        purchase_cola
      end
      it 'has no change' do
        expect(machine.change).to eq 0
      end
    end
  end
  describe '#stored_drink_info' do
    it 'has 1 info' do
      expect(machine.stored_drink_info).to have(1).item
    end
    specify { expect(machine.stored_drink_info[0][:name]).to eq :cola }
    specify { expect(machine.stored_drink_info[0][:price]).to eq 120 }
    specify { expect(machine.stored_drink_info[0][:stock]).to eq 5 }
    context 'when add water' do
      before do
        purchase_cola 5
        2.times { machine.store Drink.water }
        3.times { machine.store Drink.redbull }
      end
      it 'has 2 info' do
        expect(machine.stored_drink_info).to have(2).items
      end
      it 'does not have info for cola' do
        expect(machine.stored_drink_info.find{|info| info[:name] == :cola}).to be_nil
      end
      it 'has valid info for water' do
        info = machine.stored_drink_info.find{|info| info[:name] == :water}
        expect(info[:price]).to eq 100
        expect(info[:stock]).to eq 2
      end
      it 'has valid info for redbull' do
        info = machine.stored_drink_info.find{|info| info[:name] == :redbull}
        expect(info[:price]).to eq 200
        expect(info[:stock]).to eq 3
      end
    end
  end
  describe '#can_purchase?' do
    context 'when drinks and money okay' do
      before do
        insert 120
      end
      specify{ expect(machine.can_purchase? :cola).to be_true }
    end
    context 'when money is not emough' do
      before do
        insert 110
      end
      specify{ expect(machine.can_purchase? :cola).to be_false }
    end
    context 'when no cola' do
      before do
        purchase_cola 5
        insert 120
      end
      specify{ expect(machine.can_purchase? :cola).to be_false }
    end
  end
  describe '#purchase' do
    context 'when drinks and money okay' do
      before do
        insert 120
      end
      it 'can purchase' do
        expect(machine.purchase :cola).to eq [Drink.cola, 0]
      end
      it 'reduces drinks' do
        machine.purchase :cola
        expect(machine.drinks).to have(4).items
      end
    end
    context 'when money is not enough' do
      before do
        insert 110
      end
      it 'cannot purchase' do
        expect(machine.purchase :cola).to be_nil
      end
      it 'does not reduce drinks' do
        expect{machine.purchase :cola}.not_to change{machine.drinks}
      end
    end
    context 'when no cola' do
      before do
        purchase_cola 5
        insert 120
      end
      it 'cannot purchase' do
        expect(machine.purchase :cola).to be_nil
      end
      it 'does not reduce drinks' do
        expect{machine.purchase :cola}.not_to change{machine.drinks}.from(0)
      end
      it 'does not increase sale_amount' do
        expect{machine.purchase :cola}.not_to change{machine.sale_amount}.from(120 * 5)
      end
      it 'returns inserted money' do
        machine.purchase :cola
        expect(machine.change).to eq 120
      end
    end
    context 'when money exceeds price' do
      before do
        insert 500
      end
      it 'returns drink and change' do
        expect(machine.purchase :cola).to eq [Drink.cola, 500 - 120]
      end
      it 'has no money after purchase' do
        expect{machine.purchase :cola}.to change{machine.total}.from(500).to(0)
      end
    end
  end
  describe '#sale_amount' do
    context 'when purchase once' do
      before do
        purchase_cola
      end
      specify { expect(machine.sale_amount).to eq 120 }
    end
    context 'when purchase twice' do
      before do
        purchase_cola 2
      end
      specify { expect(machine.sale_amount).to eq 240 }
    end
  end
  describe '#store' do
    it 'can store drink' do
      expect{2.times{machine.store Drink.redbull}}.to change{machine.drinks.count(Drink.redbull)}.from(0).to(2)
    end
  end
  describe '#available_drink_names' do
    before do
      5.times { machine.store Drink.redbull }
      5.times { machine.store Drink.water }
    end
    context 'when insert 200yen' do
      before do
        insert 200
      end
      it 'can purchase all items' do
        expect(machine.available_drink_names).to have(3).items
      end
      it 'can purchase cola-s' do
        expect(machine.available_drink_names.include?(:cola)).to be_true
      end
      it 'can purchase cola' do
        expect(machine.can_purchase? :cola).to be_true
      end
      it 'can purchase redbulls' do
        expect(machine.available_drink_names.include?(:redbull)).to be_true
      end
      it 'can purchase redbull' do
        expect(machine.can_purchase? :redbull).to be_true
      end
      it 'can purchase water-s' do
        expect(machine.available_drink_names.include?(:water)).to be_true
      end
      it 'can purchase water' do
        expect(machine.can_purchase? :water).to be_true
      end
    end
    context 'when insert 190yen' do
      before do
        insert 190
      end
      it 'can purchase all items except for redbull' do
        expect(machine.available_drink_names).to have(2).items
      end
      it 'can purchase cola-s' do
        expect(machine.available_drink_names.include?(:cola)).to be_true
      end
      it 'can purchase cola' do
        expect(machine.can_purchase? :cola).to be_true
      end
      it 'cannot purchase redbull' do
        expect(machine.available_drink_names.include?(:redbull)).to be_false
      end
      it 'cannot purchase redull' do
        expect(machine.can_purchase? :redbull).to be_false
      end
      it 'can purchase water-s' do
        expect(machine.available_drink_names.include?(:water)).to be_true
      end
      it 'can purchase water' do
        expect(machine.can_purchase? :water).to be_true
      end
    end
    context 'when no cola' do
      before do
        purchase_cola 5
        insert 200
      end
      it 'can purchase water and redbull' do
        expect(machine.available_drink_names).to have(2).items
      end
      it 'can purchase redbulls' do
        expect(machine.available_drink_names.include?(:redbull)).to be_true
      end
      it 'can purchase water-s' do
        expect(machine.available_drink_names.include?(:water)).to be_true
      end
      it 'cannot purchase cola-s' do
        expect(machine.available_drink_names.include?(:cola)).to be_false
      end
      it 'can purchase water' do
        expect(machine.can_purchase? :water).to be_true
      end
      it 'cannot purchase cola' do
        expect(machine.can_purchase? :cola).to be_false
      end
      it 'can purchase redbull' do
        expect(machine.can_purchase? :redbull).to be_true
      end
    end
  end
end
