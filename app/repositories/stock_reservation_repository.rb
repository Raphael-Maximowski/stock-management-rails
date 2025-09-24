class StockReservationRepository
    def initialize
        @model = StockReservation
    end

    def find_reservations(product_id, cart_id)
        @model.find_or_initialize_by(cart_id: cart_id, product_id: product_id)
    end

    def update(reservation, params)
        @reservation = reservation.update(params)
        @reservation
    end
end