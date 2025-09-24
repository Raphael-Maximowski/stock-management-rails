class ManipulateCardProductSchema < Dry::Validation::Contract
    params do
        required(:quantity).filled(:integer, gt?: 0)
        required(:cart_id).filled(:integer, gt?: 0)
        required(:product_id).filled(:integer, gt?: 0)
        required(:user_id).filled(:integer, gt?: 0)
    end 
end