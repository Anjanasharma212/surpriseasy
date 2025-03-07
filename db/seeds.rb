# WishlistItem.destroy_all
# Wishlist.destroy_all
# Item.destroy_all
# Message.destroy_all
# Participant.destroy_all
# Assignment.destroy_all
# Group.destroy_all
# User.destroy_all

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

  if group.participants.empty?
    user = users.sample
    participants << Participant.create!(
      user: user,
      group: group,
      is_admin: false
    )
  end
end

# Sample Categories
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
  wishlists << Wishlist.create!(participant: participant)
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

# Create Messages (Group & Anonymous)
110.times do |i|
  group = groups.sample
  sender = group.users.sample
  is_anonymous = [true, false].sample

  available_receivers = group.users - [sender]

  message_attributes = {
    group: group,
    sender: sender,
    content: "This is message #{i + 1}",
    is_anonymous: is_anonymous
  }

  if is_anonymous
    if available_receivers.any?
      message_attributes[:receiver] = available_receivers.sample
    else
      message_attributes[:is_anonymous] = false
      message_attributes[:receiver] = nil
    end
  else
    message_attributes[:receiver] = nil
  end

  Message.create!(message_attributes)
end

5.times do |i|
  group = groups.sample
  participants_in_group = group.participants.to_a

  if participants_in_group.size >= 2
    giver, receiver = participants_in_group.sample(2)
    while giver == receiver
      receiver = participants_in_group.sample 
    end

    Assignment.create!(
      group: group,
      giver: giver,
      receiver: receiver
    )
  end
end

puts "✅ Seeding completed successfully!"
