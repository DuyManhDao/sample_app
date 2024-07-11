class User < ApplicationRecord
  before_save :downcase_email

  validates :name, presence: true,
            length: {maximum: Settings.user.name.max_length}
  validates :email, presence: true,
            length: {maximum: Settings.user.email.max_length},
            format: {with: Settings.user.email.valid},
            uniqueness: true
  validate :birthday_condition

  has_secure_password

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
