require 'rspec'
require './drink'

describe Drink do
  describe "==" do
    specify { expect(Drink.cola).to eq Drink.cola }
  end

  describe "eql?" do
    specify { expect(Drink.cola).to eql Drink.cola }
  end

  describe "hash" do
    specify { expect(Drink.cola.hash).to eql Drink.cola.hash }
  end
end
