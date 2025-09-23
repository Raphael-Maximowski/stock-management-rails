class StockReservationService
    def initialize(stock_reservation_repository = StockReservationRepository.new)
        @stock_reservation_repository = stock_reservation_repository
    end

    def reserve(quantity, product_id, cart_id)
        @reservation = @stock_reservation_repository.find_reservations(product_id, cart_id)
        @reservation.quantity ||= 0

        new_quantity = @reservation.quantity += quantity
        new_reservation_params = {
            quantity: new_quantity,
            reservation_status: 'active'
        }

        @reservation = @stock_reservation_repository.update(@reservation, new_reservation_params)
        @reservation
    end

    def release(quantity, product_id, cart_id)
        @reservation = @stock_reservation_repository.find_reservations(product_id, cart_id)

        new_quantity = @reservation.quantity -= quantity
        new_reservation_params = {
            quantity: new_quantity,
            reservation_status: new_quantity == 0 ? 'inactive' : 'active'
        }

        @reservation = @stock_reservation_repository.update(@reservation, new_reservation_params)
        @reservation
    end

    def completed(product_id, cart_id)
        @reservation = @stock_reservation_repository.find_reservations(product_id, cart_id)

        new_reservation_params = {
            reservation_status: 'completed'
        }

        @reservation = @stock_reservation_repository.update(@reservation, new_reservation_params)
        @reservation
    end
end