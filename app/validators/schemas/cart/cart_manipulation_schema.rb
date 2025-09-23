class CartManipulationSchema < Dry::Validation::Contract
    params do
        required(:user_id).filled(:integer, gt?: 0)
    end
end