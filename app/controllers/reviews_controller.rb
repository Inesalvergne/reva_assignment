class ReviewsController < ApplicationController
  def index
    @pagy, @reviews = pagy(scoped_reviews, limit: 12)
  end

  private

  def scoped_reviews
    @reviews = Review.includes(:company).order(:date)

    @reviews = @reviews.by_company(params[:company]) if params[:company].present?
    @reviews = @reviews.by_channels(params[:channels]) if params[:channels].present?
    @reviews = @reviews.by_ratings(params[:ratings]) if params[:ratings].present?
    @reviews = @reviews.by_date_range(params[:start_date], params[:end_date]) if params[:start_date].present? || params[:end_date].present?

    @reviews
  end
end
