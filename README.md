## VendingMachine

Sample implementation for http://devtesting.jp/tddbc/?TDDBC%E5%A4%A7%E9%98%AA2.0%2F%E8%AA%B2%E9%A1%8C

### How to use

````
$ irb
> require './lib/drink'
> require './lib/vending_machine'
> machine = VendingMachine.new # has 5 cola-s by default, price: 120
> machine.insert 10
=> nil
> machine.insert 100
=> nil
> machine.insert 1
=> 1
> machine.total
=> 110
> machine.change
=> 110
> machine.total
=> 0
> machine.insert 10
> machine.insert 10
> machine.insert 100
> machine.purchase :cola
=> [<Drink: name=cola, price=120>, 0]
> machine.total
=> 0
> machine.store Drink.redbull # price: 200
> machine.store Drink.water # price: 100
> machine.insert 1000
> machine.available_drink_names
=> [:cola, :redbull, :water]
> machine.purchase :redbull
=> [<Drink: name=redbull, price=200>, 800]
> machine.sale_amount
=> 320
> machine.insert 100
> machine.can_purchase? :water
=> true
> machine.can_purchase? :cola
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
