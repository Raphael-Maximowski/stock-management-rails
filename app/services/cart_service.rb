class CartService
    include ErrorHandling

    def initialize(
            cart_repository = CartRepository.new, 
            cart_product_repository = CartProductRepository.new,
            product_service = ProductService.new,
            stock_reservation_service = StockReservationService.new,
            user_service = UserService.new 
        )

        @cart_product_repository = cart_product_repository
        @cart_repository = cart_repository 

        @product_service = product_service
        @stock_reservation_service = stock_reservation_service
        @user_service = user_service
    end

    def find_cart(id)
        @cart = @cart_repository.find(id) || raise_if_model_not_found!(@cart.nil?, 'Cart Not Found')
    end

    def list_carts
        @cart_repository.list
    end

    def create_cart(params)
        validate_manipulate_cart_schema(params)
        create_cart_business_rules(params)

        create_cart_with_expiration(params) 
        @cart
    end

    def set_cart_as_abandoned(cart_id)
        find_active_cart(cart_id)
        remove_all_products()
        update_cart({ cart_status: 'abandoned' })
    end

    def insert_product_in_cart(cart_id, product_id, params)
        validate_cart_product_schema(cart_id, product_id, params)
        validate_insert_product_business_rules(cart_id, product_id, params)

        @cart = @cart_repository.find(cart_id)
        @product = @product_service.find_product(product_id)

        Cart.transaction do
            @product.lock!
            cart_new_params = {
                total_items: @cart.total_items + params[:quantity],
                total_amount: @cart.total_amount + (@product.price * params[:quantity])
            }

            update_cart(cart_new_params) 
            increment_cart_product(params[:quantity])
            reserve_product(params[:quantity])          
        end
        @product
    end

    def remove_product_from_cart(cart_id, product_id, params)
        validate_cart_product_schema(cart_id, product_id, params)
        validate_remove_product_business_rules(cart_id, product_id, params)

        @cart = @cart_repository.find(cart_id)
        @product = @product_service.find_product(product_id)
        @cart_product = @cart.cart_products.find_by!(product_id: product_id)

        Cart.transaction do
            @product.lock!
            cart_new_params = {
                total_items: @cart.total_items - params[:quantity],
                total_amount: @cart.total_amount - (@product.price * params[:quantity])
            }

            update_cart(cart_new_params)
            decrement_cart_product(params[:quantity])
            release_product(params[:quantity])
        end

        @product
    end

    def find_user_cart(user_id)
        @cart = @cart_repository.find_cart_by_user_id(user_id)
        raise_if_model_not_found!(@cart.nil?, 'Cart Not Found')
        @cart
    end

    def find_and_remove_all_cart_products(params)
        validate_manipulate_cart_schema(params)
        validate_remove_all_products_business_rules(params)

        @cart = @cart_repository.find(params[:id])
        raise_if_model_not_found!(@cart.nil?, 'Cart Not Found')
        remove_all_products
    end

    def remove_all_products
        Cart.transaction do
            update_cart({ total_items: 0, total_amount: 0 })
            release_all_stock()
        end

        @cart
    end

    def cart_checkout(params)
        validate_manipulate_cart_schema(params)
        validate_checkout_business_rules(params)

        @cart = @cart_repository.find(params[:id])

        Cart.transaction do
            update_cart({ cart_status: 'completed' })
            set_reservations_as_completed()
        end

        @cart = @cart_repository.find(params[:id])
        @cart
    end

    private
    
    # Self Methods

    def set_reservations_as_completed
        cart_products = @cart_product_repository.find_cart_products(@cart[:id])

        cart_products.each do | cart_product |
            @product = @product_service.find_product(cart_product[:product_id])
            @product_service.update_product_stock_after_checkout(@product, cart_product[:quantity])
            @stock_reservation_service.completed(@product[:id], @cart[:id])
        end
    end

    def decrement_cart_product(quantity)
        @cart_product = @cart.cart_products.find_or_initialize_by(product_id: @product[:id])
        @cart_product.quantity -= quantity
        @cart_product.quantity == 0 ? @cart_product.destroy! : @cart_product.save!
    end

    def increment_cart_product(quantity)
        @cart_product = @cart.cart_products.find_or_initialize_by(product_id: @product[:id])
        @cart_product.quantity ||= 0
        @cart_product.quantity += quantity
        @cart_product.save!
    end

    def release_product(quantity)
        @product_service.update_product_stock_after_remove(@product, quantity)
        @stock_reservation_service.release(quantity, @product.id, @cart.id)
    end

    def reserve_product(quantity)
        @product_service.update_product_stock_after_insert(@product, quantity)
        @reservation = @stock_reservation_service.reserve(quantity, @product[:id], @cart[:id])
    end

    def release_all_stock
        cart_products = @cart_product_repository.find_cart_products(@cart[:id])

        cart_products.each do |cart_product |
            @product = @product_service.find_product(cart_product.product_id)
            @product.lock!
            release_product(cart_product.quantity)
            decrement_cart_product(cart_product.quantity)
        end
    end

    def update_cart(params)
        @cart_repository.update(@cart, params)
    end

    def find_active_cart(cart_id)
        @cart = @cart_repository.find_cart_based_in_status(cart_id, 'active')
        raise_if_business_rule_violated!(@cart.nil?, 'Cart Validation Failed', { cart_id: 'Invalid Cart' })
    end

    def create_cart_with_expiration(params)
        attributes = { **params, expires_at: 24.hours.from_now }
        @cart = @cart_repository.create(attributes)
        CartExpirationJob.set(wait: attributes[:expires_at] - Time.current).perform_later(@cart[:id])
    end


    # Schemas And Business Validation

    def validate_checkout_business_rules(params)
        @business_errors = {}

        unless validate_cart_available?(params[:id])
            @business_errors[:cart_id] = 'Invalid Cart'
            raise_if_business_rule_violated!(true, 'Cart Validation Failed', @business_errors)
        end

        unless validate_cart_belongs_to_user?(params[:id], params[:user_id])
            @business_errors[:user_id] = 'You Do Not Have Access To This Cart'
            raise_if_business_rule_violated!(true, 'Cart Validation Failed', @business_errors)
        end

        unless validate_cart_has_any_product?(params[:id])
            @business_errors[:cart_id] = 'Insert A Item Before Checkout'
            raise_if_business_rule_violated!(true, 'Cart Validation Failed', @business_errors)
        end
    end

    def validate_manipulate_cart_schema(params)
        schema_validation = CartManipulationSchema.new().call(params)
        raise_if_model_invalid!(schema_validation.failure?, 'Checkout Validation Failed', schema_validation.errors.to_h)
    end

    def validate_remove_product_base_business_rules(cart_id)
        @business_errors = {}

        unless validate_cart_available?(cart_id)
            @business_errors[:cart_id] = 'Invalid Cart'
            raise_if_business_rule_violated!(true, 'Cart Validation Failed', @business_errors)
        end
    end

    def validate_remove_all_products_business_rules(params)
        validate_remove_product_base_business_rules(params[:id])

        unless validate_cart_belongs_to_user?(params[:id], params[:user_id])
            @business_errors[:user_id] = 'You Do Not Have Access To This Cart'
            
            raise_if_business_rule_violated!(true, 'Cart Validation Failed', @business_errors)
        end

        unless validate_cart_has_any_product?(params[:id])
            @business_errors[:cart_id] = 'Empty Cart'
            raise_if_business_rule_violated!(true, 'Cart Validation Failed', @business_errors)
        end
    end

    def validate_remove_product_business_rules(cart_id, product_id, params)
        validate_remove_product_base_business_rules(cart_id)

        unless validate_quantity_amount_to_remove(cart_id, product_id, params[:quantity])
            @business_errors[:quantity] = 'Cannot Remove This Quantity'
            raise_if_business_rule_violated!(true, 'Cart Validation Failed', @business_errors)
        end

        unless validate_cart_has_product(cart_id, product_id)
            @business_errors[:product_id] = 'Insert This Item In Yout Cart First'
            raise_if_business_rule_violated!(true, 'Cart Validation Failed', @business_errors)
        end
    end

    def validate_insert_product_business_rules(cart_id, product_id, params)
        @business_errors = {}

        unless validate_product_available?(product_id, params[:quantity])
            @business_errors[:product_id] = "Not Available Product"
        end

        unless validate_cart_available?(cart_id)
            @business_errors[:cart_id] = 'Invalid Cart'
        end

        unless validate_cart_belongs_to_user?(cart_id, params[:user_id])
            @business_errors[:user_id] = 'You Do Not Have Access To This Cart'
        end

        raise_if_business_rule_violated!(@business_errors.any?, 'Cart Validation Failed', @business_errors)
    end

    def validate_cart_product_schema(cart_id, product_id, params)
        formatted_params = {
            quantity: params[:quantity],
            user_id: params[:user_id],
            product_id: product_id,
            cart_id: cart_id
        }

        schema_validation = ManipulateCardProductSchema.new().call(formatted_params)
        raise_if_model_invalid!(schema_validation.failure?, 'Cart Product Validation Failed', schema_validation.errors.to_h)
    end

    def create_cart_business_rules(params)
        @business_errors = {}

        unless client_validation(params[:user_id]) 
            @business_errors[:user_id] = "Invalid User"
        end

        if validate_user_already_has_active_cart(params[:user_id])
             @business_errors[:user_id] = "User Already Has Active Cart"
        end

        raise_if_business_rule_violated!(@business_errors.any?, 'Cart Validation Failed', @business_errors)
    end

    # Singular Validations

    def validate_cart_has_any_product?(cart_id)
        @cart_product_repository.cart_has_any_product?(cart_id)
    end
    
    def validate_cart_belongs_to_user?(cart_id, user_id)
        @cart_repository.cart_belongs_to_user?(cart_id, user_id)
    end

    def validate_cart_has_product(cart_id, product_id)
        @cart_product_repository.cart_has_product?(cart_id, product_id)
    end

    def validate_quantity_amount_to_remove(cart_id, product_id, quantity)
        @cart_product_repository.quantity_amount_to_remove_available?(cart_id, product_id, quantity)
    end

    def validate_cart_available?(cart_id)
        @cart_repository.cart_exists_based_in_status?(cart_id, 'active')
    end

    def validate_product_available?(product_id, minum_available_stock)
        @product_service.product_available?(product_id, minum_available_stock)
    end

    def cart_not_active?(cart)
        cart[:cart_status] != 'active'
    end

    def validate_user_already_has_active_cart(client_id)
        @cart_repository.exists_active_cart_associated_to_user?(client_id)
    end

    def client_validation(client_id)
        @user_service.user_exists_based_in_role?(client_id, 'client')
    end
end