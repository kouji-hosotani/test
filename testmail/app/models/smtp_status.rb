class SmtpStatus < ActiveRecord::Base
  belongs_to :company
  default_scope -> {where :del_flag => 0}
  scope :company_filter, -> {where :company_id => User.current_user.profile.company_id}

  CIPHER = 'aes-256-cbc'

  class << self
    def decrypt(id)
      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.encrypt_secure_key, CIPHER)
      crypt.decrypt_and_verify(id)
    end
    
    def encrypt(id)
      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.encrypt_secure_key, CIPHER)
      crypt.encrypt_and_sign(id)
    end
  end

end
