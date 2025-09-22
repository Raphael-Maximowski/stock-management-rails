10.times do |i|
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    created_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
  )
end