## VendingMachine

Sample implementation for http://devtesting.jp/tddbc/?TDDBC%E5%A4%A7%E9%98%AA2.0%2F%E8%AA%B2%E9%A1%8C

### How to use

````
$ irb
> require './lib/drink'
> require './lib/vending_machine'
> machine = VendingMachine.new # has 5 cola-s by default, price: 120
> machine.insert_money 10
=> nil
> machine.insert_money 100
=> nil
> machine.insert_money 1
=> 1
> machine.total_money
=> 110
> machine.change
=> 110
> machine.total_money
=> 0
> machine.insert_money 10
> machine.insert_money 10
> machine.insert_money 100
> machine.buy :cola
=> [<Drink: name=cola, price=120>, 0]
> machine.total_money
=> 0
> machine.add_drink Drink.redbull # price: 200
> machine.add_drink Drink.water # price: 100
> machine.insert_money 1000
> machine.available_drink_names
=> [:cola, :redbull, :water]
> machine.buy :redbull
=> [<Drink: name=redbull, price=200>, 800]
> machine.sale
=> 320
> machine.insert_money 100
> machine.can_buy? :water
=> true
> machine.can_buy? :cola
=> false
> machine.change
=> 100
> machine.change
=> 0
> exit
````

### How to test

````
$ bundle install
$ bundle exec rspec
or
$ bundle exec guard
````
