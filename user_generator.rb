require 'pickup'
require 'ffaker'

module DatasetGenerator
  class UserGenerator
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
    DEFAULT_COUNTRIES = {'Canada' => 1, 'Korea' => 1}
    DEFAULT_GENDERS = {male: 1, female: 1}
    DEFAULT_AGE_GAP = (1..99).to_a
    DEFAULT_EMAIL_DOMAINS = {'gmail.com' => 1, 'live.com' => 1}
    DEFAULT_EMAIL_SEPARATORS = {'-' => 1, '.' => 1, '_' => 1}
    DEFAULT_SKILLS_AMOUNT = 1
    DEFAULT_SKILLS_SEPARATOR = ','

    def initialize(params={})
      @address_params = params[:address_params] || DEFAULT_INIT_PARAMS

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

      @need_first_name = params[:need_first_name] || DEFAULT_BOOL_VALUE
      @need_last_name = params[:need_last_name] || DEFAULT_BOOL_VALUE
      @need_gender = params[:gender] || DEFAULT_COUNTRIES
      @genders = params[:gender_options] || DEFAULT_GENDERS
      @countries = params[:countries] || DEFAULT_COUNTRIES
      @need_age = params[:need_age] || DEFAULT_BOOL_VALUE
      @age_gap = params[:age_gap] || DEFAULT_AGE_GAP
      @need_email_address = params[:need_email_address] || DEFAULT_BOOL_VALUE
      @email_domains = params[:email_domains] || DEFAULT_EMAIL_DOMAINS
      @email_separators = params[:email_separators] || DEFAULT_EMAIL_SEPARATORS
      @need_address = params[:need_address] || DEFAULT_BOOL_VALUE
      @need_skill = params[:need_skill] || DEFAULT_BOOL_VALUE
      @need_skills = params[:need_skills] || DEFAULT_BOOL_VALUE
      @skills_amount = params[:skills_amount] || DEFAULT_SKILLS_AMOUNT
      @skills_separator = params[:skills_separator] || DEFAULT_SKILLS_SEPARATOR
      @need_ip = params[:need_ip] || DEFAULT_BOOL_VALUE
    end

    def generate_users
      benchmark do
        result = []
        @records_amount.times do
          result << generate_user
        end
        result = generate_corruption(result) if @need_corruption
        generate_file(file_path: @file_path + '/' + @file_name + '.' +@file_format.to_s, records: result, col_sep: @col_separator) if @need_file
      end
    end

    def generate_user
      country = Pickup.new(@countries).pick
      gender = Pickup.new(@genders).pick
      ffaker = ffaker_name_class(country)
      result = []
      first_name = generate_first_name(ffaker, gender) if @need_first_name
      last_name = generate_last_name(ffaker, gender) if @need_last_name
      result << generate_bk if @need_bk
      result << first_name if @need_first_name
      result << last_name if @need_last_name
      result << generate_gender(gender) if @need_gender
      result << generate_age if @need_age
      result << generate_email_address(first_name, last_name) if @need_email_address
      result << DatasetGenerator::AddressGenerator.new(@address_params).generate_address if @need_address
      result << generate_skill if @need_skill
      result << generate_skills.join(@skills_separator) if @need_skills
      result << generate_ip if @need_ip
      result.flatten
    end

    def ffaker_name_class country
      case country
        when 'Korea' then FFaker::NameKR
        when 'Denmark' then FFaker::NameDA
        when 'Germany' then FFaker::NameDE
        when 'Greece' then FFaker::NameGR
        when 'Japan' then FFaker::NameJA
        when 'Netherlands' then FFaker::NameNL
        when 'Poland' then FFaker::NamePL
        when 'Russia' then FFaker::NameRU
        else FFaker::Name
      end
    end

    def generate_bk
      bk = "#{@bk_prefix}#{(@bk_pattern % @bk_start_value)}#{@bk_postfix}"
      @bk_start_value += 1
      bk
    end

    def generate_first_name ffaker_name, gender
      if gender == :male && defined?(ffaker_name.first_name_male)
        ffaker_name.first_name_male
      elsif gender == :female && defined?(ffaker_name.first_name_female)
        ffaker_name.first_name_female
      elsif defined?(ffaker_name.first_name)
      ffaker_name.first_name
      end
    end

    def generate_last_name ffaker_name, gender
      if gender == :male && defined?(ffaker_name.last_name_male)
        ffaker_name.last_name_male
      elsif gender == :female && defined?(ffaker_name.last_name_female)
        ffaker_name.last_name_female
      elsif defined?(ffaker_name.last_name)
        ffaker_name.last_name
      end
    end

    def generate_gender gender
      gender.to_s.capitalize
    end

    def generate_age
      if @age_gap.class == Array
        hash = {}
        @age_gap.each {|i| hash[i] = 1 }
        @age_gap = hash
      end
      Pickup.new(@age_gap).pick
    end

    def generate_email_address first_name, last_name
      "#{first_name}#{Pickup.new(@email_separators).pick}#{last_name}@#{Pickup.new(@email_domains).pick}"
    end

    def generate_skill
      FFaker::Skill.tech_skill
    end

    def generate_skills
      FFaker::Skill.tech_skills(@skills_amount)
    end

    def generate_ip
      FFaker::Internet.ip_v4_address
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