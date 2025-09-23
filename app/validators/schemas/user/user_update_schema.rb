class UserUpdateSchema < UserBaseSchema
    params do
        optional(:email).filled(:string, size?: 1..255)
        optional(:name).filled(:string, size?: 1..255)
    end

    rule(:email, :name, :role) do
        fields_present = [values[:email], values[:name], values[:role]].any?
        
        unless fields_present
            key.failure('must provide at least one field to update: email, name or role')
        end
    end

    rule(:email).validate(:email_format)
end