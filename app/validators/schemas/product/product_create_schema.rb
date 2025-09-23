class ProductCreateSchema < Dry::Validation::Contract
    params do
        required(:available_stock).filled(:integer, gt?: 0)
        required(:user_id).filled(:integer, gt?: 0)
        required(:name).filled(:string, size?: 0..255)
        required(:price).filled(:decimal, gt?: 0)
        optional(:description).filled(:string, size?: 0..65535)
    end 
end