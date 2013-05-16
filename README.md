## VendingMachine

Sample implementation for [TDDBC Osaka 2.0](http://devtesting.jp/tddbc/?TDDBC%E5%A4%A7%E9%98%AA2.0%2F%E8%AA%B2%E9%A1%8C)


Naming convention is taken from [here](http://devtesting.jp/tddbc/?TDDBC%E4%BB%99%E5%8F%B002%2F%E8%AA%B2%E9%A1%8C%E7%94%A8%E8%AA%9E%E9%9B%86).

### How to use

````
$ irb
> require './lib/vending_machine'
> machine = VendingMachine.new
> machine.stock_info # => {:cola=>{:price=>120, :stock=>5}}
> machine.store Drink.redbull
> machine.store Drink.water
> machine.stock_info # => {:cola=>{:price=>120, :stock=>5}, :redbull=>{:price=>200, :stock=>1}, :water=>{:price=>100, :stock=>1}}
> machine.insert 10
> machine.insert 50
> machine.total # => 60
> machine.refund # => 60
> machine.total # => 0
> machine.insert 100
> machine.purchasable_drink_names # => [:water]
> machine.purchasable? :water # => true
> machine.purchasable? :cola # => false
> machine.purchasable? :redbull # => false
> machine.insert 50
> machine.purchasable_drink_names # => [:cola, :water]
> machine.purchasable? :cola # => true
> machine.insert 100
> machine.purchasable_drink_names # => [:cola, :redbull, :water]
> machine.purchasable? :redbull # => true
> machine.total # => 250
> machine.purchase :redbull # => [<Drink: name=redbull, price=200>, 50]
> machine.total # => 0
> machine.refund # => 0
> machine.stock_info # => {:cola=>{:price=>120, :stock=>5}, :redbull=>{:price=>200, :stock=>0}, :water=>{:price=>100, :stock=>1}}
> exit
````

### How to test

````
$ bundle install
$ bundle exec rspec
or
$ bundle exec guard
````
