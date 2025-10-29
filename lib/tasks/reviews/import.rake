require "csv"

namespace :reviews do
  desc "Import reviews from CSV file"
  task :import, [ :file_path ] => :environment do |_t, args|
    file_path = args[:file_path]

    if file_path.blank?
      puts "❌ File missing"
      exit
    end

    if !File.exist?(file_path)
      puts "❌ File not found"
      exit
    end

    puts "Starting import..."

    CSV.foreach(file_path, headers: true) do |row|
      puts "Create company"
      company = Company.find_or_create_by!(name: row["company_name"])

      puts "Create review"
      Review.create!(
        company: company,
        channel: row["channel"].downcase,
        rating: row["rating"].to_i,
        date: Date.parse(row["date"]),
        title: row["title"] || nil,
        description: row["description"] || nil
      )
    end

    puts "Import complete ✅"
  end
end
