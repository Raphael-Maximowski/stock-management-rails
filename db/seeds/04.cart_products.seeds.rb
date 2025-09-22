
carts = Cart.all
products = Product.where(active: true)

if carts.empty? || products.empty?
  puts "⚠️  ERRO: Crie carts e produtos primeiro!"
  exit 1
end

total_cart_products = 0

carts.each do |cart|
  product_count = case cart.cart_status
                  when 'active' then Faker::Number.between(from: 1, to: 4)
                  when 'completed' then Faker::Number.between(from: 2, to: 5)
                  else Faker::Number.between(from: 1, to: 3)
                  end

  selected_products = products.sample(product_count)
  
  selected_products.each do |product|
    quantity = Faker::Number.between(from: 1, to: 3)
    
    CartProduct.create!(
      cart_id: cart.id,
      product_id: product.id,
      quantity: quantity,
      created_at: Faker::Time.between(from: cart.created_at, to: Time.now)
    )
    
    total_cart_products += 1
  end
end