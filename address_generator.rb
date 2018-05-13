require 'ffaker'
require 'pickup'

module DatasetGenerator
  class AddressGenerator
    include FileUtils
    include DatasetCorruptor
    include Benchmark

    DEFAULT_BOOL_VALUE = false
    DEFAULT_RECORDS_AMOUNT = 1
    DEFAULT_COUNTRIES = {'Canada' => 1,
                         'Korea' => 1,
                         'Denmark' => 1,
                         'Germany' => 1,
                         'Finland' => 1,
                         'Greece' => 1,
                         'Japan' => 1,
                         'Netherlands' => 1,
                         'Poland' => 1,
                         'Russia' => 1}

    DEFAULT_BK_START_VALUE = 1
    DEFAULT_BK_PREFIX = '' # PROD
    DEFAULT_BK_PATTERN = '%.i' # '%.6i'
    DEFAULT_BK_POSTFIX = ''

    DEFAULT_FILE_PATH = Dir.pwd
    DEFAULT_FILE_NAME = 'output'
    DEFAULT_FILE_FORMAT = :csv
    DEFAULT_COLUMN_SEPARATOR = '|'

    DEFAULT_CORRUPTION_PERCENTAGE = 0
    DEFAULT_CORRUPTION_METHODS = {delete_item: 1, replace_with_sign: 1, add_sign: 1}

    def initialize(params={})
      @need_file = params[:need_file] || DEFAULT_BOOL_VALUE
      @file_path = params[:file_path] || DEFAULT_FILE_PATH
      @file_name = params[:file_name] || DEFAULT_FILE_NAME
      @file_format = params[:file_format] || DEFAULT_FILE_FORMAT
      @col_separator = params[:col_separator] || DEFAULT_COLUMN_SEPARATOR

      @records_amount = params[:records_amount] || DEFAULT_RECORDS_AMOUNT
      @need_countries = params[:need_countries] || DEFAULT_BOOL_VALUE
      @countries = params[:countries] || DEFAULT_COUNTRIES
      @need_states = params[:need_states] || DEFAULT_BOOL_VALUE
      @need_cities = params[:need_cities] || DEFAULT_BOOL_VALUE
      @need_streets = params[:need_streets] || DEFAULT_BOOL_VALUE
      @need_zips = params[:need_zips] || DEFAULT_BOOL_VALUE

      @need_corruption = params[:need_corruption] || DEFAULT_BOOL_VALUE
      @corruption_percentage = params[:corruption_percentage] || DEFAULT_CORRUPTION_PERCENTAGE
      @corruption_methods = params[:corruption_methods] || DEFAULT_CORRUPTION_METHODS

      @need_bk = params[:need_bk] || DEFAULT_BOOL_VALUE
      @bk_start_value = params[:bk_start_value] || DEFAULT_BK_START_VALUE
      @bk_prefix = params[:bk_prefix] || DEFAULT_BK_PREFIX
      @bk_postfix = params[:bk_postfix] || DEFAULT_BK_POSTFIX
      @bk_pattern = params[:bk_patter] || DEFAULT_BK_PATTERN
    end

    def ffaker_address_class country
      case country
        when 'Canada' then FFaker::AddressAU
        when 'Korea' then FFaker::AddressKR
        when 'Denmark' then FFaker::AddressDA
        when 'Germany' then FFaker::AddressDE
        when 'Finland' then FFaker::AddressFI
        when 'Greece' then FFaker::AddressGR
        when 'Japan' then FFaker::AddressJA
        when 'Netherlands' then FFaker::AddressNL
        when 'Poland' then FFaker::AddressPL
        when 'Russia' then FFaker::AddressRU
        else FFaker::Address
      end
    end

    def generate_addresses
      benchmark do
        result = []
        @records_amount.times do
          result << generate_address
        end
        result = generate_corruption result if @need_corruption
        generate_file(file_path: @file_path + '/' + @file_name + '.' + @file_format.to_s, records: result, col_sep: @col_separator) if @need_file
      end
    end

    def generate_address
      country = Pickup.new(@countries).pick
      ffaker = ffaker_address_class(country)
      result = []
      result << generate_bk if @need_bk
      result << country if @need_countries
      result << generate_zip(ffaker) if @need_zips
      result << generate_state(ffaker) if @need_states
      result << generate_city(ffaker) if @need_cities
      result << generate_street(ffaker) if @need_streets
      result << generate_building(ffaker) if @need_buildings
      result
    end

    def generate_zip ffaker_address
      if defined?(ffaker_address.zip_code)
        ffaker_address.zip_code
      elsif defined?(ffaker_address.postal_code)
        ffaker_address.postal_code
      else
        nil
      end
    end

    def generate_state ffaker_address
      if defined?(ffaker_address.state)
        ffaker_address.state
      else
        nil
      end
    end

    def generate_city ffaker_address
      if defined?(ffaker_address.city)
        ffaker_address.city
      else
        nil
      end
    end

    def generate_street ffaker_address
      if defined?(ffaker_address.street_name)
        ffaker_address.street_name
      elsif defined?(ffaker_address.street)
        ffaker_address.street
      else
        nil
      end
    end

    def generate_building ffaker_address
      if defined?(ffaker_address.building_number)
        ffaker_address.building_number
      else
        Random.rand(1..99)
      end
    end

    def generate_bk
      bk = "#{@bk_prefix}#{(@bk_pattern % @bk_start_value)}#{@bk_postfix}"
      @bk_start_value += 1
      bk
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