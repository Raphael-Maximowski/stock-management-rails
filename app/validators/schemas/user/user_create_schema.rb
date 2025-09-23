class UserCreateSchema < UserBaseSchema
    params do
        required(:email).filled(:string, size?: 1..255)
        required(:name).filled(:string, size?: 1..255)
    end

    rule(:email).validate(:email_format)
end