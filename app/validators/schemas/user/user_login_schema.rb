class UserLoginSchema < Dry::Validation::Contract
    params do
        required(:email).filled(:string, size?: 1..255)
        required(:password).filled(:string, size?: 1..255)
    end
end