class Api::V1::ReviewsController < ApplicationController
  before_action :load_book, only: :index
  before_action :load_review, only: %i[show update]
  before_action :ensure_params_exist, only: %i[create update]
  before_action :authenticate_with_token!, only: %i[create update destroy]

  def index
    @reviews = Review.all
    json_response 'index reviews successfully', true, { reviews: @reviews }, :ok
  end

  def show
    json_response 'show review successfully', true, { review: @review }, :ok
  end

  def create
    review = Review.new review_params
    review.user_id = current_user.id
    review.book_id = params[:book_id]
    if review.save
      json_response 'created review successfully', true, { review: }, :ok
    else
      json_response 'created review fail', false, {}, :unprocessable_entity
    end
  end

  def update
    if correct_user @review.user
      if @review.update review_params
        json_response 'updated review successfully', true, { review: @review }, :ok
      else
        json_response 'updated review fail', false, {}, :unprocessable_entity
      end
    else
      json_response 'you dont have permission to do this', false, {}, :unauthorized
    end
  end

  def destroy
    if correct_user @review.user
      if @review.destroy
        json_response 'deleted review successfully', true, { review: @review }, :ok
      else
        json_response 'deleted review fail', false, {}, :unprocessable_entity
      end
    else
      json_response 'you dont have permission to do this', false, {}, :unauthorized
    end
  end

  private

  def load_book
    @book = Book.find_by id: params[:book_id]
    return if @book.present?

    json_response 'can not find a book', false, {}, :not_found
  end

  def load_review
    @review = Review.find_by id: params[:id]
    return if @review.present?

    json_response 'can not find a review', false, {}, :not_found
  end

  def review_params
    params.require(:review).permit(:title, :content_rating, :recommend_rating)
  end

  def ensure_params_exist
    return if params[:review].present?

    json_response 'missing params', false, {}, :bad_request
  end
end
