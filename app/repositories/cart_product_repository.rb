class CartProductRepository
    def initialize
        @model = CartProduct
    end

    def find_cart_products(cart_id)
        @model.includes(:product)
            .where(cart_id: cart_id)
    end

    def quantity_amount_to_remove_available?(cart_id, product_id, quantity)
        @model.where(cart_id: cart_id, product_id: product_id).where("quantity >= ?", quantity).exists?
    end

    def cart_has_product?(cart_id, product_id)
        @model.where(cart_id: cart_id, product_id: product_id).exists?
    end

    def cart_has_any_product?(cart_id)
        @model.where(cart_id: cart_id).exists?
    end
end