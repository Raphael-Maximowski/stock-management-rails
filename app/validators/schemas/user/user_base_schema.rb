class UserBaseSchema < Dry::Validation::Contract
    USER_ROLES = ['manager', 'client']

    option :user_id, optional: true

    params do
        optional(:role).filled(:string, included_in?: USER_ROLES)
    end

    register_macro(:email_format) do
        next unless value 

        unless URI::MailTo::EMAIL_REGEXP.match?(value)
            key.failure('must be a valid email format')
        end
    end
end