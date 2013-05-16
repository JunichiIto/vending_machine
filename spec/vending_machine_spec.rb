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
    context 'when available money' do
      shared_examples_for 'available money' do
        it 'does not return money' do
          expect(machine.insert money).to be_nil
        end
        it 'can insert more than once' do
          2.times { expect(machine.insert money).to be_nil }
        end
      end
      it_should_behave_like 'available money' do
        let(:money) { 10 }
      end
      it_should_behave_like 'available money' do
        let(:money) { 50 }
      end
      it_should_behave_like 'available money' do
        let(:money) { 100 }
      end
      it_should_behave_like 'available money' do
        let(:money) { 500 }
      end
      it_should_behave_like 'available money' do
        let(:money) { 1000 }
      end
    end
    context 'when unavailable money' do
      shared_examples_for 'unavailable money' do
        it 'returns money' do
          expect(machine.insert money).to eq money
        end
      end
      it_should_behave_like 'unavailable money' do
        let(:money) { 1 }
      end
      it_should_behave_like 'unavailable money' do
        let(:money) { 5 }
      end
      it_should_behave_like 'unavailable money' do
        let(:money) { 2000 }
      end
      it_should_behave_like 'unavailable money' do
        let(:money) { 5000 }
      end
      it_should_behave_like 'unavailable money' do
        let(:money) { 10000 }
      end
    end
  end
  describe '#total' do
    subject { machine.total }
    context 'when available money' do
      before do
        machine.insert 10
        machine.insert 50
      end
      it { should eq 60 }
    end
    context 'when available money' do
      before do
        machine.insert 1
        machine.insert 5
      end
      it { should eq 0 }
    end
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
  end
  describe '#stock_info' do
    it 'has 1 info' do
      expect(machine.stock_info[:cola]).not_to be_nil
    end
    it 'has valid info for cola' do
      expect(machine.stock_info[:cola]).to include(price: 120, stock: 5)
    end
    context 'when store more drinks' do
      before do
        purchase_cola 5
        2.times { machine.store Drink.water }
        3.times { machine.store Drink.redbull }
      end
      it 'has 3 info' do
        expect(machine.stock_info).to have(3).items
      end
      it 'has valid info for cola' do
        expect(machine.stock_info[:cola]).to include(price: 120, stock: 0)
      end
      it 'has valid info for water' do
        expect(machine.stock_info[:water]).to include(price: 100, stock: 2)
      end
      it 'has valid info for redbull' do
        expect(machine.stock_info[:redbull]).to include(price: 200, stock: 3)
      end
    end
  end
  describe '#purchasable?' do
    subject { machine.purchasable? :cola }
    context 'when stock and money okay' do
      before do
        insert 120
      end
      it { should be_true }
    end
    context 'when money is not enough' do
      before do
        insert 110
      end
      it { should be_false }
    end
    context 'when no cola' do
      before do
        purchase_cola 5
        insert 120
      end
      it { should be_false }
    end
  end
  describe '#purchase' do
    context 'when stock and money okay' do
      before do
        insert 120
      end
      it 'can purchase cola' do
        expect(machine.purchase :cola).to eq [Drink.cola, 0]
      end
      it 'reduces stock' do
        expect{machine.purchase :cola}.to change{machine.stock_info[:cola][:stock]}.from(5).to(4)
      end
    end
    context 'when money exceeds price' do
      before do
        insert 500
      end
      it 'returns drink and change' do
        expect(machine.purchase :cola).to eq [Drink.cola, 500 - 120]
      end
      it 'has no change after purchase' do
        expect{machine.purchase :cola}.to change{machine.total}.from(500).to(0)
      end
    end
    context 'in not purchasable cases' do
      shared_examples_for 'not purchasable' do
        it 'cannot purchase' do
          expect(machine.purchase :cola).to be_nil
        end
        it 'does not reduce stock' do
          expect{machine.purchase :cola}.not_to change{machine.stock_info[:cola][:stock]}
        end
        it 'does not increase sale_amount' do
          expect{machine.purchase :cola}.not_to change{machine.sale_amount}
        end
        it 'keeps inserted money' do
          expect{machine.purchase :cola}.not_to change{machine.total}
        end
      end
      context 'when money is not enough' do
        before do
          insert 110
        end
        it_should_behave_like 'not purchasable'
      end
      context 'when no cola' do
        before do
          purchase_cola 5
          insert 120
        end
        it_should_behave_like 'not purchasable'
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
    subject { machine.purchasable_drink_names }
    context 'when insert 200yen' do
      before do
        insert 200
      end
      it { should have(3).items }
      it { should include(:cola, :redbull, :water) }
    end
    context 'when insert 190yen' do
      before do
        insert 190
      end
      it { should have(2).items }
      it { should include(:cola, :water) }
    end
    context 'when no cola' do
      before do
        purchase_cola 5
        insert 200
      end
      it { should have(2).items }
      it { should include(:redbull, :water) }
    end
  end
end
