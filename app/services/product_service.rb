class ProductService
    include ErrorHandling

    def initialize(product_repository = ProductRepository.new, user_repository = UserRepository.new)
        @product_repository = product_repository 
        @user_repository = user_repository
    end

    def product_available?(product_id, available_stock)
        @product_repository.product_available?(product_id, available_stock)
    end

    def find_product(id)
        @product = @product_repository.find(id)
        raise_if_model_not_found!(@product.nil?, 'Product Not Found')
    
        @product
    end

    def list_products
        @product_repository.list
    end

    def create_product(params)
        params_validation = ProductCreateSchema.new().call(params)
        raise_if_model_invalid!(params_validation.failure?, 'Validation Failed', params_validation.errors.to_h)

        params_business_validation = create_product_business_rules(params)
        raise_if_business_rule_violated!(params_business_validation, 'Product Validation Failed', @business_errors)

        @product = @product_repository.create(params_validation.to_h)
    end

    def update_product_stock_after_remove(product, quantity)
        @product_repository.update(product, { 
                reserved_stock: product.reserved_stock - quantity, 
                available_stock: product.available_stock + quantity 
            }
        )
    end

    def update_product_stock_after_insert(product, quantity)
        @product_repository.update(product, { 
                reserved_stock: product.reserved_stock + quantity, 
                available_stock: product.available_stock - quantity 
            }
        )
    end

    def update_product_stock_after_checkout(product, quantity)
        @product_repository.update(product , { reserved_stock: product.reserved_stock - quantity })
    end

    def update_product(params)
        @product = @product_repository.find(params[:id])
        raise_if_model_not_found!(@product.nil?, 'Product Not Found')

        params_validation = ProductUpdateSchema.new().call(params)
        raise_if_model_invalid!(params_validation.failure?, 'Product Validation Failed', params_validation.errors.to_h)

        params_business_validation = update_product_business_rules(@product, params)
        raise_if_business_rule_violated!(params_business_validation, 'Product Validation Failed', @business_errors)

        @product = @product_repository.update(@product ,params_validation.to_h)
    end

    def delete_product(id)
        @product = @product_repository.find(id)
        raise_if_model_not_found!(@product.nil?, 'Product Not Found')

        product_new_params = { active: false }
        @product = @product_repository.update(@product , product_new_params)
    end

    private

    def create_product_business_rules(params)
        @business_errors = {}

        if !validate_product_owner_exists(params[:user_id])
            @business_errors[:user_id] = 'Invalid User Id'
        end

        if validate_product_name_registered(params[:name])
            @business_errors[:name] = 'has been taken'
        end

    end

    def update_product_business_rules(product, params)
        @business_errors = {}
    
        if params.key?(:available_stock) && !available_stock_is_greater_than_reserved_stock(product[:reserved_stock], params[:available_stock])
            @business_errors[:available_stock] = 'Available Stock Must Be Greater Or Equal Reserved Stock'
        end

        if params.key?(:name) && validate_product_name_registered(params[:name])
            @business_errors[:name] = 'has been taken'
        end

        @business_errors.any?
    end

    def available_stock_is_greater_than_reserved_stock(reserved_stock, available_stock)
        available_stock >= reserved_stock
    end

    def validate_product_owner_exists(user_id)
        @user_repository.manager_exists?(user_id, 'manager')
    end

    def validate_product_name_registered(name)
        @product_repository.product_name_registered?(name)
    end
end