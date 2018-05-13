require 'pickup'

module DatasetGenerator
  module DatasetCorruptor
    def corrupt_line(line, params={delete_item: 1, replace_with_sign: 1, add_sign: 1})
      method = Pickup.new(params)
      result = []
      line.each do |i|
        result << send(method.pick, i.to_s)
      end
      result
    end

    def delete_item item
      nil
    end

    def replace_with_sign item
      if item.nil? || item.size == 0
        nil
      else
        item[Random.new.rand(0..item.size-1)] << %w[! # $].sample
      end
    end

    def add_sign item
      item + %w[! # $].sample
    end
  end
end