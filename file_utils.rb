require 'csv'

module DatasetGenerator
  module FileUtils
    def generate_file params
      CSV.open(params[:file_path], 'w', col_sep: params[:col_sep]) do |csv|
        params[:records].each do |i|
          csv << i
        end
      end
    end
  end
end