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

    companies_created_count = 0
    reviews_created_count = 0
    duplicate_rows_count = 0
    duplicates = []

    puts "Starting import..."

    CSV.foreach(file_path, headers: true).with_index(1) do |row, line_number|
      company = Company.find_or_create_by!(name: row["company_name"])
      if company.previously_new_record?
        companies_created_count += 1
        puts "🏢 Company created"
      end

      review = Review.new(clean_row(row, company))
      if review.save
        reviews_created_count += 1
        puts "✨ Review created"
      end

    rescue ActiveRecord::RecordNotUnique
      puts "⏩ Skip - Duplicate review detected"
      duplicate_rows_count += 1
      duplicates << {
        line_number: line_number,
        company: row["company_name"],
        channel: row["channel"],
        rating: row["rating"],
        date: row["date"],
        title: row["title"],
        description: row["title"]
      }

    rescue StandardError => e
      puts "⚠️ Error: #{e.messsage}"
    end

    puts
    puts "=" * 70
    puts "Import complete ✅"
    puts
    puts "Companies created: #{companies_created_count}"
    puts "Reviews created: #{reviews_created_count}"
    puts "Duplicate rows found: #{duplicate_rows_count}"
    puts

    puts "=" * 70
    if duplicates.any?
      puts "Duplicates reviews skipped:"
      puts
      duplicates.each do |dup|
        puts
        puts "-" * 70
        puts "Line #{dup[:line_number]}"
        puts "Company: #{dup[:company]}"
        puts "Channel: #{dup[:channel]}"
        puts "Date: #{dup[:date]}"
        puts "Rating: #{dup[:rating]}"
        puts "Description: \"#{dup[:description]}\""
      end
    end
    puts "=" * 70
  end
end

def clean_row(row, company)
  {
    company: company,
    channel: row["channel"].downcase,
    rating: normalize_rating(row["rating"]),
    date: Date.parse(row["date"]),
    title: row["title"],
    description: normalize_description_for_uniqueness(row["description"])
  }
end

def normalize_rating(row_rating)
  row_rating = row_rating.to_i

  case row_rating
  when 1..5
    row_rating
  when 6..10
    # convert 10-point scale rating to 5-point scale
    # 10 -> 5, 9 -> 5, 8 -> 4, 7 -> 4, 6 -> 3
    (row_rating / 2.0).round
  else
    nil
  end
end

def normalize_description_for_uniqueness(description)
  return "" if description.blank?

  description
end
