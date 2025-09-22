user_ids = User.pluck(:id)
available_users = user_ids.dup

10.times do |i|
  status = ['active', 'abandoned', 'completed'].sample
  
  if status == 'active' && available_users.any?
    user_id = available_users.pop
  else
    user_id = user_ids.sample
  end

  Cart.create!(
    user_id: user_id,
    cart_status: status,
    total_items: 0,
    total_amount: 0.0,
    created_at: Faker::Time.between(from: 6.months.ago, to: Time.now)
  )
end