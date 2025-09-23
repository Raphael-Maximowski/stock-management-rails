class ProductRepository
    def initialize(model = Product)
        @model = model
    end

    def find(id)
        @model.find_by(id: id)
    end

    def list
        @model.all
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
end