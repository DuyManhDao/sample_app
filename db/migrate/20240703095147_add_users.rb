class AddUsers < ActiveRecord::Migration[7.0]
  def change
    5.times do |i|
      User.create(name: "User ##{i}", email: "user_#{i}@gmail.com")
    end
  end
end
