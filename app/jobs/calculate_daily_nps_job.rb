class CalculateDailyNpsJob < ApplicationJob
  def perform
    promoters_count = Review.where(rating: 5).count
    passives_count = Review.where(rating: 4).count
    detractors_count = Review.where(rating: [ 1, 2, 3 ]).count
    reviews_count = promoters_count + passives_count + detractors_count

    global_nps = ((promoters_count - detractors_count).to_f / reviews_count * 100).round(2)

    NetPromoterScore.create!(
      promoters_count:,
      passives_count:,
      detractors_count:,
      reviews_count: reviews_count,
      daily_score: global_nps
    )
  end
end
