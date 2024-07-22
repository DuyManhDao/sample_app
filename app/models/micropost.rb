class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display,
                       resize_to_limit: [Settings.image.width,
Settings.image.height]
  end

  validates :content, presence: true, length: {maximum: Settings.digit_140}
  validates :image, content_type: {in: %w(image/jpeg image/gif image/png),
                                   message: "must be a valid image format"},
            size: {less_than: 5.megabytes, message: "should be less than 5MB"}
  scope :newest, ->{order(created_at: :desc)}
end
