10.times do |i|
  product_name = Faker::Commerce.unique.product_name
  
  Product.create!(
    name: product_name,
    description: Faker::Lorem.paragraph(sentence_count: 3),
    price: Faker::Commerce.price(range: 10.0..2000.0),
    available_stock: Faker::Number.between(from: 0, to: 200),
    reserved_stock: Faker::Number.between(from: 0, to: 20),
    active: Faker::Boolean.boolean(true_ratio: 0.8), 
    created_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
  )
end