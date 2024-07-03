class User < ApplicationRecord
  validates :phone_number, presence: true,
format: {with: /\A\d+\z/, message: "only allows numbers"}
  validates :age, presence: true,
numericality: {only_integer: true, greater_than: 0}
  validates :date_of_birth, presence: true
  validates :gender, presence: true
end
