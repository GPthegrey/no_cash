require 'faker'
require 'cloudinary'
require 'open-uri'

Deal.destroy_all
Offer.destroy_all
Item.destroy_all
User.destroy_all
Category.destroy_all

# Categories
CATEGORIES = ['Electronics', 'Clothing', 'Books', 'Furniture', 'Sports Equipment', 'Home Appliances', 'Toys', 'Beauty Products']
CONDITIONS = ["new", "like new", "good", "fair", "poor"]

CATEGORIES.each do |name|
  Category.create!(name: name)
end

22.times do |time|
  puts "creating user"
  user = User.create!(email: "#{time}@mail.com", password: 'password', address: '123 Main St')
  5.times do
    puts "creating item"
    item = Item.create!(user: user, category: Category.all.sample, name: Faker::Book.title, description: Faker::Book.genre, condition: CONDITIONS.sample)

    0.times do
      puts "creating item photoo"

      image_url = Faker::LoremFlickr.image(size: "200x200", search_terms: ['book'])
      io = URI.open(image_url)

      item.photos.attach(io:, filename: "item_#{Time.now.to_i}.jpg", content_type: 'image/jpg')
    end
  end
end

User.first(10).each do |user|
puts "creating user"

  1.times do |time|
    puts "creating offer for user"
    Offer.create!(user: user, offered_item_id: user.items.pluck(:id).sample, requested_item_id: Item.select{ |item| item.user != user }.sample.id)

  end
  user.offers.each do |offer|
    if [1,2].sample == 1
      puts "creating deal for offer"

      deal = Deal.create!(offer_id: offer.id, status: 'accepted')
      rand = [1, 2, 3, 4].sample

    #   puts "creating review deal for offer"

    # #   deal.update(status: 'completed')
    # #   Review.create!(user_reviewed_id: user.id, deal: deal, user_reviewer_id: Item.find(offer.requested_item_id).user.id, content: 'Smooth exchange')
    # # elsif rand == 3
    # #   deal.update(status: 'completed')
    # #   Review.create!(user_reviewed_id: Item.find(offer.requested_item_id).user.id, deal: deal, user_reviewer_id: user.id, content: 'Great transaction')
    # # elsif rand == 2
    #   deal.update(status: 'completed')
    #   Review.create!(user_reviewed_id: Item.find(offer.requested_item_id).user.id, deal: deal, user_reviewer_id: user.id, content: 'Great transaction')
    #   Review.create!(user_reviewed_id: user.id, deal: deal, user_reviewer_id: Item.find(offer.requested_item_id).user.id, content: 'Smooth exchange')
    end

  end
end
