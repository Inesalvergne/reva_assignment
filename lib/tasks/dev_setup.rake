task dev_setup: :environment do
  return if Rails.env.production?

  puts "Set up the DB"
  puts "-" * 70
  `rails db:drop db:create db:migrate`

  puts "Create playground data..."
  puts "-" * 70
  puts "Import Reviews from CSV file"
  Rake::Task["reviews:import"].invoke("./data/reviews.csv")
  puts "Calculate NPS"
  Rake::Task["nps:calculate_daily_nps"].invoke

  puts
  puts "-" * 70
  puts "Setup completed ✅"
  puts "-" * 70
end
