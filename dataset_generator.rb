module DatasetGenerator
  VERSION = 0.1

  autoload :UserGenerator, './user_generator.rb'
  autoload :AddressGenerator, './address_generator.rb'
  autoload :ProductGenerator, './product_generator.rb'
  autoload :TransactionGenerator, './transaction_generator.rb'
  autoload :FileUtils, './file_utils.rb'
  autoload :DatasetCorruptor, './dataset_corruptor.rb'
  autoload :Benchmark, './benchmark.rb'
end