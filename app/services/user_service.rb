class UserService
    include ErrorHandling
    
    def initialize (repository: UserRepository.new)
        @repository = repository
    end

    def user_exists_based_in_role?(user_id, role)
        @repository.user_exists_based_in_role?(user_id, role)
    end

    def find_user(id)
        user = @repository.find(id)
        raise_if_model_not_found!(user.nil?, 'User Not Found')
        
        user
    end

    def list_users
        @repository.list
    end

    def create_user(params)
        params = normalize_params(params)

        params_validation = UserCreateSchema.new().call(params)
        raise_if_model_invalid!(params_validation.failure?, 'Validation Failed', params_validation.errors.to_h)

        params_bussiness_rules_validation = create_user_business_rules(params)
        raise_if_business_rule_violated!(params_bussiness_rules_validation, 'Validation Failed', @business_errors)

        @repository.create(params_validation.to_h)
    end

    def update_user(params)
        params = normalize_params(params)

        user = @repository.find(params[:id])
        raise_if_model_not_found!(user.nil?, 'User Not Found')

        params_validation = UserUpdateSchema.new().call(params)
        raise_if_model_invalid!(params_validation.failure?, 'Validation Failed', params_validation.errors.to_h)
    
        params_bussiness_rules_validation = update_user_business_rules(params)
        raise_if_business_rule_violated!(params_bussiness_rules_validation, 'Validation Failed', @business_errors)
        
        user = @repository.update(user, params_validation.to_h)
        user
    end

    def delete_user(id)
        user = @repository.find(id)
        raise_if_model_not_found!(user.nil?, 'User Not Found')
        
        user_new_status = { status: 'inactive' }
        user = @repository.update(user, user_new_status)
    end

    private
    def update_user_business_rules(params)
        @business_errors = {}
        @business_errors[:email] = 'has already been taken' if validate_email_exists_excluding_id?(params[:email], params[:id])
        
        @business_errors.any?
    end
    
    def create_user_business_rules(params)
        @business_errors = {}
        @business_errors[:email] = 'has already been taken' if validate_email_exists?(params[:email])
        
        @business_errors.any?
    end

    def validate_email_exists_excluding_id?(email, id)
        return unless email && id
        @repository.email_exists_excluding_id?(email, id)
    end

    def validate_email_exists?(email)
        return unless email
        @repository.email_exists?(email)
    end

    def normalize_params(params)
      params[:email] = params[:email].downcase if params[:email]
      params
    end
end