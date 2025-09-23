
class UsersController < ApplicationController
    before_action :set_user_service

    def index
        users = @user_service.list_users
        render json: users, status: :ok
    end

    def show
        @user = @user_service.find_user(params[:id])
        render json: @user, status: :ok
    end

    def create
        @user = @user_service.create_user(user_params)
        render json: @user, status: :created
    end

    def update
        @user = @user_service.update_user(user_params)
        render json: @user, status: :ok
    end

    def destroy
        @user_service.delete_user(params[:id])
        head :no_content
    end

    private

    def user_params
        params.permit(:id, :email, :name, :role).to_h
    end

    def set_user_service
        @user_service = UserService.new
    end 
end