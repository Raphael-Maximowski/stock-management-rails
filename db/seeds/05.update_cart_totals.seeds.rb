carts = Cart.all

if carts.empty?
  puts "⚠️  Nenhum carrinho encontrado!"
  exit 1
end

total_updated = 0

carts.each do |cart|
  cart_products = cart.cart_products.joins(:product)
  
  total_items = cart_products.sum(:quantity)
  total_amount = cart_products.sum('cart_products.quantity * products.price')
  
  cart.update!(
    total_items: total_items,
    total_amount: total_amount
  )
  
  total_updated += 1
end
