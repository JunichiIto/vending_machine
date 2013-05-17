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
  describe "initial state" do
    subject { machine }
    its(:total) { should eq 0 }
    its(:sale_amount) { should eq 0 }
    its(:purchasable_drink_names) { should be_empty }
    it 'has 5 cola by default' do
      expect(machine.stock_info[:cola][:stock]).to eq 5
    end
    it 'cannot purchase cola' do
      expect(machine.purchasable? :cola).to be_false
    end
  end
  describe "#insert" do
    context 'when available money' do
      shared_examples_for 'available money' do
        it 'does not return money' do
          expect(machine.insert money).to be_nil
        end
        it 'can insert more than once' do
          2.times { expect(machine.insert money).to be_nil }
        end
        it 'increments total' do
          expect{machine.insert money}.to change{machine.total}.from(0).to(money)
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
        it 'does not increment total' do
          expect{machine.insert money}.not_to change{machine.total}.from(0)
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
    before do
      machine.insert 10
      machine.insert 50
    end
    it { should eq 60 }
  end
  describe '#refund' do
    before do
      insert 120
    end
    it 'returns change' do
      expect(machine.refund).to eq 120
    end
    it 'has no change after refund' do
      expect{machine.refund}.to change{machine.total}.from(120).to(0)
    end
  end
  describe '#stock_info' do
    before do
      machine.store Drink.cola
      machine.store Drink.redbull
    end
    it 'has info for each drink' do
      expect(machine.stock_info).to have(2).items
    end
    it 'returns price and stock for each drink' do
      expect(machine.stock_info[:cola]).to include(price: 120, stock: 6)
      expect(machine.stock_info[:redbull]).to include(price: 200, stock: 1)
    end
  end
  describe '#purchasable?' do
    subject { machine.purchasable? :cola }
    context 'when stock and money are enough' do
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
    context 'when no stock' do
      before do
        purchase_cola 5
        insert 120
      end
      it { should be_false }
    end
  end
  describe '#purchasable_drink_names' do
    subject { machine.purchasable_drink_names }
    before do
      machine.store Drink.redbull
      machine.store Drink.water
    end
    context 'when all drinks are purchasable' do
      before do
        insert 200
      end
      it { should have(3).items }
      it { should include(:cola, :redbull, :water) }
    end
    context 'when not enough money for redbull' do
      before do
        insert 190
      end
      it { should have(2).items }
      it { should include(:cola, :water) }
    end
    context 'when no stock for cola' do
      before do
        purchase_cola 5
        insert 200
      end
      it { should have(2).items }
      it { should include(:redbull, :water) }
    end
  end
  describe '#purchase' do
    context 'when purchasable' do
      before do
        insert 500
      end
      it 'returns drink and change' do
        expect(machine.purchase :cola).to eq [Drink.cola, 500 - 120]
      end
      it 'has no change after purchase' do
        expect{machine.purchase :cola}.to change{machine.total}.from(500).to(0)
      end
      it 'increases sale_amount' do
        expect{machine.purchase :cola}.to change{machine.sale_amount}.from(0).to(120)
      end
      it 'reduces stock' do
        expect{machine.purchase :cola}.to change{machine.stock_info[:cola][:stock]}.from(5).to(4)
      end
    end
    context 'when not purchasable' do
      before do
        insert 110
      end
      it 'returns nil' do
        expect(machine.purchase :cola).to be_nil
      end
      it 'keeps change' do
        expect{machine.purchase :cola}.not_to change{machine.total}.from(110)
      end
      it 'does not increase sale_amount' do
        expect{machine.purchase :cola}.not_to change{machine.sale_amount}.from(0)
      end
      it 'does not reduce stock' do
        expect{machine.purchase :cola}.not_to change{machine.stock_info[:cola][:stock]}.from(5)
      end
    end
  end
  describe '#sale_amount' do
    subject { machine.sale_amount }
    before do
      insert 200
      machine.purchase :cola

      machine.store Drink.redbull
      insert 200
      machine.purchase :redbull
    end
    it { should eq (120 + 200) }
  end
  describe '#store' do
    it 'returns nil' do
      expect(machine.store Drink.redbull).to be_nil
    end
    context 'when store new drink' do
      it 'adds new stock_info' do
        expect{machine.store Drink.water}.to change{machine.stock_info[:water]}.from(nil)
      end
      it 'increments stock' do
        machine.store Drink.water
        expect(machine.stock_info[:water][:stock]).to eq 1
      end
    end
    context 'when store more' do
      before do
        machine.store Drink.water
      end
      it 'increments stock' do
        expect{machine.store Drink.water}.to change{machine.stock_info[:water][:stock]}.from(1).to(2)
      end
    end
  end
end
