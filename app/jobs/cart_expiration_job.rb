class CartExpirationJob < ApplicationJob
    queue_as :default

    def perform(cart_id)
        cart_service = CartService.new
        cart_service.set_cart_as_abandoned(cart_id)
    end
end