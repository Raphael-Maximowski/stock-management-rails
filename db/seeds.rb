puts "🌱 Iniciando processo de seed..."
puts "=" * 50

# Carregar todos os arquivos .rb da pasta seeds
seed_files = Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort

if seed_files.empty?
  puts "⚠️  Nenhum arquivo de seed encontrado na pasta db/seeds/"
  puts "✅ Processo concluído!"
  exit
end

seed_files.each do |file|
  puts "📁 Executando: #{File.basename(file)}"
  load file
  puts "✅ #{File.basename(file)} - concluído!"
  puts "-" * 30
end

puts "=" * 50
puts "🎉 Seed completo! Todos os arquivos foram executados."
puts "📊 Estatísticas:"
puts "   - Users: #{User.count}"
puts "   - Products: #{Product.count}"
puts "   - Carts: #{Cart.count}"
puts "   - CartProducts: #{CartProduct.count}"