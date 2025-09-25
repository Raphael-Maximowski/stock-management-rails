module ErrorHandling
  extend ActiveSupport::Concern

  class ValidationError < StandardError
    attr_reader :error_details

    def initialize(details)
      @error_details = details
    end
  end

  class BusinessRuleError < StandardError
    attr_reader :error_details

    def initialize(details)
      @error_details = details
    end
  end

  class EmptyRuleError < StandardError
    attr_reader :error_details

    def initialize(details)
      @error_details = details
    end
  end

  class Unauthorized < StandardError
  end

  included do
    private

    def raise_unauthorized_exception
      raise Unauthorized.new
    end

    def raise_if_model_not_found!(condition, message)
      if condition
        error_details = { message: message }.compact
        raise EmptyRuleError.new(error_details)
      end
    end

    def raise_if_business_rule_violated!(condition, message = nil, errors = nil)
      if condition
        error_details = { message: message, details: errors }.compact
        raise BusinessRuleError.new(error_details)
      end
    end

    def raise_if_model_invalid!(condition, message = nil, errors = nil)
      if condition
        error_details = { message: message, details: errors }.compact
        raise ValidationError.new(error_details)
      end
    end
  end
end