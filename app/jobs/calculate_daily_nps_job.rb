class CalculateDailyNpsJob < ApplicationJob
  def perform
    return if NetPromoterScore.where(created_at: Date.today.all_day).exists?
    return if Review.blank?

    generate_global_nps
    generate_nps_by_company
  end

  def generate_nps_by_company
    Company.joins(:reviews)
           .select(
              "companies.id",
              "COUNT(*) FILTER (WHERE reviews.rating = 5) as promoters_count",
              "COUNT(*) FILTER (WHERE reviews.rating = 4) as passives_count",
              "COUNT(*) FILTER (WHERE reviews.rating IN (1,2,3)) as detractors_count"
            )
           .group("companies.id")
           .find_each do |company|
      create_nps_record(
        promoters_count: company.promoters_count.to_i,
        passives_count: company.passives_count.to_i,
        detractors_count: company.detractors_count.to_i,
        company: company
      )
    end
  end

  def generate_global_nps
    result = Review.select(
        "COUNT(*) FILTER (WHERE rating = 5) as promoters_count",
        "COUNT(*) FILTER (WHERE rating = 4) as passives_count",
        "COUNT(*) FILTER (WHERE rating IN (1,2,3)) as detractors_count"
      ).take

    create_nps_record(
      promoters_count: result.promoters_count.to_i,
      passives_count: result.passives_count.to_i,
      detractors_count: result.detractors_count.to_i
    )
  end

  def create_nps_record(promoters_count:, passives_count:, detractors_count:, company: nil)
    reviews_count = promoters_count + passives_count + detractors_count
    nps_score = calculate_nps(promoters_count, detractors_count, reviews_count)

    NetPromoterScore.create!(
      company: company,
      promoters_count: promoters_count,
      passives_count: passives_count,
      detractors_count: detractors_count,
      reviews_count: reviews_count,
      daily_score: nps_score
    )
  end

  def calculate_nps(promoters_count, detractors_count, reviews_count)
    return 0.0 if reviews_count.zero?

    ((promoters_count - detractors_count).to_f / reviews_count * 100).round(2)
  end
end
