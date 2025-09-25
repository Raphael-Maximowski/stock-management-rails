class ProductRepository
    def initialize(model = Product)
        @model = model
    end

    def find(id)
        @model.find_by(id: id, active: true)
    end

    def list 
        @model.where(active: true)
    end

    def create(params)
        @model.create(params)
    end

    def update(product, params)
        product.update(params)
        product
    end

    def product_name_registered?(name)
        @model.where(name: name).exists?
    end

    def product_name_registered_excluding_id?(name, id)
        @model.where(name: name).where.not(id: id).exists?
    end

    def product_available?(id, available_stock)
        @model.where(id: id, active: true).where("available_stock >= ?", available_stock).exists?
    end
end