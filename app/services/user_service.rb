class UserService
    include ErrorHandling

    def initialize (repository: UserRepository.new)
        @repository = repository
    end

    def find_user(id)
        find_and_set_user(id)
    end

    def list_users
        @repository.list
    end

    def user_exists_based_in_role?(user_id, role)
        @repository.user_exists_based_in_role?(user_id, role)
    end

    def update_user(user_params = normalize_params(params))
        find_and_set_user(user_params[:id])
        update_user_schema_validation(user_params)
        update_user_business_rules(user_params)
        update_user_entity(user_params)
    end

    def delete_user(id)
        find_and_set_user(id)
        update_user_entity({ status: 'inactive' })
    end

    def user_login(params)
        user_login_schema_validation(params)
        find_user_by_email(params[:email])
        validate_user_password(params[:password])
    end

    def user_register(user_params = normalize_params(params))
        create_user_schema_validation(user_params)
        create_user_business_rules(user_params)

        @user = @repository.create(user_params)
        generate_token_and_render_user()
    end

    private

    # Own Methods

    def validate_user_password(password)
        if @user&.authenticate(password)
            generate_token_and_render_user()
        else
            raise_unauthorized_exception()
        end
    end

    def render_filtered_data_from_user(token)
        { user: @user.as_json(only: [:id, :email, :name, :role]), token: token }
    end

    def generate_token
        JwtService.encode(user_id: @user.id)
    end

    def generate_token_and_render_user
        token = generate_token()
        render_filtered_data_from_user(token)
    end

    def find_user_by_email(email)
        @user = @repository.find_by_email(email) || raise_unauthorized_exception()
    end

    def update_user_entity(new_params)
        @repository.update(@user, new_params)
    end

    def find_and_set_user(id)
        @user = @repository.find(id) || raise_if_model_not_found!(user.nil?, 'User Not Found')
    end

    def normalize_params(params)
      params[:email] = params[:email].downcase if params[:email]
      params
    end

    # Schemas And Business Validations

    def user_login_schema_validation(params)
        schema_validation = UserLoginSchema.new().call(params)
        raise_if_model_invalid!(schema_validation.failure?, 'Validation Failed', schema_validation.errors.to_h)
    end

    def update_user_schema_validation(params)
        schema_validation = UserUpdateSchema.new().call(params)
        raise_if_model_invalid!(schema_validation.failure?, 'Validation Failed', schema_validation.errors.to_h)
    end

    def update_user_business_rules(params)
        @business_errors = {}
        if validate_email_exists_excluding_id?(params[:email], params[:id])
            @business_errors[:email] = 'has already been taken'
        end 
    
        raise_if_business_rule_violated!(@business_errors.any?, 'Validation Failed', @business_errors)
    end
    
    def create_user_schema_validation(params)
        schema_validation = UserCreateSchema.new().call(params)
        raise_if_model_invalid!(schema_validation.failure?, 'Validation Failed', schema_validation.errors.to_h)
    end

    def create_user_business_rules(params)
        @business_errors = {}
        if validate_email_exists?(params[:email])
            @business_errors[:email] = 'has already been taken' 
        end

        if params[:password] != params[:password_confirmation]
            @business_errors[:password] = 'Password Must Be Equal to Password Confirmation' 
        end
    
        raise_if_business_rule_violated!(@business_errors.any?, 'Validation Failed', @business_errors)
    end

    # Singular Validations

    def validate_email_exists_excluding_id?(email, id)
        return unless email && id
        @repository.email_exists_excluding_id?(email, id)
    end

    def validate_email_exists?(email)
        return unless email
        @repository.email_exists?(email)
    end
end