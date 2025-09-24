class CartRepository 
    def initialize(model = Cart)
        @model = model
    end

    def find(id)
        @model.includes(cart_products: :product)
            .find_by(id: id)
    end

    def find_cart_based_in_status(id, status)
        @model.includes(cart_products: :product)
            .find_by(id: id, cart_status: status)
    end

    def find_cart_by_user_id(user_id)
        @model.includes(cart_products: :product)
            .find_by(user_id: user_id, cart_status: 'active')
    end

    def list
        @model.includes(cart_products: :product).all
    end

    def update(cart, params)
        @cart = cart.update(params)
        @cart
    end
    
    def create(params)
        @model.create(params) 
    end

    def cart_exists_based_in_status?(id, cart_status)
        @model.where(id: id, cart_status: cart_status).exists?
    end

    def exists_active_cart_associated_to_user?(user_id)
        @model.where(cart_status: 'active', user_id: user_id).exists?
    end

    def cart_belongs_to_user?(cart_id, user_id)
        @model.where(id:cart_id, user_id: user_id).exists?
    end
end