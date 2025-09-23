class ProductsController < ApplicationController
    before_action :set_product_service

    def index
        products = @product_service.list_products()
        render json: products, status: :ok
    end

    def show
        @product = @product_service.find_product(params[:id])
        render json: @product, status: :ok
    end

    def create
        @product = @product_service.create_product(create_product_params)
        render json: @product, status: :created 
    end

    def update 
        @product = @product_service.update_product(update_product_params)
        render json: @product, status: :ok
    end

    def destroy
        @product_service.delete_product(params[:id])
        head :no_content
    end

    private
    
    def create_product_params
        params.permit(:available_stock, :price, :description, :name, :user_id).to_h
    end

    def update_product_params
        params.permit(:id, :available_stock, :price, :description, :name).to_h
    end

    def set_product_service
        @product_service = ProductService.new
    end 
end