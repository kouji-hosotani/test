class Memberkind < ActiveRecord::Base
  has_many :cv_signup_dates
  has_many :access_user_daily_counts
end
