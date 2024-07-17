class User < ApplicationRecord
  before_save :downcase_email
  scope :newest_first, ->{order(created_at: :desc)}

  validates :name, presence: true,
            length: {maximum: Settings.user.name.max_length}
  validates :email, presence: true,
            length: {maximum: Settings.user.email.max_length},
            format: {with: Settings.user.email.valid_regex},
            uniqueness: true
  validates :password, presence: true,
            length: {minimum: Settings.digits.digit_6}, allow_nil: true
  validate :birthday_condition

  has_secure_password
  attr_accessor :remember_token

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_column :remember_digest, nil
  end

  private

  def downcase_email
    email.downcase!
  end

  def birthday_condition
    return if birthday.blank? || birthday_within_limits?

    errors.add(:birthday,
               I18n.t("user.birthday.out_of_range",
                      min_age: Settings.user.birthday.min_age,
                      max_age: Settings.user.birthday.max_age))
  end

  def birthday_within_limits?
    min_date = Settings.user.birthday.max_age.years.ago.to_date
    max_date = Settings.user.birthday.min_age.years.ago.to_date

    birthday.between?(min_date, max_date)
  end
end
