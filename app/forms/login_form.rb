class LoginForm < Reform::Form
  property :api_user
  property :api_key

  validates :api_user, presence: true
  validates :api_key, presence: true
end