require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe VendingMachine do
  def insert amount_of_money
    (amount_of_money / 10).times { machine.insert 10 }
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
      expect(machine.insert 10).to be_nil
    end
    it 'inserts 50 yen' do
      expect(machine.insert 50).to be_nil
    end
    it 'inserts 100 yen' do
      expect(machine.insert 100).to be_nil
    end
    it 'inserts 500 yen' do
      expect(machine.insert 500).to be_nil
    end
    it 'inserts 1000 yen' do
      expect(machine.insert 1000).to be_nil
    end
    it 'inserts more than once' do
      expect(machine.insert 10).to be_nil
      expect(machine.insert 10).to be_nil
    end
    context 'when unavailable money' do
      context '1 yen' do
        it 'returns money' do
          expect(machine.insert 1).to eq 1
        end
        it 'does not increment total' do
          expect{machine.insert 1}.not_to change{machine.total}.from(0)
        end
      end
      context '5 yen' do
        it 'returns money' do
          expect(machine.insert 5).to eq 5
        end
        it 'does not increment total' do
          expect{machine.insert 5}.not_to change{machine.total}.from(0)
        end
      end
      context '5000 yen' do
        it 'returns money' do
          expect(machine.insert 5000).to eq 5000
        end
        it 'does not increment total' do
          expect{machine.insert 5000}.not_to change{machine.total}.from(0)
        end
      end
    end
  end
  describe '#total' do
    before do
      machine.insert 10
      machine.insert 50
    end
    specify { expect(machine.total).to eq 60 }
  end
  describe '#refund' do
    before do
      insert 120
    end
    it 'returns change' do
      expect(machine.refund).to eq 120
    end
    it 'has no money after refund' do
      expect{machine.refund}.to change{machine.total}.from(120).to(0)
    end
    it 'has no change after purchase' do
      expect{machine.purchase :cola}.to change{machine.refund}.from(120).to(0)
    end
  end
  describe '#stock_info' do
    it 'has 1 info' do
      expect(machine.stock_info[:cola]).not_to be_nil
    end
    it 'has valid info for cola' do
      expect(machine.stock_info[:cola][:price]).to eq 120
      expect(machine.stock_info[:cola][:stock]).to eq 5
    end
    context 'when add water' do
      before do
        purchase_cola 5
        2.times { machine.store Drink.water }
        3.times { machine.store Drink.redbull }
      end
      it 'has 3 info' do
        expect(machine.stock_info).to have(3).items
      end
      it 'has valid info for cola' do
        info = machine.stock_info[:cola]
        expect(info[:price]).to eq 120
        expect(info[:stock]).to eq 0
      end
      it 'has valid info for water' do
        info = machine.stock_info[:water]
        expect(info[:price]).to eq 100
        expect(info[:stock]).to eq 2
      end
      it 'has valid info for redbull' do
        info = machine.stock_info[:redbull]
        expect(info[:price]).to eq 200
        expect(info[:stock]).to eq 3
      end
    end
  end
  describe '#purchasable?' do
    context 'when stock and money okay' do
      before do
        insert 120
      end
      specify{ expect(machine.purchasable? :cola).to be_true }
    end
    context 'when money is not enough' do
      before do
        insert 110
      end
      specify{ expect(machine.purchasable? :cola).to be_false }
    end
    context 'when no cola' do
      before do
        purchase_cola 5
        insert 120
      end
      specify{ expect(machine.purchasable? :cola).to be_false }
    end
  end
  describe '#purchase' do
    context 'when stock and money okay' do
      before do
        insert 120
      end
      it 'can purchase' do
        expect(machine.purchase :cola).to eq [Drink.cola, 0]
      end
      it 'reduces stock' do
        expect{machine.purchase :cola}.to change{machine.stock_info[:cola][:stock]}.from(5).to(4)
      end
    end
    context 'when money is not enough' do
      before do
        insert 110
      end
      it 'cannot purchase' do
        expect(machine.purchase :cola).to be_nil
      end
      it 'does not reduce stock' do
        expect{machine.purchase :cola}.not_to change{machine.stock_info[:cola][:stock]}.from(5)
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
      it 'does not reduce stock' do
        expect{machine.purchase :cola}.not_to change{machine.stock_info[:cola][:stock]}.from(0)
      end
      it 'does not increase sale_amount' do
        expect{machine.purchase :cola}.not_to change{machine.sale_amount}.from(120 * 5)
      end
      it 'keeps inserted money' do
        expect{machine.purchase :cola}.not_to change{machine.total}.from(120)
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
    it 'increases sale_amount after purchase' do
      expect{purchase_cola}.to change{machine.sale_amount}.from(0).to(120)
    end
    it 'increases sale_amount after purchase twice' do
      expect{purchase_cola 2}.to change{machine.sale_amount}.from(0).to(240)
    end
  end
  describe '#store' do
    it 'can store drink' do
      expect{machine.store Drink.redbull}.to change{machine.stock_info[:redbull]}.from(nil)
    end
    it 'returns nil' do
      expect(machine.store Drink.redbull).to be_nil
    end
  end
  describe '#purchasable_drink_names' do
    before do
      5.times { machine.store Drink.redbull }
      5.times { machine.store Drink.water }
    end
    context 'when insert 200yen' do
      before do
        insert 200
      end
      it 'can purchase all drinks' do
        expect(machine.purchasable_drink_names).to have(3).items
      end
      it 'contains all drinks' do
        expect(machine.purchasable_drink_names).to include(:cola, :redbull, :water)
      end
    end
    context 'when insert 190yen' do
      before do
        insert 190
      end
      it 'can purchase all drinks except for redbull' do
        expect(machine.purchasable_drink_names).to have(2).items
      end
      it 'includes all drinks except for redbull' do
        expect(machine.purchasable_drink_names).to include(:cola, :water)
      end
    end
    context 'when no cola' do
      before do
        purchase_cola 5
        insert 200
      end
      it 'can purchase all drinks except for cola' do
        expect(machine.purchasable_drink_names).to have(2).items
      end
      it 'includes all drinks except for cola' do
        expect(machine.purchasable_drink_names).to include(:redbull, :water)
      end
    end
  end
end
