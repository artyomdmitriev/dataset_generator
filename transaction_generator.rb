module DatasetGenerator
  class TransactionGenerator
    include FileUtils
    include DatasetCorruptor
    include Benchmark

    DEFAULT_INIT_PARAMS = {}
    DEFAULT_COLUMN_SEPARATOR = '|'
    DEFAULT_CORRUPTION_PERCENTAGE = 0
    DEFAULT_CORRUPTION_METHODS = {delete_item: 1, replace_with_sign: 1, add_sign: 1}
    DEFAULT_FILE_PATH = Dir.pwd
    DEFAULT_FILE_NAME = 'output'
    DEFAULT_FILE_FORMAT = :csv
    DEFAULT_BOOL_VALUE = false
    DEFAULT_RECORDS_AMOUNT = 1
    DEFAULT_BK_START_VALUE = 1
    DEFAULT_BK_PREFIX = '' # USR
    DEFAULT_BK_PATTERN = '%.i' # '%.6i'
    DEFAULT_BK_POSTFIX = ''

    DEFAULT_TRANSACTION_DATES = {Date.today => 1}
    DEFAULT_TRANSACTION_DATE_PATTERN = '%d%m%Y'

    def initialize(params={})
      @need_file = params[:need_file] || DEFAULT_BOOL_VALUE
      @file_path = params[:file_path] || DEFAULT_FILE_PATH
      @file_name = params[:file_name] || DEFAULT_FILE_NAME
      @file_format = params[:file_format] || DEFAULT_FILE_FORMAT
      @col_separator = params[:col_separator] || DEFAULT_COLUMN_SEPARATOR

      @need_corruption = params[:need_corruption] || DEFAULT_BOOL_VALUE
      @corruption_percentage = params[:corruption_percentage] || DEFAULT_CORRUPTION_PERCENTAGE
      @corruption_methods = params[:corruption_methods] || DEFAULT_CORRUPTION_METHODS

      @records_amount = params[:records_amount] || DEFAULT_RECORDS_AMOUNT

      @need_bk = params[:need_bk] || DEFAULT_BOOL_VALUE
      @bk_start_value = params[:bk_start_value] || DEFAULT_BK_START_VALUE
      @bk_prefix = params[:bk_prefix] || DEFAULT_BK_PREFIX
      @bk_postfix = params[:bk_postfix] || DEFAULT_BK_POSTFIX
      @bk_pattern = params[:bk_patter] || DEFAULT_BK_PATTERN

      @need_transaction_date = params[:need_transaction_date] || DEFAULT_BOOL_VALUE
      @transaction_dates = params[:transaction_dates] || DEFAULT_TRANSACTION_DATES
      @transaction_date_pattern = params[:transaction_date_pattern] || DEFAULT_TRANSACTION_DATE_PATTERN

      @need_user = params[:need_user] || DEFAULT_BOOL_VALUE
      @user_params = params[:user_params] || DEFAULT_INIT_PARAMS
      @need_product = params[:need_product] || DEFAULT_BOOL_VALUE
      @product_params = params[:product_params] || DEFAULT_INIT_PARAMS
    end

    def generate_transactions
      benchmark do
        result = []
        @records_amount.times { result << generate_transaction }
        result = generate_corruption result if @need_corruption
        generate_file(file_path: @file_path + '/' + @file_name + '.' +@file_format.to_s, records: result, col_sep: @col_separator) if @need_file
      end
    end

    def generate_transaction
      transaction = []
      transaction << generate_bk if @need_bk
      transaction << generate_transaction_date.strftime(@transaction_date_pattern) if @need_transaction_date
      transaction << generate_user if @need_user
      transaction << generate_product if @need_product
      transaction.flatten!
    end

    def generate_transaction_date
      Pickup.new(@transaction_dates).pick
    end

    def generate_bk
      bk = "#{@bk_prefix}#{(@bk_pattern % @bk_start_value)}#{@bk_postfix}"
      @bk_start_value += 1
      bk
    end

    def generate_user
      DatasetGenerator::UserGenerator.new(@user_params).generate_user
    end

    def generate_product
      DatasetGenerator::ProductGenerator.new(@product_params).generate_product
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