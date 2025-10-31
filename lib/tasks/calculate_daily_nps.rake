desc "Calculate daily global and by company NPS"
task calculate_daily_nps: :environment do
  CalculateDailyNpsJob.perform_now
  puts "✅ NPS generated"
end
