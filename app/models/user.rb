class User < ApplicationRecord
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_save :downcase_email

  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, length: {maximum: 50},
format: {with: VALID_EMAIL_REGEX}, uniqueness: true
  validate :birthday_within_100_years

  has_secure_password

  private

  def downcase_email
    email.downcase!
  end

  def birthday_within_100_years
    if birthday.present? &&
       (birthday < 100.years.ago.to_date || birthday > Time.zone.today)
      errors.add(:birthday, "must be within the last 100 years")
    end
  end
end
