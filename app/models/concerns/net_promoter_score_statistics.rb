module NetPromoterScoreStatistics
  extend ActiveSupport::Concern

  def percentages
    @percentages ||= {
      total: reviews_count,
      promoters: calculate_percentage(promoters_count),
      passives: calculate_percentage(passives_count),
      detractors: calculate_percentage(detractors_count)
    }
  end

  def gauge_arc_lengths
    @gauge_arc_lengths ||= {
      promoters_arc: percentage_to_arc(percentages[:promoters]),
      passives_arc: percentage_to_arc(percentages[:passives]),
      detractors_arc: percentage_to_arc(percentages[:detractors])
    }
  end

  private

  def calculate_percentage(count)
    return 0 if reviews_count.zero?
    ((count.to_f / reviews_count) * 100).round
  end

  def percentage_to_arc(percentage)
    # 75 for a 3/4 circle
    (percentage / 100.0 * 75).round(2)
  end
end
