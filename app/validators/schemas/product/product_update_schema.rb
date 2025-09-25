class ProductUpdateSchema < Dry::Validation::Contract
    AVAILABLE_KEYS = ['available_stock', 'name', 'price', 'active', 'description']

    params do
        optional(:available_stock).filled(:integer, gt?: 0)
        optional(:name).filled(:string, size?: 0..255)
        optional(:price).filled(:decimal, gt?: 0)
        optional(:description).maybe(:string, size?: 0..65535)
    end 

    rule(:available_stock, :name, :price, :description) do
        fields_present = [ values.key?(:available_stock), values.key?(:name), values.key?(:price),  
            values.key?(:description) && !values[:description].nil? ].any?
        
        unless fields_present
            base.failure('must provide at least one field to update: available_stock, name, price or description')
        end
    end
end