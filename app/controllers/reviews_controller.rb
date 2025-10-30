class ReviewsController < ApplicationController
  def index
    @pagy, @reviews = pagy(Review.includes(:company), limit: 12)
  end
end
