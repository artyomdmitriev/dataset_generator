module DatasetGenerator
  module Benchmark
    def benchmark &block
      start_time = Time.now
      yield
      puts 'Required time: ' + (Time.now - start_time).to_s + 's'
    end
  end
end