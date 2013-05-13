require 'rspec'
require './drink'

describe Drink do
  describe "==" do
    specify { expect(Drink.cola).to eq Drink.cola }
  end
end
