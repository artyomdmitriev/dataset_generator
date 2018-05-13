require 'pickup'
require 'ffaker'

module DatasetGenerator
  class ProductGenerator
    include FileUtils
    include DatasetCorruptor
    include Benchmark

    DEFAULT_BOOL_VALUE = false
    DEFAULT_RECORDS_AMOUNT = 1
    DEFAULT_BK_START_VALUE = 1
    DEFAULT_BK_PREFIX = '' # PROD
    DEFAULT_BK_PATTERN = '%.i' # '%.6i'
    DEFAULT_BK_POSTFIX = ''
    DEFAULT_PRICE_RANGE = {1 => 1}

    DEFAULT_FILE_PATH = Dir.pwd
    DEFAULT_FILE_NAME = 'output'
    DEFAULT_FILE_FORMAT = :csv
    DEFAULT_COLUMN_SEPARATOR = '|'

    DEFAULT_CORRUPTION_PERCENTAGE = 0
    DEFAULT_CORRUPTION_METHODS = {delete_item: 1, replace_with_sign: 1, add_sign: 1}

    DEFAULT_DATES = {Date.today => 1}
    DEFAULT_REVISIONS = {'v 0.1' => 1}
    DEFAULT_SALES_START_DATE_PATTERN = '%d%m%Y'
    DEFAULT_SALES_END_DATE_PATTERN = '%d%m%Y'

    def initialize(params={})
      @need_file = params[:need_file] || DEFAULT_BOOL_VALUE
      @file_path = params[:file_path] || DEFAULT_FILE_PATH
      @file_name = params[:file_name] || DEFAULT_FILE_NAME
      @file_format = params[:file_format] || DEFAULT_FILE_FORMAT
      @col_separator = params[:col_separator] || DEFAULT_COLUMN_SEPARATOR

      @need_corruption = params[:need_corruption] || DEFAULT_BOOL_VALUE
      @corruption_percentage = params[:corruption_percentage] || DEFAULT_CORRUPTION_PERCENTAGE
      @corruption_methods = params[:corruption_methods] || DEFAULT_CORRUPTION_METHODS

      @records_amount = params[:records_amount]
      @need_bk = params[:need_bk] || DEFAULT_BOOL_VALUE
      @bk_start_value = params[:bk_start_value] || DEFAULT_BK_START_VALUE
      @bk_prefix = params[:bk_prefix] || DEFAULT_BK_PREFIX
      @bk_postfix = params[:bk_postfix] || DEFAULT_BK_POSTFIX
      @bk_pattern = params[:bk_patter] || DEFAULT_BK_PATTERN
      @need_brand = params[:need_brand] || DEFAULT_BOOL_VALUE
      @need_product_name = params[:need_product_name] || DEFAULT_BOOL_VALUE
      @need_price = params[:need_price] || DEFAULT_BOOL_VALUE
      @price_range = params[:price_range] || DEFAULT_PRICE_RANGE
      @need_sales_start_date = params[:need_sales_start_date] || DEFAULT_BOOL_VALUE
      @sales_start_date = params[:sales_start_date] || DEFAULT_DATES
      @sales_start_date_pattern = params[:sales_start_date_pattern] || DEFAULT_SALES_START_DATE_PATTERN
      @need_sales_end_date = params[:need_sales_end_date] || DEFAULT_BOOL_VALUE
      @sales_end_date = params[:sales_end_date] || DEFAULT_DATES
      @sales_end_date_pattern = params[:sales_end_date_pattern] || DEFAULT_SALES_END_DATE_PATTERN
      @need_revision = params[:need_revision] || DEFAULT_BOOL_VALUE
      @revisions = params[:revisions] || DEFAULT_REVISIONS
    end

    def generate_products
      benchmark do
        result = []
        @records_amount.times do
          result << generate_product
        end
        result = generate_corruption result if @need_corruption
        generate_file(file_path: @file_path + '/' + @file_name + '.' +@file_format.to_s, records: result, col_sep: @col_separator) if @need_file
      end
    end

    def generate_product
      product = []
      product << generate_bk if @need_bk
      product << generate_brand if @need_brand
      product << generate_product_name if @need_product_name
      product << generate_price if @need_price
      product << generate_revision if @need_revision
      product << generate_start_date.strftime(@sales_start_date_pattern) if @need_start_date
      product << generate_end_date.strftime(@sales_end_date_pattern) if @need_end_date
      product
    end

    def generate_bk
      bk = "#{@bk_prefix}#{(@bk_pattern % @bk_start_value)}#{@bk_postfix}"
      @bk_start_value += 1
      bk
    end

    def generate_brand
      FFaker::Product.brand
    end

    def generate_product_name
      FFaker::Product.product_name
    end

    def generate_price
      if @price_range.class == Array
        hash = {}
        @price_range.each {|i| hash[i] = 1 }
        @price_range = hash
      end
      Pickup.new(@price_range).pick
    end

    def generate_revision
      Pickup.new(@revisions).pick
    end

    def generate_start_date
      Pickup.new(@sales_start_date).pick
    end

    def generate_end_date
      Pickup.new(@sales_end_date).pick
    end

    def generate_corruption array
      new_array = []
      array.each do |i|
        if(Random.new.rand(1..100) <= @corruption_percentage)
          new_array << corrupt_line(i, @corruption_methods)
        else
          new_array << i
        end
      end
      new_array
    end
  end
end