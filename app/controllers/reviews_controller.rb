class ReviewsController < ApplicationController
  def index
    @reviews = Review.includes(:company)
  end
end
