class ApplicationController < ActionController::API
    rescue_from ErrorHandling::ValidationError, with: :handle_validation_error
    rescue_from ErrorHandling::BusinessRuleError, with: :handle_business_error
    rescue_from ErrorHandling::EmptyRuleError, with: :handle_empty_validation_error

    before_action :authenticate_request

    def handle_empty_validation_error(exception)
        error_details = exception.error_details || {}
    
        render json: {
            error: {
                message: error_details[:message] || 'Not Found',
            }
        }, status: :not_found
    end

    def handle_validation_error(exception)
        error_details = exception.error_details || {}
    
        render json: {
            error: {
                message: error_details[:message] || 'Validation failed',
                details: error_details[:details] || {}
            }
        }, status: :unprocessable_entity
    end

    def handle_business_error(exception)
        error_details = exception.error_details || {}
    
        render json: {
            error: {
                message: error_details[:message] || 'Business rule violation',
                details: error_details[:details] || {}
            }
        }, status: :conflict 
  end

  private

    private

    def authenticate_request
        header = request.headers['Authorization']
        token = header&.split(' ')&.last

    if token
        decoded = JwtService.decode(token)
        if decoded && (user_id = decoded[:user_id])
        @current_user = User.find_by(id: user_id)
        end
    end
        render json: { error: 'Not Authenticated' }, status: :unauthorized unless @current_user
    end

    def current_user
        @current_user
    end
end
