require 'rubygems'
require 'spork'
require 'rspec'

Dir[File.join(File.dirname(__FILE__), "..", "lib", "**/*.rb")].each do |f|
  require f
end

Spork.prefork do
end

Spork.each_run do
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
end
