class ProductService
    include ErrorHandling

    def initialize(product_repository = ProductRepository.new, user_repository = UserRepository.new)
        @product_repository = product_repository 
        @user_repository = user_repository
    end

    def find_product(id)
        @product = @product_repository.find(id) || raise_if_model_not_found!(@product.nil?, 'Product Not Found')
    end

    def list_products
        @product_repository.list
    end

    def product_available?(product_id, available_stock)
        @product_repository.product_available?(product_id, available_stock)
    end

    def create_product(params)
        validate_create_product_schema(params)
        create_product_business_rules(params)
        @product = @product_repository.create(params)
    end

    def update_product(params)
        find_product(params[:id])
        update_product_schema_validation(params)
        update_product_business_rules(params)

        update_product_entity(params)
    end

    def delete_product(id)
        find_product(id)
        update_product_entity({ active: false })
    end

    def update_product_stock_after_checkout(product, quantity)
        update_product_entity(product, { reserved_stock: product.reserved_stock - quantity })
    end

    def update_product_stock_after_remove(product, quantity)
        update_product_entity(product, { 
            reserved_stock: product.reserved_stock - quantity, 
            available_stock: product.available_stock + quantity 
        })
    end

    def update_product_stock_after_insert(product, quantity)
        update_product_entity(product, { 
            reserved_stock: product.reserved_stock + quantity, 
            available_stock: product.available_stock - quantity 
        })
    end

    private

    # Own Methods

    def update_product_entity(product = @product, new_params)
        @product = @product_repository.update(product, new_params)
    end

    # Schemas And Business Validations

    def validate_create_product_schema(params)
        schema_validation = ProductCreateSchema.new().call(params)
        raise_if_model_invalid!(schema_validation.failure?, 'Validation Failed', schema_validation.errors.to_h)
    end

    def create_product_business_rules(params)
        @business_errors = {}

        if !validate_product_owner_exists(params[:user_id])
            @business_errors[:user_id] = 'Invalid User Id'
        end

        if validate_product_name_registered(params[:name])
            @business_errors[:name] = 'has been taken'
        end
            
        raise_if_business_rule_violated!(@business_errors.any?, 'Product Validation Failed', @business_errors)
    end

    def update_product_schema_validation(params)
        schema_validation = ProductUpdateSchema.new().call(params)
        raise_if_model_invalid!(schema_validation.failure?, 'Product Validation Failed', schema_validation.errors.to_h)
    end

    def update_product_business_rules(params)
        @business_errors = {}

        if params.key?(:name) && validate_product_name_registered_excluding_id?(params[:name], params[:id])
            @business_errors[:name] = 'has been taken'
        end

        raise_if_business_rule_violated!(@business_errors.any?, 'Product Validation Failed', @business_errors)
    end

    # Singular Validations 

    def validate_product_owner_exists(user_id)
        @user_repository.user_exists_based_in_role?(user_id, 'manager')
    end

    def validate_product_name_registered_excluding_id?(name, id)
        @product_repository.product_name_registered_excluding_id?(name, id)
    end

    def validate_product_name_registered(name)
        @product_repository.product_name_registered?(name)
    end
end