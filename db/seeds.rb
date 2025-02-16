# WishlistItem.destroy_all
# Wishlist.destroy_all
# Item.destroy_all
# Message.destroy_all
# Participant.destroy_all
# Assignment.destroy_all
# Group.destroy_all
# User.destroy_all

# Create Users
users = []
5.times do |i|
  email = "user#{i + 1}@example.com"
  existing_user = User.find_by(email: email)

  users << (existing_user || User.create!(
    name: "User #{i + 1}",
    email: email,
    password: 'password'
  ))
end

# Create Groups
groups = []
3.times do |i|
  groups << Group.create!(
    group_name: "Group #{i + 1}",
    user: users.sample,
    budget: rand(1000..5000),
    event_name: "Event #{i + 1}",
    event_date: Time.now + rand(1..10).days,
    group_code: "GRP#{i + 1}CODE",
    message: "Welcome to Group #{i + 1}!"
  )
end

# Create Participants
participants = []
groups.each do |group|
  group_users = users.sample([3, users.size].min) 
  group_users.each do |user|
    participants << Participant.create!(
      user: user,
      group: group,
      is_admin: [true, false].sample
    )
  end

  # Ensure at least one participant is present
  if group.participants.empty?
    user = users.sample
    participants << Participant.create!(
      user: user,
      group: group,
      is_admin: false
    )
  end
end

categories = ["Electronics", "Fashion", "Accessories", "Toys", "Books"]
ages = ["12 years and under", "12 - 18 years", "18 - 25 years", "25 - 35 years", "35 - 50 years", "50 years and over"]
genders = ["Male", "Female", "Unisex"]

# Create Items
items = []
20.times do |i|
  items << Item.create!(
    item_name: "Item #{i + 1}",
    price: rand(10..500),
    description: "Description for Item #{i + 1}",
    image_url: "http://example.com/item#{i + 1}.jpg",
    category: categories.sample,
    age: ages.sample,
    gender: genders.sample
  )
end

# Create Wishlists
wishlists = []
participants.each do |participant|
  next unless participant.persisted?
  wishlists << Wishlist.create!(
    participant: participant
  )
end

wishlists.each do |wishlist|
  selected_items = items.sample(3)
  selected_items.each do |item|
    WishlistItem.create!(
      wishlist: wishlist,
      item: item
    )
  end
end

# Create Messages
110.times do |i|
  group = groups.sample
  sender = group.users.sample 

  Message.create!(
    group: group,
    sender: sender,
    message: "This is group message #{i + 1}",
    is_anonymous: [true, false].sample
  )
end

5.times do |i|
  group = groups.sample
  participants_in_group = group.participants
  if participants_in_group.size >= 2
    giver, receiver = participants_in_group.sample(2) 
    Assignment.create!(
      group: group,
      giver: giver,
      receiver: receiver
    )
  end
end

puts "Seeding completed successfully!"

# user1 = User.create(name: "John Doe", email: "john.doe@example.com", password: "password")

# Create a group for the user
# group1 = Group.create(group_name: "Holiday Gifts", user: user1, event_name: "Christmas", event_date: Date.new(2025, 12, 25))

# # Create participants (two participants for the group)
# participant1 = Participant.create(user: user1, group: group1, is_admin: true)
# participant2 = Participant.create(user: User.create(name: "Jane Doe", email: "jane.doe@example.com", password: "password"), group: group1, is_admin: false)

# # Create wishlists for each participant
# wishlist1 = Wishlist.create(participant: participant1)
# wishlist2 = Wishlist.create(participant: participant2)

# # Create items for the wishlists
# item1 = Item.create(item_name: "Toy Car", price: 15.99, description: "A small red toy car", image_url: "https://example.com/toy_car.jpg")
# item2 = Item.create(item_name: "Books", price: 9.99, description: "A set of adventure books", image_url: "https://example.com/books.jpg")
# item3 = Item.create(item_name: "Lego Set", price: 29.99, description: "A fun Lego building set", image_url: "https://example.com/lego_set.jpg")
# item4 = Item.create(item_name: "Smartwatch", price: 99.99, description: "A stylish smartwatch", image_url: "https://example.com/smartwatch.jpg")
# item5 = Item.create(item_name: "Headphones", price: 59.99, description: "Noise-canceling headphones", image_url: "https://example.com/headphones.jpg")
# item6 = Item.create(item_name: "Drone", price: 199.99, description: "A high-quality drone", image_url: "https://example.com/drone.jpg")
# item7 = Item.create(item_name: "Bluetooth Speaker", price: 49.99, description: "Portable Bluetooth speaker", image_url: "https://example.com/bluetooth_speaker.jpg")
# item8 = Item.create(item_name: "Smart Home Assistant", price: 89.99, description: "Voice-controlled smart assistant", image_url: "https://example.com/smart_home_assistant.jpg")
# item9 = Item.create(item_name: "Fitness Tracker", price: 59.99, description: "Activity and heart-rate tracker", image_url: "https://example.com/fitness_tracker.jpg")
# item10 = Item.create(item_name: "Electric Scooter", price: 299.99, description: "Eco-friendly electric scooter", image_url: "https://example.com/electric_scooter.jpg")

# # Add multiple items to each wishlist for participant 1 via join table (wishlist_items)
# wishlist1.items << [item1, item2, item3, item4, item5, item6, item7, item8, item9, item10]

# # Add more items to participant 2's wishlist
# item11 = Item.create(item_name: "Board Game", price: 20.99, description: "A fun board game", image_url: "https://example.com/board_game.jpg")
# item12 = Item.create(item_name: "Jacket", price: 49.99, description: "Winter jacket", image_url: "https://example.com/jacket.jpg")
# item13 = Item.create(item_name: "Bicycle", price: 199.99, description: "A cool mountain bike", image_url: "https://example.com/bicycle.jpg")
# item14 = Item.create(item_name: "Smartphone", price: 499.99, description: "Latest model smartphone", image_url: "https://example.com/smartphone.jpg")
# item15 = Item.create(item_name: "Sunglasses", price: 29.99, description: "Sunglasses with UV protection", image_url: "https://example.com/sunglasses.jpg")
# item16 = Item.create(item_name: "Camera", price: 299.99, description: "Digital camera with high resolution", image_url: "https://example.com/camera.jpg")
# item17 = Item.create(item_name: "Gaming Console", price: 399.99, description: "Next-gen gaming console", image_url: "https://example.com/gaming_console.jpg")
# item18 = Item.create(item_name: "Backpack", price: 69.99, description: "Stylish and durable backpack", image_url: "https://example.com/backpack.jpg")
# item19 = Item.create(item_name: "Wireless Earbuds", price: 79.99, description: "High-quality wireless earbuds", image_url: "https://example.com/wireless_earbuds.jpg")
# item20 = Item.create(item_name: "Cooking Set", price: 99.99, description: "Complete cookware set", image_url: "https://example.com/cooking_set.jpg")

# # Add multiple items to wishlist for participant 2 via join table (wishlist_items)
# wishlist2.items << [item11, item12, item13, item14, item15, item16, item17, item18, item19, item20]

# # Create a message between participants
# Message.create(group: group1, sender_id: participant1.user.id, receiver_id: participant2.user.id, message: "Hey, I have some ideas for gifts!", is_anonymous: false, read: false)

# puts "Data seeded successfully!"
 