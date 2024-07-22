class User < ApplicationRecord
  has_many :microposts, dependent: :destroy

  attr_accessor :remember_token, :activation_token, :reset_token

  before_save :downcase_email
  before_create :create_activation_digest
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

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def forget
    update_column :remember_digest, nil
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.time_to_expire.hours.ago
  end

  def feed
    microposts
  end

  private

  def downcase_email
    email.downcase!
  end

  def birthday_condition
    return if birthday.blank? || birthday_within_limits?

    errors.add(:birthday,
               t("user.birthday.out_of_range",
                 min_age: Settings.user.birthday.min_age,
                 max_age: Settings.user.birthday.max_age))
  end

  def birthday_within_limits?
    min_date = Settings.user.birthday.max_age.years.ago.to_date
    max_date = Settings.user.birthday.min_age.years.ago.to_date

    birthday.between?(min_date, max_date)
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
