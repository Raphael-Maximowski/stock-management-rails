class CartsController < ApplicationController
    before_action :set_cart_service

    def index
        carts = @cart_service.list_carts()
        render_cart_with_products(carts)
    end

    def show
        @cart = @cart_service.find_cart(params[:id])
        render_cart_with_products() 
    end

    def create
        @cart = @cart_service.create_cart(create_cart_params)
        render json: @cart, status: :created 
    end

    def insert_product
        @product = @cart_service.insert_product_in_cart(
            params[:id], 
            params[:product_id], 
            cart_product_params
        )
        render json: @product, status: :created
    end

    def remove_product
        @cart_service.remove_product_from_cart(
            params[:id], 
            params[:product_id], 
            cart_product_params
        )
        head :no_content
    end

    def find_user_cart
        @cart = @cart_service.find_user_cart(params[:user_id])
        render_cart_with_products()
    end

    def remove_all_products
        @cart = @cart_service.find_and_remove_all_cart_products(checkout_and_remove_all_params)
        head :no_content
    end

    def checkout
        @cart = @cart_service.cart_checkout(checkout_and_remove_all_params)
        render json: @cart, status: :ok
        head :no_content 
    end

    private

    def render_cart_with_products(cartsData = @cart)
        render  json: cartsData, 
                include: { cart_products: { include: :product } },
                status: :ok
    end

    def set_cart_service
        @cart_service = CartService.new
    end 

    def checkout_and_remove_all_params
        params.permit(:user_id, :id).to_h
    end

    def cart_product_params
        params.permit(:quantity, :user_id).to_h
    end

    def create_cart_params
        params.permit(:user_id).to_h
    end
end