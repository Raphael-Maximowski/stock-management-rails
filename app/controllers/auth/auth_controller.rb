class Auth::AuthController < ApplicationController
  skip_before_action :authenticate_request

  def initialize
    @user_service = UserService.new
  end

  def login
    @user_data = @user_service.user_login(user_params)
    render json: @user_data, status: :created
  end

  def register
    @user_data = @user_service.user_register(user_params)
    render json: @user_data, status: :created
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation, :name).to_h
  end
end