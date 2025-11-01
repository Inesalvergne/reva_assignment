class ReviewsController < ApplicationController
  before_action :load_nps_data, only: %i[index]

  def index
    @pagy, @reviews = pagy(scoped_reviews, limit: 14)
    @filter_params = %w[company description ratings channels start_date end_date]
  end

  private

  def load_nps_data
    if params[:company].present?
      company = Company.find_by(name: params[:company])
      @nps = NetPromoterScore.find_by(company: company)
    else
      @nps = NetPromoterScore.global_nps
    end
  end

  def scoped_reviews
    @reviews = Review.includes(:company).order(:date)
    @reviews = @reviews.by_company(params[:company]) if params[:company].present?
    @reviews = @reviews.by_channels(params[:channels]) if params[:channels].present?
    @reviews = @reviews.by_ratings(params[:ratings]) if params[:ratings].present?
    @reviews = @reviews.by_date_range(params[:start_date], params[:end_date]) if params[:start_date].present? || params[:end_date].present?
    @reviews = @reviews.search_by_description(params[:description]) if params[:description].present?
    @reviews
  end
end
