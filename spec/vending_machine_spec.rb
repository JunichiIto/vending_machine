require 'rspec'
require './vending_machine'

describe VendingMachine do
  let(:machine) { VendingMachine.new }
  describe "step 1" do
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
    end
  end
end
